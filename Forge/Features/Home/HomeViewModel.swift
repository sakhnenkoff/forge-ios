//
//  HomeViewModel.swift
//  Forge
//
//

import SwiftUI
import DesignSystem

@MainActor
@Observable
final class HomeViewModel {
    var toast: Toast?
    var selectedHomeTab: String = "Dashboard"

    private var hasLoaded = false

    static let homeTabs = ["Dashboard", "Components"]

    // MARK: - Lifecycle

    func greeting(for session: AppSession) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        default: timeGreeting = "Good evening"
        }

        if let name = session.currentUser?.displayNameCalculated {
            return "\(timeGreeting), \(name)"
        }
        return timeGreeting
    }

    var currentDateString: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    func onAppear(services: AppServices, session: AppSession) {
        services.logManager.trackEvent(event: Event.onAppear(isSignedIn: session.isSignedIn))
        guard !hasLoaded else { return }
        hasLoaded = true
    }
}

extension HomeViewModel {
    enum Event: LoggableEvent {
        case onAppear(isSignedIn: Bool)

        var eventName: String {
            switch self {
            case .onAppear:
                return "Home_Appear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let isSignedIn):
                return ["is_signed_in": isSignedIn]
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
