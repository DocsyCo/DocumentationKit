//
//  DocumentationSchemeHandler.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SymbolKit
import UniformTypeIdentifiers
import DocumentationKit

private let bundleSpecificSubpaths: [String] = [
    "data",
    "downloads",
    "images",
    "videos",
    "index",
]

private let rendererSpecificSubpaths: [String] = [
    "documentation",
    "tutorials",
    "js",
    "css",
    "img",
]

#if canImport(WebKit)
import WebKit

public class DocumentationSchemeHandler: NSObject {
    public typealias FallbackResponseHandler = (URLRequest) -> (URLResponse, Data)?

    // The schema to support the documentation.
    public static let scheme = "doc"
    public static var fullScheme: String {
        "\(scheme)://"
    }

    @MainActor
    private var tasks: [URLRequest: Task<Void, Never>] = [:]

    /// Fallback handler is called if the response data is nil.
    public var fallbackHandler: FallbackResponseHandler?

    /// The `FileServer` instance for serving content.
    public let fileServer: FileServer

//    /// The default file provider to serve content from memory.
//    var memoryProvider = MemoryFileServerProvider()

    override public init() {
        self.fileServer = FileServer(baseURL: URL(string: DocumentationSchemeHandler.fullScheme)!)
    }
}

// MARK: Provider Registration

public extension DocumentationSchemeHandler {
    /// Registers a data provider that handles all requests to bundle-specific files like
    /// - topic json files at `/data`
    /// - bundle resource files at `/downloads`,  `/images`,  or `/videos`
    /// - index files at `/index`
    func registerBundleDataProvider(_ provider: FileServerProvider) {
        registerProvider(provider, subPaths: bundleSpecificSubpaths)
    }

    /// Registers a data provider that handles all requests to app source files like
    /// - html template files at `/documentation`, or `/tutorials`
    /// - renderer js source at  `/js`
    /// - renderer stylesheets at  `/css`
    /// - renderer assets at `/img`
    func registerRendererSourceProvider(_ provider: FileServerProvider) {
        registerProvider(provider, subPaths: rendererSpecificSubpaths)
    }

    /// Registers a data provider for a number of subpaths
    private func registerProvider(_ provider: FileServerProvider, subPaths: [String]) {
        for subPath in subPaths {
            fileServer.register(provider: provider, subPath: subPath)
        }
    }
}

import Foundation
import SymbolKit
import UniformTypeIdentifiers

// MARK: URLSchemeHandler

extension DocumentationSchemeHandler: WKURLSchemeHandler {
    public func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        tasks[urlSchemeTask.request] = Task {
            let (data, response) = await response(to: urlSchemeTask.request)
            await MainActor.run {
                guard tasks[urlSchemeTask.request] != nil else { return }
                urlSchemeTask.didReceive(response)
                if let data {
                    urlSchemeTask.didReceive(data)
                }
                urlSchemeTask.didFinish()
            }
        }
    }

    @MainActor
    public func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        tasks[urlSchemeTask.request]?.cancel()
        tasks[urlSchemeTask.request] = nil
    }

    /// Returns a tuple with a response and the given data.
    ///  - Parameter request: The request coming from a web client.
    /// - Returns: The response and data which are going to be served to the client.
    func response(to request: URLRequest) async -> (Data?, URLResponse) {
        guard let url = request.url else {
            let response = HTTPURLResponse.error(
                url: fileServer.baseURL,
                statusCode: 400,
                error: URLError(.badURL)
            )
            return (nil, response)
        }

        do {
            let data: Data
            let mimeType: String

            guard url.absoluteString.hasPrefix(fileServer.baseURL.absoluteString) else {
                let response = HTTPURLResponse.error(
                    url: fileServer.baseURL,
                    statusCode: 403,
                    error: URLError(.unsupportedURL)
                )
                return (nil, response)
            }

            // We need to make sure that the path extension is for an actual file and not a symbol name which is a false positive
            // like: "'...(_:)-6u3ic", that would be recognized as filename with the extension "(_:)-6u3ic". (rdar://71856738)
            if url.pathExtension.isAlphanumeric, !url.lastPathComponent.isSwiftEntity {
                data = try await fileServer.data(for: url)
                mimeType = Self.mimeType(for: url.pathExtension)
            } else { // request is for a path, we need to fake a redirect here
                if url.pathComponents.isEmpty {
                    print("Tried to load an invalid URL: \(url.absoluteString).\nFalling back to serve index.html.")
                }
                mimeType = "text/html"
                data = try await fileServer.data(for: fileServer.baseURL.appendingPathComponent("/index.html"))
            }

            let response = HTTPURLResponse.response(
                url: url,
                mimeType: mimeType,
                contentLength: data.count
            )

            return (data, response)
        } catch {
            let response = HTTPURLResponse.error(url: url, statusCode: 404, error: error)
            return (nil, response)
        }
    }

    /// Returns the MIME type based on file extension, best guess.
    static func mimeType(for ext: String) -> String {
        let defaultMimeType = "application/octet-stream"
        let mimeType = UTType(filenameExtension: ext)?.preferredMIMEType
        return mimeType ?? defaultMimeType
    }
}

private extension HTTPURLResponse {
    static func error(url: URL, statusCode: Int, error: (any Error)? = nil) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: [
                "X-Documentation-Provider-Error": "\(error.map { "\($0)" } ?? "-")",
            ]
        )!
    }

    static func response(url: URL, mimeType: String, contentLength: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            mimeType: mimeType,
            expectedContentLength: contentLength,
            textEncodingName: "utf-8"
        )
    }
}

fileprivate extension String {
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

/// Checks whether the given string is a known entity definition which might interfere with the rendering engine while dealing with URLs.
fileprivate func isKnownEntityDefinition(_ identifier: String) -> Bool {
    SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier(identifier)
}

#endif
