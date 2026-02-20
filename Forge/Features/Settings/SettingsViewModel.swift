//
//  SettingsViewModel.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

@MainActor
@Observable
final class SettingsViewModel {
    var isProcessing = false
    var errorMessage: String?
    var toast: Toast?

    func signOut(services: AppServices, session: AppSession) {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.signOutStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await services.signOut()
                session.resetForSignOut()
                services.logManager.trackEvent(event: Event.signOutSuccess)
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.signOutFail(error: error))
            }
            self.isProcessing = false
        }
    }

    func deleteAccount(services: AppServices, session: AppSession) {
        guard let auth = session.auth else {
            errorMessage = "No active session."
            return
        }
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.deleteAccountStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                let option = self.authReauthOption(auth: auth)
                try await services.authManager.deleteAccountWithReauthentication(option: option, revokeToken: false) {
                    try await services.userManager.deleteCurrentUser()
                }

                if let purchaseManager = services.purchaseManager {
                    try await purchaseManager.logOut()
                }
                services.logManager.deleteUserProfile()

                session.resetForSignOut(clearOnboarding: true)
                services.logManager.trackEvent(event: Event.deleteAccountSuccess)
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
            self.isProcessing = false
        }
    }

    func requestPushAuthorization(services: AppServices) {
        guard let pushManager = services.pushManager else {
            errorMessage = "Push notifications are disabled."
            return
        }
        guard !isProcessing else { return }
        isProcessing = true

        Task { [weak self] in
            guard let self else { return }
            defer { self.isProcessing = false }
            do {
                services.logManager.trackEvent(event: Event.pushRequestStart)
                let granted = try await pushManager.requestAuthorization()
                toast = granted ? .success("Notifications enabled.") : .info("Notifications not enabled.")
                services.logManager.trackEvent(event: Event.pushRequestFinish(granted: granted))
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.pushRequestFail(error: error))
            }
        }
    }

    func resetOnboarding(services: AppServices, session: AppSession) {
        session.resetOnboarding()
        toast = .success("Onboarding reset.")
        services.logManager.trackEvent(event: Event.resetOnboarding)
    }

    func resetPaywall(services: AppServices, session: AppSession) {
        session.resetPaywallDismissal()
        toast = .info("Paywall will show on next launch.")
        services.logManager.trackEvent(event: Event.resetPaywall)
    }

    func showAuthScreen(services: AppServices, session: AppSession) {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.resetAuth)

        Task { [weak self] in
            guard let self else { return }
            do {
                if session.isSignedIn {
                    try await services.signOut()
                }
                session.resetForSignOut(clearAuthDismissal: true)
                toast = .info("Sign-in screen will show on next launch.")
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.resetAuthFail(error: error))
            }
            self.isProcessing = false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func authReauthOption(auth: UserAuthInfo) -> SignInOption {
        if auth.authProviders.contains(.apple) {
            return .apple
        }
        if auth.authProviders.contains(.google), let clientId = Constants.firebaseAppClientId {
            return .google(GIDClientID: clientId)
        }
        return .anonymous
    }
}

extension SettingsViewModel {
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case resetOnboarding
        case resetPaywall
        case resetAuth
        case resetAuthFail(error: Error)
        case pushRequestStart
        case pushRequestFinish(granted: Bool)
        case pushRequestFail(error: Error)

        var eventName: String {
            switch self {
            case .signOutStart:
                return "Settings_SignOut_Start"
            case .signOutSuccess:
                return "Settings_SignOut_Success"
            case .signOutFail:
                return "Settings_SignOut_Fail"
            case .deleteAccountStart:
                return "Settings_Delete_Start"
            case .deleteAccountSuccess:
                return "Settings_Delete_Success"
            case .deleteAccountFail:
                return "Settings_Delete_Fail"
            case .resetOnboarding:
                return "Settings_Reset_Onboarding"
            case .resetPaywall:
                return "Settings_Reset_Paywall"
            case .resetAuth:
                return "Settings_Reset_Auth"
            case .resetAuthFail:
                return "Settings_Reset_Auth_Fail"
            case .pushRequestStart:
                return "Settings_Push_Request_Start"
            case .pushRequestFinish:
                return "Settings_Push_Request_Finish"
            case .pushRequestFail:
                return "Settings_Push_Request_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(let error), .deleteAccountFail(let error), .resetAuthFail(let error):
                return error.eventParameters
            case .pushRequestFinish(let granted):
                return ["granted": granted]
            case .pushRequestFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail, .resetAuthFail:
                return .severe
            case .pushRequestFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
