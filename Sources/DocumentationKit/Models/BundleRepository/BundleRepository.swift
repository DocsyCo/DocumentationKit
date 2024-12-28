//
//  BundleRepository.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A repository that serves bundle files from registered providers
public final class BundleRepository: Sendable {
    public enum RepositoryError: Error {
        case unknownBundle(BundleIdentifier)
        case providerError(DocumentationURI, any Error)
    }

    private struct Source {
        let bundle: DocumentationBundle
        let provider: BundleRepositoryProvider
    }

    private let sources = ExclusiveMutating<[BundleIdentifier: Source]>([:])

    public var count: Int {
        get async { await sources.value.count }
    }

    public var isEmpty: Bool {
        get async { await sources.value.isEmpty }
    }

    /// Creates an empty BundleRepository
    public init() {}

    /// Retrieves the matching DocumentationBundle if it is available
    /// - Parameter identifier: the identifier of the bundle
    public func bundle(with identifier: BundleIdentifier) async -> DocumentationBundle? {
        await sources.value[identifier]?.bundle
    }

    /// Register a bundle and an associated provider in repository
    /// - Parameters:
    ///   - bundle: the bundle that should be registered
    ///   - dataProvider: the provider that can serve the bundle
    public func registerBundle(
        _ bundle: DocumentationBundle,
        withProvider dataProvider: BundleRepositoryProvider
    ) async {
        let source = Source(bundle: bundle, provider: dataProvider)

        await sources.mutate { sources in
            sources[bundle.identifier] = source
        }
    }

    /// Unregisters a provider and its associated bundle from the repository
    /// - Parameter bundleIdentifier: The identifier of the bundle
    public func unregisterBundle(with identifier: BundleIdentifier) async {
        await sources.mutate { sources in
            sources.removeValue(forKey: identifier)
        }
    }

    /// Unregisters all providers from this repository
    public func unregisterAll() async {
        await sources.set(to: [:])
    }
    
//    @available(swift, obsoleted: 5.0, message: "This method is no longer supported")
#warning("should be deprecated")
    public func contentsOfUrl(_ url: URL) async throws(RepositoryError) -> Data {
        guard let url = DocumentationURI(url: url) else {
            fatalError("Not a topic url")
        }
        return try await contentsOfUrl(url)
    }

    
    
    public func contentsOfUrl(_ url: DocumentationURI) async throws(RepositoryError) -> Data {
        let source = await sources.value[url.bundleIdentifier]

        guard let source else {
            throw .unknownBundle(url.bundleIdentifier)
        }

        let internalURL = source.bundle.baseURL.appending(
            path: url.path.trimmingCharacters(in: slashCharSet)
        )
        
        do {
            return try await source.provider.data(for: internalURL.path())
        } catch {
            throw RepositoryError.providerError(url, error)
        }
    }
}

enum RepositoryError {
    case notProvided(DocumentationURI)
    case providerError(DocumentationURI, any Error)
}

/// A protocol used for serving content to a `BundleRepository`.
/// > This abstraction lets a `BundleRepository` provide content from multiple types of sources at the same time.
public protocol BundleRepositoryProvider {
    /// - Parameter path: the path to the content
    /// - Returns: The contents of the file at path
    func data(for path: String) async throws -> Data
}

extension BundleRepositoryProvider {
    @_disfavoredOverload
    func data(for path: String) async -> Data? {
        try? await data(for: path)
    }
}
