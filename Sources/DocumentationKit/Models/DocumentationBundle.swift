//
//  DocumentationBundle.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public typealias BundleIdentifier = String

public struct DocumentationBundle: Identifiable, CustomStringConvertible, Sendable, Codable {
    public var description: String {
        "Documenatation(identifier: '\(identifier)', displayName: '\(displayName)')"
    }

    public var id: String { identifier }

    /// Information about this documentation bundle that's unrelated to its documentation content.
    public let metadata: Metadata

    /// The bundle's human-readable display name.
    public var displayName: String {
        metadata.displayName
    }

    /// The documentation bundle identifier.
    ///
    /// An identifier string that specifies the app type of the bundle.
    /// The string should be in reverse DNS format using only the Roman alphabet in
    /// upper and lower case (A–Z, a–z), the dot (“.”), and the hyphen (“-”).
    public var identifier: BundleIdentifier {
        metadata.identifier
    }

    /// The documentation bundle's version.
    ///
    /// > It's not safe to make computations based on assumptions about the format of bundle's version. The version can be in any format.
//    public var version: String? {
//        metadata.version
//    }

    /// The url to the index directory
    public var indexURL: URL { URL(filePath: indexPath) }
    
    public let indexPath: String

    /// An URL to a custom JSON settings file used to theme renderer output.
    public let themeSettingsUrl: URL?

    /// An URL prefix that should be preprended to
    /// any path output by this bundle
    public let baseURL: URL

    /// Creates a documentation bundle.
    ///
    /// - Parameters:
    ///   - info: Information about the bundle.
    ///   - baseURL: A URL prefix to be appended to the relative presentation URL.
    ///   - indexURL: The url to the index directory
    ///   - themeSettings: A custom JSON settings file used to theme renderer output.
    public init(
        info: Metadata,
        baseURL: URL = URL(string: "/")!,
        indexPath: String,
        themeSettingsUrl: URL? = nil
    ) {
        self.metadata = info
        self.baseURL = baseURL
        self.indexPath = indexPath.trimmingCharacters(in: CharacterSet(["/"]))
        self.themeSettingsUrl = themeSettingsUrl
//        self.documentURLs = documentURLs
//        self.miscResourceURLs = miscResourceURLs
//        self.customHeader = customHeader
//        self.customFooter = customFooter
//        self.themeSettings = themeSettings

//        let documentationRootReference = TopicReference(
//            bundleIdentifier: info.identifier,
//            path: "/documentation",
//            sourceLanguage: .swift
//        )
//        let tutorialsRootReference = TopicReference(
//            bundleIdentifier: info.identifier,
//            path: "/tutorials",
//            sourceLanguage: .swift
//        )
    }
    
    func url(for path: String) -> URL {
        baseURL.appending(path: path)
    }
}

public extension DocumentationBundle {
    struct Metadata: Codable, Equatable, Sendable {
        /// The display name of the bundle.
        public let displayName: String

        /// The unique identifier of the bundle.
        public let identifier: String

//        /// The version of the bundle.
//        public var version: String?

        enum CodingKeys: String, CodingKey {
            case displayName = "bundleDisplayName"
            case identifier = "bundleIdentifier"
        }

        public init(displayName: String, identifier: String) {
            self.displayName = displayName
            self.identifier = identifier
        }
    }
}
