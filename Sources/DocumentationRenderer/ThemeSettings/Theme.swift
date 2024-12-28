//
//  Theme.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct ThemeSettings: Encodable {
    public var theme: Theme = .init(
        aside: .init(),
        badge: .init(),
        borderRadius: nil,
        button: .init(),
        code: .init(),
        color: .init([:])
    )

    public var features: Features = .init(
        docs: .init(quickNavigation: nil, onThisPageNavigator: nil, i18n: nil)
    )

    public var typography: Typography = .init(htmlFont: nil, htmlFontMono: nil)

    public init(theme: Theme? = nil, features: Features? = nil) {
        if let theme {
            self.theme = theme
        }
        if let features {
            self.features = features
        }
    }
}

// MARK: Features

public extension ThemeSettings {
    /// Flags for enabling or disabling features of the website.
    struct Features: Encodable {
        public var docs: Docs

        public init(docs: Docs? = nil) {
            self.docs = docs ?? Docs()
        }
    }
}

public extension ThemeSettings.Features.EnableFeature? {
    mutating func enable() {
        self = .init(enable: true)
    }
}

public extension ThemeSettings.Features.DisableFeature? {
    mutating func disable() {
        self = .init(disable: true)
    }
}

public extension ThemeSettings.Features {
    /// flags for enabling or disabling `/documentation` page features.
    struct Docs: Encodable {
        public var quickNavigation: EnableFeature? = nil
        public var onThisPageNavigator: DisableFeature? = nil
        public var i18n: EnableFeature? = nil

        public init(
            quickNavigation: EnableFeature? = nil,
            onThisPageNavigator: DisableFeature? = nil,
            i18n: EnableFeature? = nil
        ) {
            self.quickNavigation = quickNavigation
            self.onThisPageNavigator = onThisPageNavigator
            self.i18n = i18n
        }
    }

    /// Enables a feature if `enable` is `true`.
    struct EnableFeature: Encodable {
        /// Determines whether the feature is enabled.
        public var enable: Bool

        public init(enable: Bool) {
            self.enable = enable
        }
    }

    /// Disables a feature if `disable` is `true`.
    struct DisableFeature: Encodable {
        /// Determines whether the feature is disabled.
        public var disable: Bool

        public init(disable: Bool) {
            self.disable = disable
        }
    }
}

// MARK: Theme

public extension ThemeSettings {
    /// Settings concerning the visual appearance of the DoccViewer and the styling of its components.
    struct Theme: Encodable {
        /// Settings concerning "aside" elements.
        public var aside: BorderAttributes

        /// Settings concerning "badge" elements.
        public var badge: BorderAttributes

        /// The CSS border-radius value used globally for elements like code listings and asides.
        public var borderRadius: String?

        /// Settings concerning "button" elements.
        public var button: BorderAttributes

        /// Settings concerning "code listing" elements.
        public var code: Code

        public var color: ColorScheme

        public init(
            aside: BorderAttributes = BorderAttributes(),
            badge: BorderAttributes = BorderAttributes(),
            borderRadius: String? = nil,
            button: BorderAttributes = BorderAttributes(),
            code: Code = Code(),
            color: ColorScheme = ColorScheme([:])
        ) {
            self.aside = aside
            self.badge = badge
            self.borderRadius = borderRadius
            self.button = button
            self.code = code
            self.color = color
        }
    }
}

// MARK: Element Settings

public extension ThemeSettings.Theme {
    /// Represents attributes for border styling.
    struct BorderAttributes: Encodable {
        /// A CSS value for `border-radius`.
        public var borderRadius: String? = nil

        /// A CSS value for `border-style`.
        public var borderStyle: String? = nil

        /// A CSS value for `border-width`.
        public var borderWidth: String? = nil

        enum CodingKeys: String, CodingKey {
            case borderRadius = "border-radius"
            case borderStyle = "border-style"
            case borderWidth = "border-width"
        }

        public init(
            borderRadius: String? = nil,
            borderStyle: String? = nil,
            borderWidth: String? = nil
        ) {
            self.borderRadius = borderRadius
            self.borderStyle = borderStyle
            self.borderWidth = borderWidth
        }

        fileprivate func hasValues() -> Bool {
            [borderRadius, borderStyle, borderWidth].contains(where: { $0 != nil })
        }
    }

    /// Settings concerning "code listing" elements.
    struct Code: Encodable {
        /// The number of spaces used to indent multi-parameter Swift symbol declarations.
        public var indentationWidth: Int? = nil

        /// A CSS value for `border-radius`.
        public var borderRadius: String? = nil

        /// A CSS value for `border-style`.
        public var borderStyle: String? = nil

        /// A CSS value for `border-width`.
        public var borderWidth: String? = nil

        enum CodingKeys: String, CodingKey {
            case indentationWidth
            case borderRadius = "border-radius"
            case borderStyle = "border-style"
            case borderWidth = "border-width"
        }

        public init(
            indentationWidth: Int? = nil,
            borderRadius: String? = nil,
            borderStyle: String? = nil,
            borderWidth: String? = nil
        ) {
            self.indentationWidth = indentationWidth
            self.borderRadius = borderRadius
            self.borderStyle = borderStyle
            self.borderWidth = borderWidth
        }
    }

