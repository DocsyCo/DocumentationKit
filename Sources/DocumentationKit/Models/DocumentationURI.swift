//
//  DocumentationURI.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct DocumentationURI: Sendable, Equatable, Codable {
    public static let scheme = "doc"

    public let bundleIdentifier: String
    public let path: String

    public init(bundleIdentifier: String, path: String) {
        self.bundleIdentifier = bundleIdentifier
        self.path = "/" + path.trimmingCharacters(in: slashCharSet)
    }

    public init?(url: URL) {
        guard url.scheme == "doc" else { return nil }
        
        if let host = url.host() {
            self.init(bundleIdentifier: host, path: url.path())
        } else if let firstPathComponent = url.pathComponents.first {
            let path = url.pathComponents.dropFirst().joined(separator: "/")
            self.init(
                bundleIdentifier: firstPathComponent,
                path: path.trimmingCharacters(in: slashCharSet)
            )
        } else {
            return nil
        }
    }

    public var url: URL {
        URL(string: "doc://\(bundleIdentifier)\(path)")!
    }

    public func encode(to encoder: any Encoder) throws {
        try url.encode(to: encoder)
    }

    public init(from decoder: any Decoder) throws {
        let url = try URL(from: decoder)
        guard let parsed = Self(url: url) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Invalid DocumentationURI: \(url.absoluteString)"
            ))
        }

        self = parsed
    }
}

extension DocumentationURI: CustomStringConvertible {
    public var description: String {
        "<" + url.absoluteString + ">"
    }
}
