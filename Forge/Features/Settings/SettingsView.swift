//
//  SettingsView.swift
//  Forge
//
//

import SwiftUI
import UIKit
import AppRouter
import DesignSystem

struct SettingsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        DSScreen(title: "Settings") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Manage your account, subscription, and preferences.")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.isProcessing {
                    ProgressView("Updating settings...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                flowTogglesSection
                accountSection
                subscriptionSection
                navigationSection
                debugSection

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Settings update failed",
                        message: errorMessage,
                        retryTitle: "Dismiss",
                        onRetry: { viewModel.clearError() }
                    )
                }
            }
        }
        .toast($viewModel.toast)
    }

    private var accountSection: some View {
        DSSection(title: "Account") {
            if session.isSignedIn {
                DSListCard {
                    DSListRow(
                        title: "User ID",
                        subtitle: session.auth?.uid ?? "unknown",
                        leadingIcon: "person.crop.circle"
                    ) {
                        copyToPasteboard(session.auth?.uid ?? "")
                    } trailing: {
                        DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                    }

                    if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                        Divider()
                        DSListRow(
                            title: "Email",
                            subtitle: email,
                            leadingIcon: "envelope"
                        ) {
                            copyToPasteboard(email)
                        } trailing: {
                            DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                        }
                    }

                    Divider()
                    DSListRow(
                        title: "Sign out",
                        subtitle: "End this session.",
                        leadingIcon: "arrow.backward.square"
                    ) {
                        viewModel.signOut(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                    Divider()
                    DSListRow(
                        title: "Delete account",
                        subtitle: "Remove all data.",
                        leadingIcon: "trash",
                        leadingTint: .error,
                        titleColor: .error
                    ) {
                        viewModel.deleteAccount(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .destructive, size: .small)
                    }
                }
                .disabled(viewModel.isProcessing)
            } else {
                if FeatureFlags.enableAuth {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.exclamationmark",
                        title: "Not signed in",
                        message: "Sign in to sync your finances and unlock cloud backup.",
                        actionTitle: "Go to sign in",
                        action: { viewModel.showAuthScreen(services: services, session: session) }
                    )
                } else {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Guest mode active",
                        message: "Authentication is disabled in FeatureFlags."
                    )
                }
            }
        }
    }

    private var flowTogglesSection: some View {
        DSSection(title: "App Flows") {
            DSListCard {
                DSListRow(
                    title: "Onboarding flow",
                    subtitle: "Show the onboarding steps.",
                    leadingIcon: "sparkles"
                ) {
                    Toggle("", isOn: onboardingToggle).labelsHidden().tint(Color.themePrimary)
                }

                Divider()

                if FeatureFlags.enableAuth {
                    DSListRow(
                        title: "Sign-in screen",
                        subtitle: "Show the auth screen.",
                        leadingIcon: "person.crop.circle"
                    ) {
                        Toggle("", isOn: authToggle).labelsHidden().tint(Color.themePrimary)
                    }
                }

                if FeatureFlags.enablePurchases {
                    Divider()
                    DSListRow(
                        title: "Paywall flow",
                        subtitle: "Show the premium upsell.",
                        leadingIcon: "creditcard.fill"
                    ) {
                        Toggle("", isOn: paywallToggle).labelsHidden().tint(Color.themePrimary)
                    }
                }
            }
            .disabled(viewModel.isProcessing)
        }
    }

    private var subscriptionSection: some View {
        DSSection(title: "Subscription") {
            DSListCard {
                DSListRow(
                    title: "Plan",
                    subtitle: session.isPremium ? "Pro active." : "Free plan. Upgrade for more.",
                    leadingIcon: "sparkles"
                ) {
                    Text(session.isPremium ? "Pro" : "Free")
                        .font(.captionLarge())
                        .foregroundStyle(Color.themePrimary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(Color.themePrimary.opacity(0.12), in: Capsule())
                }
                Divider()
                DSListRow(
                    title: "Upgrade to Pro",
                    subtitle: "Unlock all features.",
                    leadingIcon: "creditcard.fill"
                ) {
                    router.presentSheet(.paywall)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
            .disabled(!FeatureFlags.enablePurchases)
        }
    }

    private var navigationSection: some View {
        DSSection(title: "Navigation") {
            DSListCard {
                DSListRow(
                    title: "Settings detail",
                    subtitle: "Privacy and tracking.",
                    leadingIcon: "slider.horizontal.3"
                ) {
                    router.navigateTo(.settingsDetail, for: .settings)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }
    }

    private var debugSection: some View {
        DSSection(title: "Debug") {
            DSListCard {
                DSListRow(
                    title: "Open debug menu",
                    subtitle: "Developer utilities.",
                    leadingIcon: "ladybug.fill"
                ) {
                    router.presentSheet(.debug)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }
    }

    private var onboardingToggle: Binding<Bool> {
        Binding(
            get: { !session.isOnboardingComplete },
            set: { newValue in
                if newValue {
                    viewModel.resetOnboarding(services: services, session: session)
                } else {
                    session.setOnboardingComplete()
                    viewModel.toast = .info("Onboarding hidden.")
                }
            }
        )
    }

    private var authToggle: Binding<Bool> {
        Binding(
            get: { FeatureFlags.enableAuth && !session.hasDismissedAuth },
            set: { newValue in
                guard FeatureFlags.enableAuth else { return }
                if newValue {
                    viewModel.showAuthScreen(services: services, session: session)
                } else {
                    session.markAuthDismissed()
                    viewModel.toast = .info("Sign-in hidden.")
                }
            }
        )
    }

    private var paywallToggle: Binding<Bool> {
        Binding(
            get: { FeatureFlags.enablePurchases && !session.hasDismissedPaywall },
            set: { newValue in
                guard FeatureFlags.enablePurchases else { return }
                if newValue {
                    viewModel.resetPaywall(services: services, session: session)
                } else {
                    session.markPaywallDismissed()
                    viewModel.toast = .info("Paywall hidden.")
                }
            }
        )
    }

    private func copyToPasteboard(_ value: String) {
        guard !value.isEmpty else { return }
        UIPasteboard.general.string = value
        viewModel.toast = .success("Copied to clipboard.")
    }

}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
