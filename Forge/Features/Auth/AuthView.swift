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
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Sync your finances across devices and unlock premium insights.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var valueProps: some View {
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
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(Color.themePrimary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
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
            DSListCard {
                if viewModel.availableProviders.contains(.apple) {
                    DSListRow(
                        title: "Sign in with Apple",
                        subtitle: "Private relay available",
                        leadingIcon: "apple.logo"
                    ) {
                        viewModel.signInApple(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                }

                if viewModel.availableProviders.contains(.google) {
                    if viewModel.availableProviders.contains(.apple) {
                        Divider()
                    }
                    DSListRow(
                        title: "Sign in with Google",
                        subtitle: "Continue with your Google account",
                        leadingIcon: "g.circle.fill"
                    ) {
                        viewModel.signInGoogle(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                }

                if viewModel.availableProviders.contains(.guest) {
                    if viewModel.availableProviders.contains(.apple) || viewModel.availableProviders.contains(.google) {
                        Divider()
                    }
                    DSListRow(
                        title: "Explore as guest",
                        subtitle: "Try the app first",
                        leadingIcon: "person"
                    ) {
                        viewModel.signInAnonymously(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                }
            }
            .disabled(viewModel.isLoading)
        }
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
