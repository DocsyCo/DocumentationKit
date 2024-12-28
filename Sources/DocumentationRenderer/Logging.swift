//
//  Logging.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import OSLog

extension Logger {
    @inline(__always)
    static func doccviewer(_ category: String) -> Logger {
        Logger(subsystem: "com.noahkamara.DocCViewer", category: category)
    }
}
