//
//  FileServer2.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SwiftDocC
import SymbolKit

/// FileServer is a struct simulating a web server behavior to serve files.
public class FileServer {
    /// The base URL of the server. Example: `http://www.example.com`.
    public let baseURL: URL

    /// The list of providers from which files are served.
    private var providers: [String: FileServerProvider] = [:]

    /// Initialize a FileServer instance with a base URL.
    /// - parameter baseURL: The base URL to use.
    public init(baseURL: URL) {
        self.baseURL = baseURL.absoluteURL
    }

    /// Registers a `FileServerProvider` to a `FileServer` objects which can be used to provide content
    /// to a local web page served by local content.
    /// - Parameters:
    ///   - provider: An object conforming to `FileServerProvider`.
    ///   - subPath: The sub-path in which the `FileServerProvider` will be queried for content.
    /// - Returns: A boolean indicating if the registration succeeded or not.
    @discardableResult
    public func register(provider: FileServerProvider, subPath: String = "/") -> Bool {
        guard !subPath.isEmpty else { return false }
        let trimmed = subPath.trimmingCharacters(in: slashCharSet)
        providers[trimmed] = provider
        return true
    }

    public func data(for url: URL) async throws -> Data {
        let urlString = url.absoluteString
        guard urlString.hasPrefix(baseURL.absoluteString) else {
            throw FileServerProviderError.notFound
        }

        let urlPath = urlString
            .trimmingPrefix(baseURL.absoluteString)
            .trimmingCharacters(in: slashCharSet)

        let providerKey = providers.keys
            .sorted { l, r in l.count > r.count }
            .filter { providerPath in urlPath.hasPrefix(providerPath) }
            .first ?? "" // in case missing an exact match, get the root one

        guard let provider = providers[providerKey] else {
            fatalError("A provider has not been passed to a FileServer.")
        }

        return try await provider.data(for: urlPath.removingPrefix(providerKey))
    }
}

/// Checks whether the given string is a known entity definition which might interfere with the rendering engine while dealing with URLs.
private func isKnownEntityDefinition(_ identifier: String) -> Bool {
    SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier(identifier)
}

private extension String {
    /// Removes the prefix of a string.
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// Check that a given string is alphanumeric.
    var isAlphanumeric: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }

    /// Check that a given string is a Swift entity definition.
    var isSwiftEntity: Bool {
        let swiftEntityPattern = #"(?<=\-)swift\..*"#
        if let range = range(of: swiftEntityPattern, options: .regularExpression, range: nil, locale: nil) {
            let entityCheck = String(self[range])
            return isKnownEntityDefinition(entityCheck)
        }
        return false
    }
}
