//
//  CommunicationBridge.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
@preconcurrency import SwiftDocC

/// A bridge that provides bi-directional communication with a documentation renderer.
///
/// Use a communication bridge to send and receive messages between an IDE and an embedded documentation renderer.
public protocol CommunicationBridge {
    /// Handler for sending messages.
    associatedtype SendHandler: Sendable

    /// A closure that the communication bridge calls when it receives a message.
    var onReceiveMessage: ((Message) -> Void)? { get set }

    /// Sends a message to the documentation renderer using the given handler.
    /// - Parameter message: The message to send to the renderer.
    /// - Parameter handler: A closure that performs the sending operation.
    /// - Throws: Throws a `CommunicationBridgeError.unableToEncodeMessage` if the given message could not be encoded.
    func send(_ message: Message, using handler: SendHandler) async throws
}

/// An error that occurs when using a communication bridge.
public enum CommunicationBridgeError: Error {
    /// An indication that a message could not be encoded when using a communication bridge.
    case unableToEncodeMessage(_ message: Message, underlyingError: Error)
}
