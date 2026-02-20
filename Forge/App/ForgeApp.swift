//
//  ForgeApp.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

@main
struct ForgeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var services: AppServices
    @State private var session = AppSession()
    #if DEBUG
    @State private var themeRefreshID = UUID()
    #endif

    init() {
        let configuration = BuildConfiguration.current
        configuration.configureFirebase()
        _services = State(initialValue: AppServices(configuration: configuration))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                #if DEBUG
                .id(themeRefreshID)
                .onReceive(NotificationCenter.default.publisher(for: DesignSystem.themeDidChangeNotification)) { _ in
                    themeRefreshID = UUID()
                }
                #endif
                .environment(services)
                .environment(session)
        }
    }
}
