import SwiftUI

public struct LoadingView: View {
    let message: String?
    let style: LoadingStyle

    public init(
        message: String? = nil,
        style: LoadingStyle = .default
    ) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(style.scale)
                .tint(style.tintColor)

            if let message = message {
                Text(message)
                    .font(.bodySmall())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DSSpacing.lg)
        .background(style.backgroundColor)
        .cornerRadius(DSSpacing.md)
    }
}

public enum LoadingStyle {
    case `default`
    case overlay
    case inline

    var scale: CGFloat {
        switch self {
        case .default: return 1.5
        case .overlay: return 2.0
        case .inline: return 1.0
        }
    }

    var backgroundColor: Color {
        switch self {
        case .default: return .backgroundSecondary
        case .overlay: return .overlayBackground
        case .inline: return .clear
        }
    }

    var tintColor: Color {
        switch self {
        case .default, .inline: return .themePrimary
        case .overlay: return .textOnPrimary
        }
    }
}

public extension View {
    func loading(_ isLoading: Bool, message: String? = nil) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.overlayBackground
                        .ignoresSafeArea()

                    LoadingView(message: message, style: .overlay)
                }
            }
        }
    }
}

#Preview("Default Loading") {
    LoadingView(message: "Loading...")
}

#Preview("Overlay Loading") {
    LoadingView(message: "Please wait...", style: .overlay)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.overlayBackground)
}

#Preview("Inline Loading") {
    HStack {
        Text("Processing")
        LoadingView(style: .inline)
    }
}

#Preview("Loading Modifier") {
    Text("Content underneath")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loading(true, message: "Loading data...")
}
