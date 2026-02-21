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

    private var hasLoaded = false

    // MARK: - Lifecycle

    func greeting(for session: AppSession) -> String {
        if let name = session.currentUser?.displayNameCalculated {
            return "Welcome, \(name)"
        }
        return "Welcome"
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
