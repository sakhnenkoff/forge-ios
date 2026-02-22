//
//  AuthView.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

struct AuthView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var viewModel = AuthViewModel()

    var body: some View {
        DSScreen(contentPadding: DSSpacing.md, topPadding: DSSpacing.xxlg) {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                hero
                valueProps
                signInOptions
                skipButton
                if viewModel.isLoading {
                    ProgressView("Signing you in...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Couldn't sign you in",
                        message: errorMessage,
                        retryTitle: "Try again",
                        onRetry: { viewModel.retryLastSignIn(services: services, session: session) },
                        dismissTitle: "Dismiss",
                        onDismiss: { viewModel.clearError() }
                    )
                }

                footerNote
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Sign in")
                .font(.display())
                .foregroundStyle(Color.textPrimary)
            Text("Sync your finances across devices and unlock premium insights.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var valueProps: some View {
        DSCard(tint: Color.themePrimary.opacity(0.03)) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                featureRow(
                    icon: "lock.shield.fill",
                    title: "Bank-grade security",
                    message: "Your financial data is encrypted and never shared."
                )
                featureRow(
                    icon: "icloud.fill",
                    title: "Sync everywhere",
                    message: "Access your budget on iPhone, iPad, and Mac."
                )
                featureRow(
                    icon: "chart.bar.fill",
                    title: "Smart insights",
                    message: "AI-powered spending analysis tailored to your habits."
                )
            }
        }
    }

    @ViewBuilder
    private var signInOptions: some View {
        if viewModel.availableProviders.isEmpty {
            EmptyStateView(
                icon: "person.crop.circle.badge.xmark",
                title: "Sign-in unavailable",
                message: "Providers are temporarily unavailable. Try again in a moment.",
                actionTitle: "Refresh",
                action: { viewModel.refreshProviders() }
            )
        } else {
            VStack(spacing: DSSpacing.sm) {
                if viewModel.availableProviders.contains(.apple) {
                    providerCard(
                        icon: "apple.logo",
                        title: "Sign in with Apple",
                        description: "Private relay available"
                    ) {
                        viewModel.signInApple(services: services, session: session)
                    }
                }

                if viewModel.availableProviders.contains(.google) {
                    providerCard(
                        icon: "g.circle.fill",
                        title: "Sign in with Google",
                        description: "Continue with your Google account"
                    ) {
                        viewModel.signInGoogle(services: services, session: session)
                    }
                }

                if viewModel.availableProviders.contains(.guest) {
                    providerCard(
                        icon: "person",
                        title: "Explore as guest",
                        description: "Try the app first"
                    ) {
                        viewModel.signInAnonymously(services: services, session: session)
                    }
                }
            }
            .disabled(viewModel.isLoading)
        }
    }

    private func providerCard(icon: String, title: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            DSCard {
                HStack(spacing: DSSpacing.smd) {
                    DSIconBadge(
                        systemName: icon,
                        size: 40,
                        cornerRadius: DSRadii.sm,
                        backgroundColor: Color.themePrimary.opacity(0.08),
                        foregroundColor: Color.themePrimary
                    )
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(title)
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text(description)
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var footerNote: some View {
        Text("By continuing, you agree to the terms and acknowledge the privacy policy.")
            .font(.captionLarge())
            .foregroundStyle(Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var skipButton: some View {
        DSButton.link(title: "Skip for now") {
            session.markAuthDismissed()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func featureRow(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: DSLayout.iconMedium, weight: .medium))
                .foregroundStyle(Color.themePrimary)
                .padding(DSSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                        .fill(Color.surface)
                )

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AuthView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
