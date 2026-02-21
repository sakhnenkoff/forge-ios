import SwiftUI

/// A skeleton loading placeholder with animated shimmer effect.
/// Use to indicate content is loading while maintaining layout structure.
public struct SkeletonView: View {
    let style: SkeletonStyle
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(style: SkeletonStyle = .rectangle(height: 20)) {
        self.style = style
    }

    public var body: some View {
        skeletonShape
            .overlay(shimmerOverlay)
            .clipShape(style.clipShape)
            .accessibilityHidden(true)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
            .onChange(of: reduceMotion) { _, newValue in
                if newValue {
                    isAnimating = false
                }
            }
    }

    @ViewBuilder
    private var skeletonShape: some View {
        switch style {
        case .text(let lines, let lastLineWidth):
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                ForEach(0..<lines, id: \.self) { index in
                    let isLastLine = index == lines - 1
                    RoundedRectangle(cornerRadius: DSSpacing.xs)
                        .fill(Color.skeletonBase)
                        .frame(height: 16)
                        .frame(
                            maxWidth: isLastLine ? .infinity : .infinity,
                            alignment: .leading
                        )
                        .scaleEffect(
                            x: isLastLine ? lastLineWidth : 1.0,
                            y: 1.0,
                            anchor: .leading
                        )
                }
            }

        case .circle(let diameter):
            Circle()
                .fill(Color.skeletonBase)
                .frame(width: diameter, height: diameter)

        case .rectangle(let width, let height):
            RoundedRectangle(cornerRadius: DSSpacing.sm)
                .fill(Color.skeletonBase)
                .frame(width: width, height: height)

        case .card:
            VStack(alignment: .leading, spacing: DSSpacing.smd) {
                RoundedRectangle(cornerRadius: DSSpacing.sm)
                    .fill(Color.skeletonBase)
                    .frame(height: 120)

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    RoundedRectangle(cornerRadius: DSSpacing.xs)
                        .fill(Color.skeletonBase)
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: DSSpacing.xs)
                        .fill(Color.skeletonBase)
                        .frame(height: 16)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: 0.7, y: 1.0, anchor: .leading)
                }
            }
            .padding(DSSpacing.smd)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.smd))

        case .avatar(let size):
            Circle()
                .fill(Color.skeletonBase)
                .frame(width: size.diameter, height: size.diameter)

        case .listRow:
            HStack(spacing: DSSpacing.smd) {
                Circle()
                    .fill(Color.skeletonBase)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    RoundedRectangle(cornerRadius: DSSpacing.xs)
                        .fill(Color.skeletonBase)
                        .frame(height: 14)

                    RoundedRectangle(cornerRadius: DSSpacing.xs)
                        .fill(Color.skeletonBase)
                        .frame(height: 12)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: 0.6, y: 1.0, anchor: .leading)
                }
            }
        }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if reduceMotion {
            Color.clear
        } else {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.6)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.6)
            }
        }
    }
}

// MARK: - Skeleton Style

public enum SkeletonStyle {
    /// Text lines with optional last line width ratio (0.0-1.0)
    case text(lines: Int = 1, lastLineWidth: CGFloat = 0.7)

    /// Circle with specific diameter
    case circle(diameter: CGFloat)

    /// Rectangle with optional width and height
    case rectangle(width: CGFloat? = nil, height: CGFloat)

    /// Card placeholder with image and text
    case card

    /// Avatar placeholder with preset sizes
    case avatar(size: AvatarSize)

    /// List row with avatar and two lines
    case listRow

    var clipShape: AnyShape {
        switch self {
        case .circle, .avatar:
            return AnyShape(Circle())
        default:
            return AnyShape(RoundedRectangle(cornerRadius: DSSpacing.sm))
        }
    }
}

public enum AvatarSize {
    case small   // 32pt
    case medium  // 44pt
    case large   // 64pt

    var diameter: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 64
        }
    }
}

// MARK: - Skeleton Colors

public extension Color {
    /// Base color for skeleton placeholders
    static var skeletonBase: Color {
        Color(light: .borderLight, dark: .borderDark)
    }
}

// MARK: - View Modifier

public extension View {
    /// Shows a skeleton placeholder while loading, then reveals content.
    /// - Parameters:
    ///   - isLoading: Whether to show the skeleton
    ///   - style: The skeleton style to display
    /// - Returns: Either the skeleton or the content.
    @ViewBuilder
    func skeleton(
        _ isLoading: Bool,
        style: SkeletonStyle = .rectangle(height: 20)
    ) -> some View {
        if isLoading {
            SkeletonView(style: style)
        } else {
            self
        }
    }

    /// Applies a redacted shimmer effect while loading.
    @ViewBuilder
    func shimmer(_ isLoading: Bool) -> some View {
        if isLoading {
            self
                .redacted(reason: .placeholder)
                .shimmering()
        } else {
            self
        }
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.6)
                    }
                    .mask(content)
                )
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        isAnimating = true
                    }
                }
        }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Previews

#Preview("Text Lines") {
    VStack(alignment: .leading, spacing: DSSpacing.lg) {
        SkeletonView(style: .text(lines: 1))
        SkeletonView(style: .text(lines: 2))
        SkeletonView(style: .text(lines: 3, lastLineWidth: 0.5))
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Shapes") {
    HStack(spacing: DSSpacing.lg) {
        SkeletonView(style: .circle(diameter: 60))
        SkeletonView(style: .avatar(size: .medium))
        SkeletonView(style: .rectangle(width: 100, height: 60))
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Card") {
    SkeletonView(style: .card)
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("List Rows") {
    VStack(spacing: DSSpacing.md) {
        SkeletonView(style: .listRow)
        SkeletonView(style: .listRow)
        SkeletonView(style: .listRow)
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Skeleton Modifier") {
    let isLoading = true

    return VStack {
        Text("Hello, World!")
            .skeleton(isLoading, style: .text(lines: 1))
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Shimmer Effect") {
    VStack(alignment: .leading, spacing: DSSpacing.smd) {
        Text("Profile Name")
            .font(.headline)
        Text("This is a description that will shimmer while loading")
            .font(.subheadline)
    }
    .shimmer(true)
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Dark Mode") {
    VStack(spacing: DSSpacing.lg) {
        SkeletonView(style: .listRow)
        SkeletonView(style: .text(lines: 2))
        SkeletonView(style: .card)
    }
    .padding()
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
