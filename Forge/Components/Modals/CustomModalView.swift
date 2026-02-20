//
//  CustomModalView.swift
//  
//
//  
//

import SwiftUI
import DesignSystem

struct CustomModalView: View {

    var title: String = "Title"
    var subtitle: String? = "This is a subtitle."
    var primaryButtonTitle: String = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle: String = "No"
    var secondaryButtonAction: () -> Void = { }
    
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.smd) {
                Text(title)
                    .font(.titleSmall())
                    .foregroundStyle(Color.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(DSSpacing.smd)

            VStack(spacing: DSSpacing.sm) {
                DSButton(title: primaryButtonTitle, isFullWidth: true, action: primaryButtonAction)
                DSButton(title: secondaryButtonTitle, style: .tertiary, isFullWidth: true, action: secondaryButtonAction)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
        .padding(DSSpacing.xxlg)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                
            }
        )
    }
}
