//
//  AuthViewModel.swift
//  Forge
//
//
//

import SwiftUI

@MainActor
@Observable
final class AuthViewModel {
    enum Provider: CaseIterable {
        case apple
        case google
        case guest
    }

    var isLoading = false
    var errorMessage: String?
    var availableProviders: [Provider] = Provider.allCases

    private var lastProvider: Provider?

    func signInApple(services: AppServices, session: AppSession) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        lastProvider = .apple
        services.logManager.trackEvent(event: Event.appleStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await services.authManager.signInApple()
                try await self.handleAuthResult(result, services: services, session: session)
                services.logManager.trackEvent(event: Event.appleSuccess(isNewUser: result.isNewUser))
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.appleFail(error: error))
            }
            self.isLoading = false
        }
    }

    func signInGoogle(services: AppServices, session: AppSession) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        lastProvider = .google
        services.logManager.trackEvent(event: Event.googleStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                guard let clientId = Constants.firebaseAppClientId else {
                    throw AppError("Missing Google Client ID")
                }
                let result = try await services.authManager.signInGoogle(GIDClientID: clientId)
                try await self.handleAuthResult(result, services: services, session: session)
                services.logManager.trackEvent(event: Event.googleSuccess(isNewUser: result.isNewUser))
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.googleFail(error: error))
            }
            self.isLoading = false
        }
    }

    func signInAnonymously(services: AppServices, session: AppSession) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        lastProvider = .guest
        services.logManager.trackEvent(event: Event.anonStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await services.authManager.signInAnonymously()
                try await self.handleAuthResult(result, services: services, session: session)
                services.logManager.trackEvent(event: Event.anonSuccess(isNewUser: result.isNewUser))
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.anonFail(error: error))
            }
            self.isLoading = false
        }
    }

    private func handleAuthResult(
        _ result: (user: UserAuthInfo, isNewUser: Bool),
        services: AppServices,
        session: AppSession
    ) async throws {
        try await services.logIn(user: result.user, isNewUser: result.isNewUser)
        session.updateAuth(user: result.user, currentUser: services.userManager.currentUser)
        session.markAuthDismissed()

        if let purchaseManager = services.purchaseManager {
            session.updatePremiumStatus(entitlements: purchaseManager.entitlements)
        }
    }

    func retryLastSignIn(services: AppServices, session: AppSession) {
        guard let lastProvider else {
            errorMessage = nil
            return
        }

        switch lastProvider {
        case .apple:
            signInApple(services: services, session: session)
        case .google:
            signInGoogle(services: services, session: session)
        case .guest:
            signInAnonymously(services: services, session: session)
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func refreshProviders() {
        availableProviders = Provider.allCases
    }
}

extension AuthViewModel {
    enum Event: LoggableEvent {
        case appleStart
        case appleSuccess(isNewUser: Bool)
        case appleFail(error: Error)
        case googleStart
        case googleSuccess(isNewUser: Bool)
        case googleFail(error: Error)
        case anonStart
        case anonSuccess(isNewUser: Bool)
        case anonFail(error: Error)

        var eventName: String {
            switch self {
            case .appleStart:
                return "Auth_Apple_Start"
            case .appleSuccess:
                return "Auth_Apple_Success"
            case .appleFail:
                return "Auth_Apple_Fail"
            case .googleStart:
                return "Auth_Google_Start"
            case .googleSuccess:
                return "Auth_Google_Success"
            case .googleFail:
                return "Auth_Google_Fail"
            case .anonStart:
                return "Auth_Anon_Start"
            case .anonSuccess:
                return "Auth_Anon_Success"
            case .anonFail:
                return "Auth_Anon_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .appleSuccess(let isNewUser), .googleSuccess(let isNewUser), .anonSuccess(let isNewUser):
                return ["is_new_user": isNewUser]
            case .appleFail(let error), .googleFail(let error), .anonFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .appleFail, .googleFail, .anonFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
