//
//  DocumentationRepository+Models.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct BundleMetadata: Sendable, Identifiable, Codable, Equatable {
    public let id: UUID
    public let displayName: String
    public let bundleIdentifier: String

    public init(id: UUID, displayName: String, bundleIdentifier: String) {
        self.id = id
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
    }
}

public struct BundleRevision: Sendable, Identifiable, Codable, Equatable {
    public typealias Tag = String

    public var id: String { tag }

    public let bundleId: BundleMetadata.ID
    public let tag: String
    public let source: URL
//    let checksum: String

    public init(bundleId: BundleMetadata.ID, tag: String, source: URL) {
        self.bundleId = bundleId
        self.tag = tag
        self.source = source
    }
}

public struct DocumentationRequest {}

public struct BundleDetail: Sendable, Identifiable, Codable, Equatable {
    public var id: UUID { metadata.id }
    public let metadata: BundleMetadata
    public let revisions: [Revision]

    public init(metadata: BundleMetadata, revisions: [Revision]) {
        self.metadata = metadata
        self.revisions = revisions
    }

    public struct Revision: Sendable, Identifiable, Codable, Equatable {
        public var id: String { tag }
        public let tag: String
        public let source: URL

        public init(tag: String, source: URL) {
            self.tag = tag
            self.source = source
        }
    }
}
