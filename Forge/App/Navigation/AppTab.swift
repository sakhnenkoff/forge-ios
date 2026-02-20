//
//  AppTab.swift
//  Forge
//
//
//

import SwiftUI
import AppRouter

enum AppTab: String, TabType, CaseIterable, Identifiable {
    case home
    case settings

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .settings:
            return "gearshape"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        }
    }

    @MainActor
    @ViewBuilder
    func makeContentView() -> some View {
        switch self {
        case .home:
            HomeView()
        case .settings:
            SettingsView()
        }
    }
}
