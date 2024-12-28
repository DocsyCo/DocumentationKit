//
//  DocumentationViewContext.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import DocumentationKit
import Foundation
import OSLog
import WebKit

protocol DocumentationViewContext {
    @MainActor func navigate(to url: DocumentationURI)
    @MainActor func goForward()
    @MainActor func goBack()
}

public extension DocumentationRenderer {
    @MainActor
    @Observable
    class Navigation {
        private var context: DocumentationViewContext?

        public private(set) var canGoBack: Bool = false
        public private(set) var canGoForward: Bool = false

        public func goBack() {
            context?.goBack()
        }

        public func goForward() {
            context?.goForward()
        }

        func register(context: DocumentationViewContext) {
            self.context = context
        }
    }
}

public extension DocumentationView {
    class Coordinator: NSObject, DocumentationViewContext {
        let logger = Logger.doccviewer("Coordinator")
        private(set) var viewer: DocumentationRenderer
        private var bridge: WebKitCommunicationBridge?
        private var view: WKWebView?

        func register(view: WKWebView, bridge: WebKitCommunicationBridge) {
            logger.debug("registering on view. using \(type(of: bridge)) as bridge")
            self.view = view
            self.bridge = bridge
        }

        init(viewer: DocumentationRenderer) {
            self.viewer = viewer
            super.init()
            viewer.context = self
        }

        @MainActor
        public func navigate(to url: DocumentationURI) {
            guard let bridge, let view else {
                logger.error("attempted navigation ")
                return
            }

            guard
                let currentUrl = view.url,
                let currentTopic = DocumentationURI(url: currentUrl),
                currentTopic.bundleIdentifier == url.bundleIdentifier
            else {
                logger.debug("bundle crossing requires full reload \(url.url)")
                view.load(.init(url: url.url))
                return
            }

            logger.debug("attempting dynamic navigation to \(url.url)")
            do {
                try bridge
                    .send(.init(type: .navigation, data: .init(url.path)), using: view)
            } catch {
                logger.error("failed to send navigation request: \(error)")
                logger.debug("falling back to full-page load \(url.url)")
                view.load(.init(url: url.url))
            }
        }

        @MainActor
        public func didNavigate(to url: DocumentationURI) {
            viewer.url = url
            viewer.canGoBack = view?.canGoBack ?? false
            viewer.canGoForward = view?.canGoForward ?? false
        }

        @MainActor
        public func goForward() {
            view?.goForward()
        }

        @MainActor
        public func goBack() {
            view?.goBack()
        }
    }
}

extension DocumentationView.Coordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .cancel
        }

        guard url.scheme == "doc" else {
            viewer.openUrlAction(url)
            return .cancel
        }

        return .allow
    }

//    func webView(
//        _ webView: WKWebView,
//        decidePolicyFor navigationAction: WKNavigationAction,
//        preferences: WKWebpagePreferences,
//        decisionHandler: @escaping @MainActor (
//            WKNavigationActionPolicy,
//            WKWebpagePreferences
//        ) -> Void
//    ) {
//
//    }
}
