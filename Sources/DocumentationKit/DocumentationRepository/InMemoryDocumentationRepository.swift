//
//  InMemoryDocumentationRepository.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

// MARK: InMemory

public actor InMemoryDocumentationRepository: DocumentationRepository {
    public private(set) var bundleMap: [BundleMetadata.ID: BundleMetadata] = [:]
    public private(set) var bundleRevisions = [BundleMetadata.ID: [BundleRevision.Tag: BundleRevision]]()

    public init(
        bundles: [BundleMetadata] = [],
        revisions: [BundleMetadata.ID: [String: URL]] = [:]
    ) {
        self.bundleMap = Dictionary(uniqueKeysWithValues: bundles.map { ($0.id, $0) })

        self.bundleRevisions = Dictionary(uniqueKeysWithValues: revisions.map { bundleId, revisions in
            let revisions = revisions.map {
                ($0.key, BundleRevision(bundleId: bundleId, tag: $0.key, source: $0.value))
            }

            return (bundleId, Dictionary(uniqueKeysWithValues: revisions))
        })
    }
}

enum DocumentationRepositoryError: Error {
    case notFound
    case duplicate
}

public extension InMemoryDocumentationRepository {
    // MARK: Bundles

    func search(query: BundleQuery) -> [BundleDetail] {
        var bundles = bundleMap
            .sorted(by: { $0.value.displayName < $1.value.displayName })
            .map(\.key)
            .compactMap { self.bundle($0) }

        if let term = query.term?.lowercased() {
            bundles.removeAll(where: { !$0.metadata.displayName.lowercased().contains(term) })
        }

        return bundles
    }

    func searchCompletions(for prefix: String, limit: Int) async throws -> [String] {
        []
    }

    func addBundle(displayName: String, identifier: String) -> BundleDetail {
        let metadata = BundleMetadata(
            id: UUID(),
            displayName: displayName,
            bundleIdentifier: identifier
        )

        bundleRevisions[metadata.id] = [:]
        bundleMap[metadata.id] = metadata

        return BundleDetail(metadata: metadata, revisions: [])
    }

    func bundle(_ bundleId: BundleMetadata.ID) -> BundleDetail? {
        guard let metadata = bundleMap[bundleId] else {
            return nil
        }

        return BundleDetail(
            metadata: metadata,
            revisions: revisions(forBundle: bundleId).map { .init(tag: $0.tag, source: $0.source) }
        )
    }

    func removeBundle(_ bundleId: BundleMetadata.ID) {
        _ = bundleMap.removeValue(forKey: bundleId)
        _ = bundleRevisions.removeValue(forKey: bundleId)
    }

    // MARK: Revisions

    func revisions(
        forBundle bundleId: BundleMetadata.ID
    ) -> [BundleRevision] {
        bundleRevisions[bundleId]?.values.sorted(by: { $0.tag < $1.tag }) ?? []
    }

    func addRevision(
        _ tag: BundleRevision.Tag,
        source: URL,
        toBundle bundleId: BundleMetadata.ID
    ) throws -> BundleRevision {
        let revision = BundleRevision(
            bundleId: bundleId,
            tag: tag,
            source: source
        )

        guard bundleRevisions[bundleId] != nil else {
            throw DocumentationRepositoryError.notFound
        }
        
        guard bundleRevisions[bundleId]?[revision.id] == nil else {
            throw DocumentationRepositoryError.duplicate
        }
        
        bundleRevisions[bundleId]![revision.id] = revision
        return revision
    }

    func revision(
        _ tag: BundleRevision.Tag,
        forBundle bundleId: BundleMetadata.ID
    ) -> BundleRevision? {
        bundleRevisions[bundleId]?[tag]
    }

    func removeRevision(_ tag: BundleRevision.Tag, forBundle bundleId: BundleMetadata.ID) async {
        _ = bundleRevisions[bundleId]?.removeValue(forKey: tag)
    }
}
