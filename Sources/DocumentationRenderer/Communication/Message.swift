//
//  Message.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
@preconcurrency import SwiftDocC

/// A message to send or receive from a documentation renderer using a communication bridge.
public struct Message: Sendable {
    /// The type of the message.
    ///
    /// Clients can use the type of the message to determine which handler to invoke.
    public let type: MessageType

    /// The payload of the message.
    ///
    /// The data associated with a message is encodable, so a communication bridge can encode it when a client sends a
    /// message.
    public let data: AnyCodable?

    /// Creates a message given a type, a data payload, and an identifier.
    /// - Parameters:
    ///   - type: The type of the message.
    ///   - data: The data payload of the message.
    ///   - identifier: The identifier of the message.
    public init(type: MessageType, data: AnyCodable?) {
        self.type = type
        self.data = data
    }

    /// Creates a message that indicates a request for code-color preferences.
    ///
    /// This message is sent by renderer to request code-color preferences that renderers use when syntax highlighting code listings.
    /// The string value of this message type is `requestCodeColors`.
    public static func requestCodeColors() -> Message {
        .init(type: .requestCodeColors, data: nil)
    }
//
//    /// Creates a message that indicates what code colors a renderer uses to syntax highlight code listings.
//    ///
//    /// A "codeColors" message is sent as a response to a `requestCodeColors` message and provides code colors
//    /// preferences that a renderer uses when syntax highlighting code. The string value of this message type is `codeColors`.
//    ///
//    /// - Parameters:
//    ///   - codeColors: The code colors information that a renderer uses to syntax highlight code listings.
//    ///   - identifier: An identifier for the message.
//    public static func codeColors(_ codeColors: CodeColors) -> Message {
//        return .init(type: .codeColors, data: AnyCodable(codeColors))
//    }
}

public extension MessageType {
    /// A message that indicates what that a renderer wants to change the topic
    static let navigation = MessageType(rawValue: "navigation")
}