    /// An absolute URL or relative path.
    typealias URL = String

    /// A definition for a device frame
    struct DeviceFrameAttributes: Encodable {
        /// The top position of the screen within the frame.
        public var screenTop: Double? = nil

        /// The width of the screen.
        public var screenWidth: Double? = nil

        /// The height of the screen.
        public var screenHeight: Double? = nil

        /// The left position of the screen within the frame.
        public var screenLeft: Double? = nil

        /// The width of the entire frame.
        public var frameWidth: Double? = nil

        /// The height of the entire frame.
        public var frameHeight: Double? = nil

        /// The URL for the light mode frame image.
        public var lightUrl: URL? = nil

        /// The URL for the dark mode frame image.
        public var darkUrl: URL? = nil

        public init(
            screenTop: Double? = nil,
            screenWidth: Double? = nil,
            screenHeight: Double? = nil,
            screenLeft: Double? = nil,
            frameWidth: Double? = nil,
            frameHeight: Double? = nil,
            lightUrl: URL? = nil,
            darkUrl: URL? = nil
        ) {
            self.screenTop = screenTop
            self.screenWidth = screenWidth
            self.screenHeight = screenHeight
            self.screenLeft = screenLeft
            self.frameWidth = frameWidth
            self.frameHeight = frameHeight
            self.lightUrl = lightUrl
            self.darkUrl = darkUrl
        }
    }
}

// MARK: ColorScheme

public extension ThemeSettings.Theme {
    /// An object where each key represents the name of a color variable referenced in the renderer.
    /// A CSS property in the form `--color-[key]` will either be created or overwritten with the value associated with it.
    @dynamicMemberLookup
    struct ColorScheme: Encodable {
        public typealias ColorMap = [String: Color]
        private var values: ColorMap

        public var keys: ColorMap.Keys { values.keys }

        public subscript(_ key: String) -> Color? {
            values[key]
        }

        public subscript(dynamicMember keyPath: KeyPath<Colors, String>) -> Color? {
            get { self[Colors[keyPath]] }
            set {
                let key: String = Colors[keyPath]

                if let newValue {
                    self[key] = newValue
                } else {
                    _ = values.removeValue(forKey: key)
                }
            }
        }

        @_disfavoredOverload
        public subscript(_ key: String) -> Color {
            get {
                values[key]!
            }
            set {
                values[key] = newValue
            }
        }

        public init(_ values: [String: Color]) {
            self.values = values
        }

        public func encode(to encoder: any Encoder) throws {
            try values.encode(to: encoder)
        }
    }

    /// Represents a color value that can be either a CSS color string or a light/dark color pair.
    enum Color: Encodable {
        /// Any valid CSS color value
        case single(Value)

        /// A pair of light and dark CSS color values.
        case pair(light: Value, dark: Value)

        static func single(variable: KeyPath<Colors, String>) -> Color {
            .single(.init(rawValue: Colors[variable]))
        }

        static func single(variable: String) -> Color {
            assert(variable.prefix(2) == "==")
            return .single(.init(rawValue: "var(\(variable))"))
        }

        static func pair(light: KeyPath<Colors, String>, dark: KeyPath<Colors, String>) -> Color {
            .pair(light: .init(rawValue: Colors[light]),
                  dark: .init(rawValue: Colors[dark]))
        }

        public struct Value: RawRepresentable, ExpressibleByStringLiteral, Encodable {
            public let rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }

            public init(stringLiteral value: String) {
                self.init(rawValue: value)
            }

            public func encode(to encoder: any Encoder) throws {
                try rawValue.encode(to: encoder)
            }

            public static func variable(_ variable: StringLiteralType) -> Self {
                assert(variable.prefix(2) == "--")
                return self.init(rawValue: "var(\(variable))")
            }
        }

        enum PairCodingKeys: CodingKey {
            case light
            case dark
        }

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .single(let value):
                try value.encode(to: encoder)
            case .pair(let light, let dark):
                var container = encoder.container(keyedBy: PairCodingKeys.self)
                try container.encode(light, forKey: .light)
                try container.encode(dark, forKey: .dark)
            }
        }
    }
}

extension ThemeSettings.Theme.Color.Value {
    init(color: SwiftUI.Color, in environment: EnvironmentValues) {
        self.init(rawValue: "#" + color.toHex())
    }
}

import SwiftUI

extension SwiftUI.Color {
    func toHex() -> String {
#if os(macOS)
        let cgColor = NSColor(self).cgColor
#else
        let cgColor = UIColor(self).cgColor
#endif

        guard let components = cgColor.components, components.count >= 3 else {
            return "000000"
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

#if DEBUG
extension ThemeSettings: CustomStringConvertible {
    public var description: String {
        do {
            let data = try JSONEncoder().encode(self)

            return String(
                data: data, // try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .fragmentsAllowed]),
                encoding: .utf8
            )!
        } catch {
            print(error)
            return error.localizedDescription
        }
    }
}
#endif
