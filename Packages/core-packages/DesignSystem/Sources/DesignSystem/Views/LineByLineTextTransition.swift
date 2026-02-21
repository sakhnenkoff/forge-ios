import SwiftUI

// MARK: - Line-by-Line Text Renderer

/// A custom TextRenderer that animates text line-by-line with blur and translation effects.
/// Use with `.textRenderer()` modifier and `.transition()` for smooth text transitions.
@available(iOS 18.0, *)
public struct LineByLineAppearanceTextRenderer: TextRenderer, Animatable {
    public var progress: Double
    let duration: TimeInterval
    let singleLineDurationRatio: Double

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public init(
        progress: Double,
        duration: TimeInterval = 0.6,
        singleLineDurationRatio: Double = 0.9
    ) {
        self.progress = progress
        self.duration = duration
        self.singleLineDurationRatio = singleLineDurationRatio
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let lineDelayRatio = (1.0 - singleLineDurationRatio) / Double(layout.count)
        let lineDuration = duration * singleLineDurationRatio

        for (lineIndex, line) in layout.enumerated() {
            var lineContext = context

            let lineMinProgress = lineDelayRatio * Double(lineIndex)
            let lineProgress = max(min((progress - lineMinProgress) / singleLineDurationRatio, 1.0), 0.0)

            let spring = Spring.snappy(duration: lineDuration, extraBounce: 0.2)

            let yTranslation = spring.value(
                fromValue: line.typographicBounds.rect.height,
                toValue: 0,
                initialVelocity: 0,
                time: lineDuration * lineProgress
            )
            let opacity = UnitCurve.easeInOut.value(at: lineProgress)
            let blurRadius = 2 * (1.0 - UnitCurve.easeInOut.value(at: lineProgress))

            lineContext.translateBy(x: 0, y: yTranslation)
            lineContext.opacity = opacity
            lineContext.addFilter(.blur(radius: blurRadius))

            lineContext.draw(line, options: .disablesSubpixelQuantization)
        }
    }
}

// MARK: - Line-by-Line Blur Transition

/// A transition that animates text line-by-line with blur effects.
/// Perfect for onboarding screens with centered text.
@available(iOS 18.0, *)
public struct LineByLineInBlurOutTransition: Transition {
    public var duration: TimeInterval

    public init(duration: TimeInterval = 0.6) {
        self.duration = duration
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        let renderer = LineByLineAppearanceTextRenderer(
            progress: phase == .willAppear ? 0.0 : 1.0,
            duration: duration,
            singleLineDurationRatio: 0.9
        )

        let animation: Animation = phase == .identity
            ? .linear(duration: duration)
            : .easeOut(duration: duration * 0.6)

        content
            .textRenderer(renderer)
            .scaleEffect(phase == .didDisappear ? 0.9 : 1.0)
            .opacity(phase == .didDisappear ? 0.0 : 1.0)
            .blur(radius: phase == .didDisappear ? 2.0 : 0.0)
            .offset(x: 0, y: phase == .didDisappear ? -10.0 : 0.0)
            .animation(animation, value: phase)
    }
}

// MARK: - View Extension

@available(iOS 18.0, *)
public extension View {
    /// Applies line-by-line blur transition for text content.
    /// Use on Text views inside a container with `.transition()`.
    func lineByLineTransition(duration: TimeInterval = 0.6) -> some View {
        self.transition(LineByLineInBlurOutTransition(duration: duration))
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview("Line-by-Line Transition") {
    struct PreviewWrapper: View {
        @State private var currentIndex: Int? = nil

        let texts = [
            "A quiet space\nfor your thoughts",
            "Track your journey,\none day at a time",
            "Build habits that\nactually stick"
        ]

        var body: some View {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()

                VStack {
                    Spacer()

                    if let currentIndex {
                        Text(texts[currentIndex])
                            .font(.system(size: 32, weight: .semibold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.textPrimary)
                            .id(currentIndex)
                            .transition(LineByLineInBlurOutTransition())
                    }

                    Spacer()

                    Button("Next") {
                        withAnimation(.smooth(duration: 0.5)) {
                            currentIndex = currentIndex.map { ($0 + 1) % texts.count } ?? 0
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 32)
            }
            .onAppear {
                currentIndex = 0
            }
        }
    }

    return PreviewWrapper()
}
