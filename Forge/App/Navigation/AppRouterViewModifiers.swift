//
//  AppRouterViewModifiers.swift
//  Forge
//
//

import SwiftUI

extension View {
    func withAppRouterDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .settingsDetail:
                SettingsDetailView()
            }
        }
    }
}
