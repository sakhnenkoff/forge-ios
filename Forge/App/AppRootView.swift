//
//  AppRootView.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

struct AppRootView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session

    var body: some View {
        ZStack {
            switch session.rootState {
            case .loading:
                ProgressView("Preparing your demo...")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundPrimary)
                    .transition(.opacity)
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)
            case .auth:
                AuthView()
                    .transition(.opacity)
            case .paywall:
                PaywallView()
                    .transition(.opacity)
            case .app:
                AppTabsView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: session.rootState)
        .task {
            await session.bootstrap(services: services)
        }
    }
}
