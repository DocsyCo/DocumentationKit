//
//  ColorVars.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension ThemeSettings.Theme {
    struct Colors: Sendable {
        public static let shared = Colors()

        fileprivate init() {}

        static subscript(_ keyPath: KeyPath<Colors, String>) -> String {
            shared[keyPath: keyPath]
        }

        static subscript(_ keyPath: KeyPath<Colors, String>) -> Color.Value {
            Color.Value(rawValue: shared[keyPath: keyPath])
        }

        public let typeIconBlue = "type-icon-blue"
        public let typeIconGreen = "type-icon-green"
        public let typeIconOrange = "type-icon-orange"
        public let typeIconPink = "type-icon-pink"
        public let typeIconPurple = "type-icon-purple"
        public let typeIconSky = "type-icon-sky"
        public let typeIconTeal = "type-icon-teal"

        public let notFoundInputBackground = "not-found-input-background"
        public let notFoundInputBorder = "not-found-input-border"

        public let figureLightBlue = "figureLight-blue"

        public let grid = "grid"

        public let highlightGreen = "highlight-green"
        public let highlightRed = "highlight-red"

        public var articleBackground: String { "article-background" }
        public var articleBodyBackground: String { "article-body-background" }
        public var asideDeprecated: String { "aside-deprecated" }
        public var asideDeprecatedBackground: String { "aside-deprecated-background" }
        public var asideDeprecatedBorder: String { "aside-deprecated-border" }
        public var asideExperiment: String { "aside-experiment" }
        public var asideExperimentBackground: String { "aside-experiment-background" }
        public var asideExperimentBorder: String { "aside-experiment-border" }
        public var asideImportant: String { "aside-important" }
        public var asideImportantBackground: String { "aside-important-background" }
        public var asideImportantBorder: String { "aside-important-border" }
        public var asideNote: String { "aside-note" }
        public var asideNoteBackground: String { "aside-note-background" }
        public var asideNoteBorder: String { "aside-note-border" }
        public var asideTip: String { "aside-tip" }
        public var asideTipBackground: String { "aside-tip-background" }
        public var asideTipBorder: String { "aside-tip-border" }
        public var asideWarning: String { "aside-warning" }
        public var asideWarningBackground: String { "aside-warning-background" }
        public var asideWarningBorder: String { "aside-warning-border" }
        public var badgeBeta: String { "badge-beta" }
        public var badgeDarkBeta: String { "badge-dark-beta" }
        public var badgeDarkDefault: String { "badge-dark-default" }
        public var badgeDarkDeprecated: String { "badge-dark-deprecated" }
        public var badgeDefault: String { "badge-default" }
        public var badgeDeprecated: String { "badge-deprecated" }
        public var buttonBackground: String { "button-background" }
        public var buttonBackgroundActive: String { "button-background-active" }
        public var buttonBackgroundHover: String { "button-background-hover" }
        public var buttonBorder: String { "button-border" }
        public var buttonText: String { "button-text" }
        public var callToActionBackground: String { "call-to-action-background" }
        public var changesAdded: String { "changes-added" }
        public var changesAddedHover: String { "changes-added-hover" }
        public var changesDeprecated: String { "changes-deprecated" }
        public var changesDeprecatedHover: String { "changes-deprecated-hover" }
        public var changesModified: String { "changes-modified" }
        public var changesModifiedHover: String { "changes-modified-hover" }
        public var changesModifiedPreviousBackground: String { "changes-modified-previous-background" }
        public var codeBackground: String { "code-background" }
        public var codeCollapsibleBackground: String { "code-collapsible-background" }
        public var codeCollapsibleText: String { "code-collapsible-text" }
        public var codeLineHighlight: String { "code-line-highlight" }
        public var codeLineHighlightBorder: String { "code-line-highlight-border" }
        public var codePlain: String { "code-plain" }
        public var documentationIntroAccent: String { "documentation-intro-accent" }
        public var documentationIntroEyebrow: String { "documentation-intro-eyebrow" }
        public var documentationIntroFigure: String { "documentation-intro-figure" }
        public var documentationIntroFill: String { "documentation-intro-fill" }
        public var documentationIntroTitle: String { "documentation-intro-title" }
        public var dropdownBackground: String { "dropdown-background" }
        public var dropdownBorder: String { "dropdown-border" }
        public var dropdownDarkBackground: String { "dropdown-dark-background" }
        public var dropdownDarkBorder: String { "dropdown-dark-border" }
        public var dropdownDarkOptionText: String { "dropdown-dark-option-text" }
        public var dropdownDarkText: String { "dropdown-dark-text" }
        public var dropdownOptionText: String { "dropdown-option-text" }
        public var dropdownText: String { "dropdown-text" }
        public var eyebrow: String { "eyebrow" }

        public var figureBlue: String { "figure-blue" }
        public var figureGray: String { "figure-gray" }
        public var figureGraySecondary: String { "figure-gray-secondary" }
        public var figureGraySecondaryAlt: String { "figure-gray-secondary-alt" }
        public var figureGrayTertiary: String { "figure-gray-tertiary" }
        public var figureGreen: String { "figure-green" }
        public var figureLightGray: String { "figure-light-gray" }

        public var figureOrange: String { "figure-orange" }
        public var figureRed: String { "figure-red" }
        public let figurePink = "figure-pink"
        public let figurePurple = "figure-purple"
        public let figureTeal = "figure-teal"
        public let figureYellow = "figure-yellow"

        public var fill: String { "fill" }
        public var fillSecondary: String { "fill-secondary" }
        public var fillTertiary: String { "fill-tertiary" }
        public var fillQuaternary: String { "fill-quaternary" }

        public var fillBlue: String { "fill-blue" }
        public var fillBlueSecondary: String { "fill-blue-secondary" }
        public var fillLightBlueSecondary: String { "fill-light-blue-secondary" }

        public var fillGray: String { "fill-gray" }
        public var fillGraySecondary: String { "fill-gray-secondary" }
        public var fillGrayTertiary: String { "fill-gray-tertiary" }
        public var fillGrayQuaternary: String { "fill-gray-quaternary" }
        public let fillLightGraySecondary = "fillLight-gray-secondary"

        public var fillGreenSecondary: String { "fill-green-secondary" }
        public let fillPurpleSecondary = "fill-purple-secondary"
        public let fillTealSecondary = "fill-teal-secondary"
        public let fillYellowSecondary = "fill-yellow-secondary"
        public var fillOrangeSecondary: String { "fill-orange-secondary" }
        public var fillRedSecondary: String { "fill-red-secondary" }

        public var focusBorderColor: String { "focus-border-color" }
        public var focusColor: String { "focus-color" }
        public var formError: String { "form-error" }
        public var formErrorBackground: String { "form-error-background" }
        public var formValid: String { "form-valid" }
        public var formValidBackground: String { "form-valid-background" }
        public var genericModalBackground: String { "generic-modal-background" }
        public var headerText: String { "header-text" }
        public var heroEyebrow: String { "hero-eyebrow" }
        public var link: String { "link" }
        public var loadingPlaceholderBackground: String { "loading-placeholder-background" }
        public var navColor: String { "nav-color" }
        public var navCurrentLink: String { "nav-current-link" }
        public var navDarkBorderTopColor: String { "nav-dark-border-top-color" }
        public var navDarkColor: String { "nav-dark-color" }
        public var navDarkCurrentLink: String { "nav-dark-current-link" }
        public var navDarkExpanded: String { "nav-dark-expanded" }
        public var navDarkHierarchyCollapseBackground: String { "nav-dark-hierarchy-collapse-background" }
        public var navDarkHierarchyCollapseBorders: String { "nav-dark-hierarchy-collapse-borders" }
        public var navDarkHierarchyItemBorders: String { "nav-dark-hierarchy-item-borders" }
        public var navDarkKeyline: String { "nav-dark-keyline" }
        public var navDarkLinkColor: String { "nav-dark-link-color" }
        public var navDarkLinkColorHover: String { "nav-dark-link-color-hover" }
        public var navDarkOutlines: String { "nav-dark-outlines" }
        public var navDarkRootSubhead: String { "nav-dark-root-subhead" }
        public var navDarkRule: String { "nav-dark-rule" }
        public var navDarkSolidBackground: String { "nav-dark-solid-background" }
        public var navDarkStickingExpandedKeyline: String { "nav-dark-sticking-expanded-keyline" }
        public var navDarkStuck: String { "nav-dark-stuck" }
        public var navDarkUiblurExpanded: String { "nav-dark-uiblur-expanded" }
        public var navDarkUiblurStuck: String { "nav-dark-uiblur-stuck" }
        public var navExpanded: String { "nav-expanded" }
        public var navHierarchyCollapseBackground: String { "nav-hierarchy-collapse-background" }
        public var navHierarchyCollapseBorders: String { "nav-hierarchy-collapse-borders" }
        public var navHierarchyItemBorders: String { "nav-hierarchy-item-borders" }
        public var navKeyline: String { "nav-keyline" }
        public var navLinkColor: String { "nav-link-color" }
        public var navLinkColorHover: String { "nav-link-color-hover" }
        public var navOutlines: String { "nav-outlines" }
        public var navRootSubhead: String { "nav-root-subhead" }
        public var navRootTitle: String { "nav-root-title" }
        public var navRule: String { "nav-rule" }
        public var navSolidBackground: String { "nav-solid-background" }
        public var navStickingExpandedKeyline: String { "nav-sticking-expanded-keyline" }
        public var navStuck: String { "nav-stuck" }
        public var navUiblurExpanded: String { "nav-uiblur-expanded" }
        public var navUiblurStuck: String { "nav-uiblur-stuck" }
        public var navigatorItemHover: String { "navigator-item-hover" }
        public var runtimePreviewBackground: String { "runtime-preview-background" }
        public var runtimePreviewDisabledText: String { "runtime-preview-disabled-text" }
        public var runtimePreviewText: String { "runtime-preview-text" }
        public var secondaryLabel: String { "secondary-label" }

        public let standardBlue: String = "standard-blue"
        public let standardGray: String = "standard-gray"
        public let standardGreen: String = "standard-green"
        public let standardOrange: String = "standard-orange"
        public let standardPurple: String = "standard-purple"
        public let standardRed: String = "standard-red"
        public let standardYellow: String = "standard-yellow"

        public var standardBlueDocumentationIntroFill: String { "standard-blue-documentation-intro-fill" }
        public var standardGrayDocumentationIntroFill: String { "standard-gray-documentation-intro-fill" }
        public var standardGreenDocumentationIntroFill: String { "standard-green-documentation-intro-fill" }
        public var standardOrangeDocumentationIntroFill: String { "standard-orange-documentation-intro-fill" }
        public var standardPurpleDocumentationIntroFill: String { "standard-purple-documentation-intro-fill" }
        public var standardRedDocumentationIntroFill: String { "standard-red-documentation-intro-fill" }
        public var standardYellowDocumentationIntroFill: String { "standard-yellow-documentation-intro-fill" }
        public var stepBackground: String { "step-background" }
        public var stepCaption: String { "step-caption" }
        public var stepFocused: String { "step-focused" }
        public var stepText: String { "step-text" }
        public var svgIcon: String { "svg-icon" }
        public var syntaxAttributes: String { "syntax-attributes" }
        public var syntaxCharacters: String { "syntax-characters" }
        public var syntaxComments: String { "syntax-comments" }
        public var syntaxDocumentationMarkup: String { "syntax-documentation-markup" }
        public var syntaxDocumentationMarkupKeywords: String { "syntax-documentation-markup-keywords" }
        public var syntaxHeading: String { "syntax-heading" }
        public var syntaxKeywords: String { "syntax-keywords" }
        public var syntaxMarks: String { "syntax-marks" }
        public var syntaxNumbers: String { "syntax-numbers" }
        public var syntaxOtherClassNames: String { "syntax-other-class-names" }
        public var syntaxOtherConstants: String { "syntax-other-constants" }
        public var syntaxOtherDeclarations: String { "syntax-other-declarations" }
        public var syntaxOtherFunctionAndMethodNames: String { "syntax-other-function-and-method-names" }
        public var syntaxOtherInstanceVariablesAndGlobals: String { "syntax-other-instance-public variables-and-globals" }
        public var syntaxOtherPreprocessorMacros: String { "syntax-other-preprocessor-macros" }
        public var syntaxOtherTypeNames: String { "syntax-other-type-names" }
        public var syntaxParamInternalName: String { "syntax-param-internal-name" }
        public var syntaxPlainText: String { "syntax-plain-text" }
        public var syntaxPreprocessorStatements: String { "syntax-preprocessor-statements" }
        public var syntaxProjectClassNames: String { "syntax-project-class-names" }
        public var syntaxProjectConstants: String { "syntax-project-constants" }
        public var syntaxProjectFunctionAndMethodNames: String { "syntax-project-function-and-method-names" }
        public var syntaxProjectInstanceVariablesAndGlobals: String { "syntax-project-instance-public variables-and-globals" }
        public var syntaxProjectPreprocessorMacros: String { "syntax-project-preprocessor-macros" }
        public var syntaxProjectTypeNames: String { "syntax-project-type-names" }
        public var syntaxStrings: String { "syntax-strings" }
        public var syntaxTypeDeclarations: String { "syntax-type-declarations" }
        public var syntaxUrls: String { "syntax-urls" }
        public var tabnavItemBorderColor: String { "tabnav-item-border-color" }
        public var text: String { "text" }
        public var textBackground: String { "text-background" }
        public var tutorialAssessmentsBackground: String { "tutorial-assessments-background" }
        public var tutorialBackground: String { "tutorial-background" }
        public var tutorialHeroBackground: String { "tutorial-hero-background" }
        public var tutorialHeroText: String { "tutorial-hero-text" }
        public var tutorialNavbarDropdownBackground: String { "tutorial-navbar-dropdown-background" }
        public var tutorialNavbarDropdownBorder: String { "tutorial-navbar-dropdown-border" }
        public var tutorialQuizBorderActive: String { "tutorial-quiz-border-active" }
        public var tutorialsOverviewBackground: String { "tutorials-overview-background" }
        public var tutorialsOverviewContent: String { "tutorials-overview-content" }
        public var tutorialsOverviewContentAlt: String { "tutorials-overview-content-alt" }
        public var tutorialsOverviewEyebrow: String { "tutorials-overview-eyebrow" }
        public var tutorialsOverviewFill: String { "tutorials-overview-fill" }
        public var tutorialsOverviewFillSecondary: String { "tutorials-overview-fill-secondary" }
        public var tutorialsOverviewHeaderText: String { "tutorials-overview-header-text" }
        public var tutorialsOverviewIcon: String { "tutorials-overview-icon" }
        public var tutorialsOverviewLink: String { "tutorials-overview-link" }
        public var tutorialsOverviewNavigationLink: String { "tutorials-overview-navigation-link" }
        public var tutorialsOverviewNavigationLinkActive: String { "tutorials-overview-navigation-link-active" }
        public var tutorialsOverviewNavigationLinkHover: String { "tutorials-overview-navigation-link-hover" }
        public var tutorialsTeal: String { "tutorials-teal" }
    }
}
