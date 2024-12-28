//
//  SearchIndexer.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SwiftDocC

public final class SearchIndexer: Sendable {
    private let rootURL: URL
    private let writer: SearchIndex.Writer
    private let decoder = JSONDecoder()

    public init(
        rootURL: URL,
        index: SearchIndex.Writer
    ) {
        self.rootURL = rootURL
        self.writer = index
    }

    public struct IndexingResult {
        public let topics: Int
        public let records: Int
    }

    /// indexes the topic at the specified path relative to the rootURL
    /// - Parameter path: a valid path to a topic
    /// - Returns: the number of records indexed
    @discardableResult
    public func indexTopic(at path: String) async throws -> Int {
        let url = rootURL
            .appending(component: "data")
            .appending(path: path)
            .appendingPathExtension("json")

        let data = try Data(contentsOf: url)
        let node = try decoder.decode(RenderNode.self, from: data)

        let records = try node.indexingRecords(onPage: node.identifier)
        try await writer.insert(records)
        return records.count
    }

    /// Indexes the topics at the specified paths relative to the rootURL
    /// - Parameter paths: a list of valid path to a topic
    /// - Returns: the result of the indexing operation
    @discardableResult
    public func indexTopics(at paths: [String]) async throws -> IndexingResult {
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

//// MARK: Read Navigator Index
// extension NavigatorIndex {
//    public func topicPaths() async throws -> [String] {
//        return navigatorTree.numericIdentifierToNode.keys.compactMap { nodeID in
//            let path = self.path(for: nodeID)
//
//            guard let path, !path.contains("#") else {
//                return nil
//            }
//
//            return path
//        }
//    }
// }
