//
//  FileServerProvider.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public enum FileServerProviderError: Error {
    case notFound
}

/// A protocol used for serving content to a `FileServer`.
/// > This abstraction lets a `FileServer` provide content from multiple types of sources at the same time.
public protocol FileServerProvider {
    typealias ProviderError = FileServerProviderError

    /// Retrieve the data linked to a given path based on the `baseURL`.
    ///
    /// - parameter path: The path.
    /// - returns: The data matching the url, if possible.
    func data(for path: String) async throws -> Data
}

// MARK: MemoryFileServerProvider
public class InMemoryFileServerProvider: FileServerProvider {
    /// Files to serve based on relative path.
    private var files: ExclusiveMutating<[String: Data]> = .init([:])

    public init() {}

    /// Add a file to the file server.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - data: The data for that file.
    /// - Returns: `true` if the file was added successfully.
    @discardableResult
    public func addFile(path: String, data: Data) async -> Bool {
        guard !path.isEmpty else { return false }
        var trimmed = path.trimmingCharacters(in: slashCharSet)
#if os(Windows)
        trimmed = trimmed.replacingOccurrences(of: #"/"#, with: #"\"#)
#endif

        await files.mutate { files in
            files[trimmed] = data
        }

        return true
    }

    /// Retrieve the data that the server serves for the given path.
    ///
    /// - Parameter path: The path to a file served by the server.
    /// - Returns: The data for that file, if server by the server. Otherwise, `nil`.
    public func data(for path: String) async throws -> Data {
        var trimmed = path.trimmingCharacters(in: slashCharSet)
#if os(Windows)
        trimmed = trimmed.replacingOccurrences(of: #"/"#, with: #"\"#)
#endif

        guard let value = await files.value[trimmed] else {
            throw ProviderError.notFound
        }
        
        return value
    }

    /// Adds files from the `source` directory to the `destination` directory in the file server.
    ///
    /// - Parameters:
    ///   - source: The source directory to add files from.
    ///   - destination: he destination directory in the file server to add the files to.
    ///   - recursive: Whether or not to recursively add files from the source directory.
    public func addFiles(
        inFolder source: String,
        inSubPath destination: String = "",
        recursive: Bool = true
    ) async {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: source, isDirectory: &isDirectory) else { return }
        guard isDirectory.boolValue else { return }

        let trimmedSubPath = destination.trimmingCharacters(in: slashCharSet)
        let enumerator = FileManager.default.enumerator(atPath: source)!

        for file in enumerator {
            guard let file = file as? String else { fatalError("Enumerator returned an unexpected type.") }
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: source).appendingPathComponent(file)) else { continue }
            if recursive == false, file.contains("/") { continue } // skip if subfolder and recursive is disabled

            await addFile(path: "/\(trimmedSubPath)/\(file)", data: data)
        }
    }

    /// Remove all files served by the server.
    public func removeAllFiles() async {
        await files.set(to: [:])
    }

    /// Removes all files served by the server matching a given subpath.
    ///
    /// - Parameter directory: The path to a directory to remove
    public func removeAllFiles(in directory: String) async {
        var trimmed = directory.trimmingCharacters(in: slashCharSet)
#if os(Windows)
        trimmed = trimmed.appending(#"\"#)
#else
        trimmed = trimmed.appending(#"/"#)
#endif
        for key in await files.value.keys where key.hasPrefix(trimmed) {
            await files.mutate {
                $0.removeValue(forKey: key)
            }
        }
    }
}
