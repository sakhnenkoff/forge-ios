import SwiftUI

/// Defines a single text style with all its attributes
public struct TextStyle: Sendable {
    public let size: CGFloat
    public let weight: Font.Weight
    public let design: Font.Design
    public let customFontName: String?

    public init(
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design = .default,
        customFont: String? = nil
    ) {
        self.size = size
        self.weight = weight
        self.design = design
        self.customFontName = customFont
    }

    public var font: Font {
        if let customFontName {
            return .custom(customFontName, size: size).weight(weight)
        }

        return .system(size: size, weight: weight, design: design)
    }
}

/// Typography scale with all text styles
public struct TypographyScale: Sendable {

    // MARK: - Title Styles

    public let titleLarge: TextStyle
    public let titleMedium: TextStyle
    public let titleSmall: TextStyle

    // MARK: - Headline Styles

    public let headlineLarge: TextStyle
    public let headlineMedium: TextStyle
    public let headlineSmall: TextStyle

    // MARK: - Body Styles

    public let bodyLarge: TextStyle
    public let bodyMedium: TextStyle
    public let bodySmall: TextStyle

    // MARK: - Caption Styles

    public let captionLarge: TextStyle
    public let captionSmall: TextStyle

    // MARK: - Button Styles

    public let buttonLarge: TextStyle
    public let buttonMedium: TextStyle
    public let buttonSmall: TextStyle

    // MARK: - Init

    public init(
        titleLarge: TextStyle,
        titleMedium: TextStyle,
        titleSmall: TextStyle,
        headlineLarge: TextStyle,
        headlineMedium: TextStyle,
        headlineSmall: TextStyle,
        bodyLarge: TextStyle,
        bodyMedium: TextStyle,
        bodySmall: TextStyle,
        captionLarge: TextStyle,
        captionSmall: TextStyle,
        buttonLarge: TextStyle,
        buttonMedium: TextStyle,
        buttonSmall: TextStyle
    ) {
        self.titleLarge = titleLarge
        self.titleMedium = titleMedium
        self.titleSmall = titleSmall
        self.headlineLarge = headlineLarge
        self.headlineMedium = headlineMedium
        self.headlineSmall = headlineSmall
        self.bodyLarge = bodyLarge
        self.bodyMedium = bodyMedium
        self.bodySmall = bodySmall
        self.captionLarge = captionLarge
        self.captionSmall = captionSmall
        self.buttonLarge = buttonLarge
        self.buttonMedium = buttonMedium
        self.buttonSmall = buttonSmall
    }
}

#if canImport(UIKit)
import UIKit

extension TextStyle {
    func uiFont(weightOverride: UIFont.Weight? = nil) -> UIFont {
        let effectiveWeight = weightOverride ?? weight.uiKitWeight

        if let customFontName, let customFont = UIFont(name: customFontName, size: size) {
            return customFont.withWeight(effectiveWeight)
        }

        let descriptor = UIFont.systemFont(ofSize: size, weight: effectiveWeight).fontDescriptor
            .withDesign(design.uiKitDesign) ?? UIFont.systemFont(ofSize: size, weight: effectiveWeight).fontDescriptor

        return UIFont(descriptor: descriptor, size: size)
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

private extension Font.Weight {
    var uiKitWeight: UIFont.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        default: .regular
        }
    }
}

private extension Font.Design {
    var uiKitDesign: UIFontDescriptor.SystemDesign {
        switch self {
        case .default: .default
        case .serif: .serif
        case .rounded: .rounded
        case .monospaced: .monospaced
        @unknown default: .default
        }
    }
}
#endif
