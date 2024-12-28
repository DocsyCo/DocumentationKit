//
//  DocumentationRepository.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB

public protocol DocumentationRepository: Sendable {
    typealias BundleQuery = DocumentationRepositoryBundleQuery

    /// Add a new bundle to the repository
    /// - Parameters:
    ///   - displayName: the display name of the bundle.
    ///   - identifier: the identifier of the bundle
    /// - Returns: the details of the created bundle.
    func addBundle(displayName: String, identifier: String) async throws -> BundleDetail

    /// Retrieve the bundle with the given identifier, if it exists
    /// - Parameter bundleId: the identifier of the bundle.
    /// - Returns: the details of the bundle. if it exists.
    func bundle(_ bundleId: BundleDetail.ID) async throws -> BundleDetail?

    /// Retrieve details for all bundles from this repository
    /// - Parameter query: a query to filter bundles
    /// - Returns: matching bundles
    func search(query: BundleQuery) async throws -> [BundleDetail]

    /// Retrieve completions for a prefix
    /// - Parameters:
    ///   - prefix: the prefix to find completions for
    ///   - limit: the maximum number of completions to retrieve
    func searchCompletions(for prefix: String, limit: Int) async throws -> [String]

    /// Remove a bundle from the repository
    /// - Parameter bundleId: the identifier of the bundle.
    func removeBundle(_ bundleId: BundleMetadata.ID) async throws

    /// Add a revision to a bundle
    /// - Parameters:
    ///   - tag: the tag of the new revision
    ///   - source: the source url for the revision
    ///   - identifier: the identifier of the bundle this revision belongs to
    /// - Returns: the created revision
    func addRevision(
        _ tag: String,
        source: URL,
        toBundle identifier: BundleDetail.ID
    ) async throws -> BundleRevision

    /// Retrieves a revision for a bundle by it's tag
    /// - Parameters:
    ///   - tag: the revision's tag
    ///   - bundleId: the identifier of the bundle
    /// - Returns: the revision matching the tag if any exists
    func revision(_ tag: String, forBundle bundleId: BundleDetail.ID) async throws -> BundleRevision?

    /// Remove a revision from a bundle
    /// - Parameters:
    ///   - tag: the tag of the revision
    ///   - bundleId: the id of the bundle
    func removeRevision(_ tag: BundleRevision.Tag, forBundle bundleId: BundleDetail.ID) async throws
}

public extension DocumentationRepository {
    /// Retrieves details for all bundles from this repository
    func bundles() async throws -> [BundleDetail] {
        try await search(query: .init())
    }
}

public struct DocumentationRepositoryBundleQuery: Sendable {
    public let term: String?

    public init(term: String? = nil) {
        self.term = (term?.isEmpty ?? true) ? nil : term
    }
}
