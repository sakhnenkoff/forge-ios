import SwiftUI

public struct AppTopIcon: View {
    let systemName: String
    let tint: Color

    public init(systemName: String, tint: Color = Color.themePrimary) {
        self.systemName = systemName
        self.tint = tint
    }

    public var body: some View {
        SketchIcon(systemName: systemName, size: 28, color: tint)
    }
}

#Preview("App Top Icon") {
    AppTopIcon(systemName: "house")
        .padding()
        .background(Color.backgroundPrimary)
}
