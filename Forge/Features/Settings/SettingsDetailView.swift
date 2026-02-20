//
//  SettingsDetailView.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

struct SettingsDetailView: View {
    @Environment(AppServices.self) private var services
    @State private var viewModel = SettingsDetailViewModel()

    var body: some View {
        DSScreen(title: "Settings Detail") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header

                if viewModel.isProcessing {
                    ProgressView("Requesting permission...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                privacySection
                trackingSection

                if viewModel.needsRestart {
                    infoCard(
                        title: "Restart recommended",
                        message: "Restart the app to apply analytics changes.",
                        icon: "arrow.clockwise",
                        tint: .warning
                    )
                }

                if AppConfiguration.isMock {
                    infoCard(
                        title: "Mock build",
                        message: "Analytics and tracking SDKs are disabled in Mock builds.",
                        icon: "flask",
                        tint: .info
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Privacy update failed",
                        message: errorMessage,
                        retryTitle: "Dismiss",
                        onRetry: { viewModel.clearError() }
                    )
                }
            }
        }
        .onAppear {
            viewModel.onAppear(services: services)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Privacy & data")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Control analytics and tracking preferences.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var privacySection: some View {
        DSSection(title: "Analytics") {
            DSListCard {
                DSListRow(
                    title: "Share analytics",
                    subtitle: "Help us improve onboarding.",
                    leadingIcon: "chart.line.uptrend.xyaxis"
                ) {
                    Toggle("", isOn: Binding(
                        get: { viewModel.analyticsOptIn },
                        set: { viewModel.setAnalyticsOptIn($0, services: services) }
                    )).labelsHidden().tint(Color.themePrimary)
                }

                Divider()

                DSListRow(
                    title: "What we collect",
                    subtitle: "Anonymized engagement data.",
                    leadingIcon: "doc.text.magnifyingglass",
                    leadingTint: .textSecondary,
                    titleColor: .textPrimary
                )
            }
        }
    }

    private var trackingSection: some View {
        DSSection(title: "Tracking") {
            DSListCard {
                DSListRow(
                    title: "Allow tracking (ATT)",
                    subtitle: "Personalize the demo.",
                    leadingIcon: "hand.raised"
                ) {
                    Toggle("", isOn: Binding(
                        get: { viewModel.trackingOptIn },
                        set: { viewModel.setTrackingOptIn($0, services: services) }
                    )).labelsHidden().tint(Color.themePrimary)
                }

                Divider()

                DSListRow(
                    title: "Tracking status",
                    subtitle: viewModel.trackingStatusLabel,
                    leadingIcon: "lock.shield",
                    leadingTint: .textSecondary,
                    titleColor: .textPrimary
                )

                Divider()

                DSListRow(
                    title: "Request authorization",
                    subtitle: "Show the system dialog.",
                    leadingIcon: "checkmark.seal"
                ) {
                    viewModel.requestTrackingAuthorization(services: services)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                .disabled(!viewModel.trackingOptIn || viewModel.isProcessing || AppConfiguration.isMock)
            }
        }
    }

    private func infoCard(title: String, message: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(tint.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
