//
//  DocumentationRepositoryTests.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import DocumentationKit
import Foundation.NSURL
import Testing

@Suite("DocumentationRepository")
struct DocumentationRepositoryTests {
    let repository: DocumentationRepository = InMemoryDocumentationRepository()

    @Test
    func createBundle() async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let bundle = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        )

        #expect(bundle.metadata.bundleIdentifier == bundleIdentifier)
        #expect(bundle.metadata.displayName == displayName)
        #expect(bundle.revisions.isEmpty)
    }

    @Test
    func listBundles() async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let bundle = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        )

        let bundleList = try await repository.bundles()

        let firstBundle = try #require(bundleList.first)

        #expect(bundleList.count == 1)

        #expect(firstBundle == bundle)
    }

    @Test
    func removeBundle() async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let bundle = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        )

        try #require(try await repository.bundles().count == 1)

        try await repository.removeBundle(bundle.id)
        #expect(try try await repository.bundles().count == 0)
    }

    @Test
    func addRevision() async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let bundleId = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        ).id

        let tag1 = "1.0.0"
        let tag2 = "2.0.0"
        let source = URL(filePath: "/")

        for tag in [tag1, tag2] {
            let createdRevision = try await repository.addRevision(
                tag, source: source,
                toBundle: bundleId
            )

            #expect(createdRevision.tag == tag)
            #expect(createdRevision.source == source)

            let foundByTag = try await repository.revision(tag, forBundle: bundleId)
            #expect(foundByTag == createdRevision)
        }

        let bundle = try #require(try await repository.bundle(bundleId))
        try #require(bundle.revisions.count == 2)

        #expect(bundle.revisions.map(\.tag) == [tag1, tag2])
        #expect(bundle.revisions.map(\.source) == [source, source])
    }

    @Test
    func removeRevision() async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let bundleId = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        ).id

        let tag = "1.0.0"

        _ = try await repository.addRevision(
            tag,
            source: URL(filePath: "/"),
            toBundle: bundleId
        )

        try #require(try await repository.revision(tag, forBundle: bundleId) != nil)

        try await repository.removeRevision(tag, forBundle: bundleId)
        #expect(try await repository.revision(tag, forBundle: bundleId) == nil)
    }

    @Test(arguments: [
        nil,
        "Docu",
        "documentationkit",
        "docu",
        "kit",
        "ki",
    ])
    func searchTest(
        term: String?
    ) async throws {
        let displayName = "DocumentationKit"
        let bundleIdentifier = "com.example.DocumentationKit"

        let createdBundle = try await repository.addBundle(
            displayName: displayName,
            identifier: bundleIdentifier
        )

        try #require(try await repository.bundle(createdBundle.id) != nil)
        let results = try await repository.search(query: .init(term: term))
        #expect(results.count == 1)
        #expect(results.first == createdBundle)
    }
}
