//
//  HomeView.swift
//  Forge
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct HomeView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router

    @State private var viewModel = HomeViewModel()

    var body: some View {
        DSScreen(title: "Home") {
            VStack(spacing: DSSpacing.xxl) {
                Spacer()

                VStack(spacing: DSSpacing.lg) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundStyle(Color.themePrimary)

                    VStack(spacing: DSSpacing.sm) {
                        Text("Welcome to \(Bundle.main.displayName)")
                            .font(.titleLarge())
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Start building your app")
                            .font(.bodyMedium())
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DSIconButton(icon: "gearshape", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Settings") {
                    router.selectedTab = .settings
                }
            }
        }
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }
}

private extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "App"
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
