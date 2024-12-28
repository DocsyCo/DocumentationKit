//
//  WebKitCommunicationBridge.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

// The WebKitCommunicationBridge is only available on platforms that support WebKit.
import Foundation
@preconcurrency import SwiftDocC
import WebKit

/// Provides bi-directional communication with a documentation renderer via JavaScript calls in a web view.
public struct WebKitCommunicationBridge: CommunicationBridge {
    public var onReceiveMessage: ((Message) -> Void)? = nil

    /// Creates a communication bridge configured with the given controller to receive messages.
    /// - Parameter contentController: The controller that receives messages. Set to `nil` if  you need the communication bridge
    /// to ignore received messages.
    /// - Parameter onReceiveMessage: The handler that the communication bridge calls when it receives a message.
    /// Set to `nil` if you need the communication bridge to ignore received messages.
    @MainActor
    public init(
        contentController: WKUserContentController?,
        onReceiveMessage: ((Message) -> Void)? = nil
    ) {
        guard let onReceiveMessage else {
            return
        }

        self.onReceiveMessage = onReceiveMessage

        contentController?.add(
            ScriptMessageHandler(onReceiveMessageData: onReceiveMessageData),
            name: "bridge"
        )
    }

    /// Sends a message using the given handler using the JSON format.
    /// - Parameter message: The message to send.
    /// - Parameter evaluateJavaScript: A handler that the communication bridge uses to send the given message, encoded in JSON.
    /// - Throws: Throws a ``CommunicationBridgeError/unableToEncodeMessage(_:underlyingError:)`` if the communication bridge could not encode the given message to JSON.
    @MainActor
    public func send(
        _ message: Message,
        using webView: WKWebView
    ) throws {
        do {
            let encoder = JSONEncoder()
            let encodedMessage = try encoder.encode(message)
            let messageJSON = String(data: encodedMessage, encoding: .utf8)!
            let script = "window.bridge.receive(\(messageJSON))"
            webView.evaluateJavaScript(script)
        } catch {
            throw CommunicationBridgeError.unableToEncodeMessage(message, underlyingError: error)
        }
    }

    /// Called by the communication bridge when a message is received by a script message handler.
    ///
    /// Decodes the given WebKit script message as a ``Message``, and calls the ``onReceiveMessage`` handler.
    /// The communication bridge ignores unrecognized messages.
    /// - Parameter messageBody: The body of a `WKScriptMessage` provided by a `WKScriptMessageHandler`.
    func onReceiveMessageData(messageBody: Any) {
        // `WKScriptMessageHandler` transforms JavaScript objects to dictionaries.
        // Serialize the given dictionary to JSON data if possible, and decode the JSON data to a
        // message. If either of these steps fail, the communication-bridge ignores the message.
        guard let messageData = try? JSONSerialization.data(withJSONObject: messageBody),
              let message = try? JSONDecoder().decode(Message.self, from: messageData)
        else {
            return
        }

        onReceiveMessage?(message)
    }

    /// A WebKit script message handler for communication bridge messages.
    ///
    /// When receiving a message, the handler calls the given `onReceiveMessageData` handler with the message's body.
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        var onReceiveMessageData: (Any) -> Void

        init(onReceiveMessageData: @escaping (Any) -> Void) {
            self.onReceiveMessageData = onReceiveMessageData
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            onReceiveMessageData(message.body)
        }
    }
}
