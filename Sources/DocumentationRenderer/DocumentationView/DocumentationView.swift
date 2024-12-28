//
//  DocumentationView.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import DocumentationKit
import Foundation
import WebKit

public class WKDocumentationView: WKWebView {
    private let schemaHandler: DocumentationSchemeHandler
    private var coordinator: DocumentationView.Coordinator

    public init(coordinator: DocumentationView.Coordinator) {
        self.coordinator = coordinator

        let config = WKWebViewConfiguration()

        // Handle Documentation Links
        let schemaHandler = DocumentationSchemeHandler()
        schemaHandler.fileServer.register(provider: coordinator.viewer.provider)
        config.setURLSchemeHandler(schemaHandler, forURLScheme: "doc")
        self.schemaHandler = schemaHandler

        // Configure controller for Communication
        let contentController = WKUserContentController()
        config.userContentController = contentController

        super.init(frame: .zero, configuration: config)

        // Configure Communication Bridge
        let bridge = WebKitCommunicationBridge(
            contentController: contentController,
            onReceiveMessage: { message in
                switch message.type {
                case .rendered:
                    if let url = self.url, let docURI = DocumentationURI(url: url) {
                        coordinator.didNavigate(to: docURI)
                    }
                default:
                    print("Unhandled Event", message.type)
                }
            }
        )

        // Register View & Bridge in Coordinator
        coordinator.register(view: self, bridge: bridge)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct DocumentationView {
    public typealias ViewType = WKDocumentationView

    let viewer: DocumentationRenderer

    public init(_ viewer: DocumentationRenderer) {
        self.viewer = viewer
    }

    @MainActor
    public func makeCoordinator() -> Coordinator {
        Coordinator(viewer: viewer)
    }

    @MainActor
    func makeView(context: Context) -> ViewType {
        let view = WKDocumentationView(coordinator: context.coordinator)
        view.isInspectable = true
        return view
    }

    @MainActor
    func updateView(_ nsView: ViewType, context: Context) {}
}

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)

// MARK: View (macOS)

extension DocumentationView: NSViewRepresentable {
    public func makeNSView(context: Context) -> ViewType {
        makeView(context: context)
    }

    public func updateNSView(_ nsView: ViewType, context: Context) {
        updateView(nsView, context: context)
    }
}
#else

// MARK: View (iOS)

extension DocumentationView: UIViewRepresentable {
    public func makeUIView(context: Context) -> ViewType {
        makeView(context: context)
    }

    public func updateUIView(_ uiView: ViewType, context: Context) {
        updateView(uiView, context: context)
    }
}
#endif
#endif
