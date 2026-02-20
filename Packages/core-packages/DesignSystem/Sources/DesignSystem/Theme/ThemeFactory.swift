import SwiftUI

enum ThemeFactory {
    static func spacing() -> SpacingScale {
        SpacingScale(
            xs: 4,
            sm: 8,
            smd: 12,
            md: 16,
            mlg: 20,
            lg: 24,
            xl: 32,
            xxlg: 40,
            xxl: 52
        )
    }

    static func layout() -> LayoutScale {
        LayoutScale(
            cardMaxWidth: 360,
            cardCompactWidth: 340,
            textMaxWidth: 260,
            mediaHeight: 160,
            avatarLarge: 68,
            avatarSmall: 44,
            iconSmall: 20,
            iconMedium: 22,
            iconLarge: 28,
            listRowMinHeight: 52
        )
    }

    static func hybridTypography(
        titleDesign: Font.Design,
        headlineDesign: Font.Design,
        bodyDesign: Font.Design,
        bodyWeight: Font.Weight = .regular
    ) -> TypographyScale {
        TypographyScale(
            titleLarge: TextStyle(size: 26, weight: .semibold, design: titleDesign),
            titleMedium: TextStyle(size: 22, weight: .semibold, design: titleDesign),
            titleSmall: TextStyle(size: 18, weight: .semibold, design: titleDesign),
            headlineLarge: TextStyle(size: 17, weight: .semibold, design: headlineDesign),
            headlineMedium: TextStyle(size: 15, weight: .semibold, design: headlineDesign),
            headlineSmall: TextStyle(size: 13, weight: .semibold, design: headlineDesign),
            bodyLarge: TextStyle(size: 15, weight: bodyWeight, design: bodyDesign),
            bodyMedium: TextStyle(size: 13, weight: bodyWeight, design: bodyDesign),
            bodySmall: TextStyle(size: 12, weight: bodyWeight, design: bodyDesign),
            captionLarge: TextStyle(size: 11, weight: .regular, design: .monospaced),
            captionSmall: TextStyle(size: 10, weight: .regular, design: .monospaced),
            buttonLarge: TextStyle(size: 14, weight: .semibold, design: .monospaced),
            buttonMedium: TextStyle(size: 13, weight: .semibold, design: .monospaced),
            buttonSmall: TextStyle(size: 12, weight: .semibold, design: .monospaced)
        )
    }
}
