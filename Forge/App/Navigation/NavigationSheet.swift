//
//  NavigationSheet.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

struct NavigationSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
        }
    }
}
