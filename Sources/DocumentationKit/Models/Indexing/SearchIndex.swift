//
//  SearchIndex.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB
import SwiftDocC

public final class SearchIndex: Sendable {
    public typealias Record = IndexingRecord

    struct Metadata: Codable, FetchableRecord, PersistableRecord {
        static let `default` = Metadata(appVersion: "0.1.0")
        let appVersion: String

        init(appVersion: String) {
            self.appVersion = appVersion
        }
    }

    private let db: DatabaseReader & DatabaseWriter

    /// Creates a search index
    public init(writer: DatabaseWriter) {
        self.db = writer
    }

    /// Opens an in-memory search index
    public convenience init() throws {
        let db = try DatabaseQueue(named: UUID().uuidString, configuration: .init())
        try Reader.migrator.migrate(db)
        self.init(writer: db)
    }

    enum ReadingError: Error {
        case corrupted(_ reason: String)
    }

    /// Return the number of records in the index
    public func count() -> Int {
        try! db.read { db in
            try IndexingRecord.fetchCount(db)
        }
    }

    /// Get a mutable writer to this index
    public func writer() -> Writer {
        Writer(writer: db)
    }

    /// Search the index for records
    /// - Parameters:
    ///   - term: The term to search for
    /// - Returns: a list of indexing records that matched the search
    public func search(
        for term: String,
        limit: Int = 10
    ) throws -> [IndexingRecord] {
        let pattern = FTS5Pattern(matchingAnyTokenIn: term)
        let query = IndexingRecord.matching(pattern).limit(limit)
        let results = try db.read { db in
            try query.fetchAll(db)
        }
        return results
    }
}

// MARK: Writer

public extension SearchIndex {
    final class Writer: Sendable {
        private let writer: DatabaseWriter

        fileprivate init(writer: DatabaseWriter) {
            self.writer = writer
        }

        func insert(_ records: [IndexingRecord]) async throws {
            try await writer.write { db in
                for record in records {
                    try record.insert(db)
                }
            }
        }

        func clear() async throws {
            try await writer.write { db in
                _ = try IndexingRecord.deleteAll(db)
            }
        }
    }
}

// MARK: Docc IndexingRecord

extension IndexingRecord: @retroactive MutablePersistableRecord {}
extension IndexingRecord: @retroactive TableRecord {}
extension IndexingRecord: @retroactive EncodableRecord {}
extension IndexingRecord: @retroactive PersistableRecord {}
extension IndexingRecord: @retroactive FetchableRecord {}
extension IndexingRecord: @retroactive @unchecked Sendable {}

// MARK: Open

public extension SearchIndex {
    /// Opens a search index at the specified file-url
    /// - Parameters:
    ///   - url: a file-url to the location of the search index
    ///   - createIfNeeded: create an index if the path-name doesnt exist
    ///   - fileManager: file manager used to check existence of url
    static func openSearchIndex(
        at url: URL,
        createIfNeeded: Bool = false,
        fileManager: FileManager = .default
    ) throws(Reader.ReaderError) -> SearchIndex {
        try Reader.openSearchIndex(at: url, createIfNeeded: createIfNeeded, fileManager: fileManager)
    }

    /// A Reader that can open a SearchIndex from disk
    enum Reader {
        public enum ReaderError: Error {
            /// No database was found at the url
            /// > set `createIfNeeded` to true to create a database
            case notFound

            case couldNotOpen(any Error)
            case corrupted(_ reason: String)
            case couldNotMigrate(any Error)
        }

        /// Opens a search index at the specified file-url
        /// - Parameters:
        ///   - url: a file-url to the location of the search index
        ///   - createIfNeeded: create an index if the path-name doesnt exist
        ///   - fileManager: file manager used to check existence of url
        public static func openSearchIndex(
            at url: URL,
            createIfNeeded: Bool = false,
            fileManager: FileManager = .default
        ) throws(ReaderError) -> SearchIndex {
            let path = url.path(percentEncoded: false)
            let exists = fileManager.fileExists(atPath: path)

            guard exists || createIfNeeded else {
                throw .notFound
            }

            let database: DatabaseWriter

            do {
                database = try DatabaseQueue(path: url.path())
            } catch {
                throw .couldNotOpen(error)
            }

            do {
                try migrator.migrate(database)
            } catch {
                throw .couldNotMigrate(error)
            }

            return SearchIndex(writer: database)
        }

        fileprivate static let migrator: DatabaseMigrator = {
            var migrator = DatabaseMigrator()
            migrator.registerMigration("createMetadata") { db in
                try db.create(table: "metadata") { t in
                    // Single row guarantee: have inserts replace the existing row,
                    // and make sure the id column is always 1.
                    t.primaryKey("id", .integer, onConflict: .replace)
                        .check { $0 == 1 }

                    // The configuration columns
                    t.column("appVersion", .text)
                }
            }

            migrator.registerMigration("createIndexingRecord") { db in
                try db.create(virtualTable: "indexingRecord", using: FTS5()) { t in
                    t.tokenizer = .porter()
                    t.column("kind").notIndexed()
                    t.column("location").notIndexed()
                    t.column("platforms").notIndexed()
                    t.column("title")
                    t.column("summary")
                    t.column("headings")
                    t.column("rawIndexableTextContent")
                }
            }

            return migrator
        }()
    }
}

// MARK: Read Navigator Index

public extension NavigatorIndex {
    func topicPaths() async throws -> [String] {
        navigatorTree.numericIdentifierToNode.keys.compactMap { nodeID in
            let path = self.path(for: nodeID)

            guard let path, !path.contains("#") else {
                return nil
            }

            return path
        }
    }
}

final class DocumentationIndexer: Sendable {
    private let rootURL: URL
    private let index: SearchIndex.Writer
    private let decoder = JSONDecoder()

    init(
        rootURL: URL,
        index: SearchIndex.Writer
    ) {
        self.rootURL = rootURL
        self.index = index
    }

    struct IndexingResult {
        let topics: Int
        let records: Int
    }

    /// indexes the topic at the specified path relative to the rootURL
    /// - Parameter path: a valid path to a topic
    /// - Returns: the number of records indexed
    @discardableResult
    func indexTopic(at path: String) async throws -> Int {
        let url = rootURL
            .appending(component: "data")
            .appending(path: path)
            .appendingPathExtension("json")

        let data = try Data(contentsOf: url)
        let node = try decoder.decode(RenderNode.self, from: data)

        let records = try node.indexingRecords(onPage: node.identifier)
        try await index.insert(records)
        return records.count
    }

    /// Indexes the topics at the specified paths relative to the rootURL
    /// - Parameter paths: a list of valid path to a topic
    /// - Returns: the result of the indexing operation
    @discardableResult
    func indexTopics(at paths: [String]) async throws -> IndexingResult {
        try await withThrowingTaskGroup(of: Int.self) { group in
            var numberOfRecords = 0
            var numberOfTopics = 0

            for path in paths {
                group.addTask {
                    try await self.indexTopic(at: path)
                }
            }

            for try await indexedRecordsCount in group {
                guard indexedRecordsCount > 0 else {
                    continue
                }

                numberOfRecords += indexedRecordsCount
                numberOfTopics += 1
            }

            return IndexingResult(topics: numberOfTopics, records: numberOfRecords)
        }
    }
}
