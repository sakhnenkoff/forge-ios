//
//  AppSession.swift
//  Forge
//
//
//

import SwiftUI
import Core

@MainActor
@Observable
final class AppSession {
    enum RootState {
        case loading
        case onboarding
        case auth
        case paywall
        case app
    }

    private let onboardingKey = "app_onboarding_complete"
    private let premiumKey = "app_premium"
    private let paywallDismissedKey = "app_paywall_dismissed"
    private let authDismissedKey = "app_auth_dismissed"

    private let keychain: KeychainCacheServiceProtocol
    private var didBootstrap = false

    var isLoading = true
    var auth: UserAuthInfo?
    var currentUser: UserModel?

    // Non-sensitive: stays in UserDefaults
    var isOnboardingComplete: Bool

    // Sensitive: backed by Keychain (read in init, written in mutation methods)
    var isPremium: Bool
    var hasDismissedPaywall: Bool
    var hasDismissedAuth: Bool

    var lastErrorMessage: String?

    init(keychain: KeychainCacheServiceProtocol = KeychainCacheService()) {
        self.keychain = keychain
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
        isPremium = (keychain.fetchString(for: premiumKey) == "true")
        hasDismissedPaywall = (keychain.fetchString(for: paywallDismissedKey) == "true")
        hasDismissedAuth = (keychain.fetchString(for: authDismissedKey) == "true")
    }

    var isSignedIn: Bool {
        auth != nil
    }

    var shouldShowPaywall: Bool {
        FeatureFlags.enablePurchases && !isPremium && !hasDismissedPaywall
    }

    var shouldShowAuth: Bool {
        FeatureFlags.enableAuth && !isSignedIn && !hasDismissedAuth
    }

    // MARK: - Post-Onboarding Routing
    //
    // After onboarding completes, the app routes through this priority order:
    //   1. Auth screen   (if enableAuth && not signed in && not dismissed)
    //   2. Paywall screen (if enablePurchases && not premium && not dismissed)
    //   3. Main app       (AppTabsView)
    //
    // To change the routing behavior, modify the conditions below:
    //   - Show paywall BEFORE auth: swap the `shouldShowAuth` and `shouldShowPaywall` checks
    //   - Skip paywall entirely: set FeatureFlags.enablePurchases = false
    //     in Configurations/FeatureFlags.swift
    //   - Skip auth entirely: set FeatureFlags.enableAuth = false
    //     in Configurations/FeatureFlags.swift
    //   - Always show paywall after onboarding: remove the `hasDismissedPaywall` check
    //     in the `shouldShowPaywall` computed property above
    var rootState: RootState {
        if isLoading {
            return .loading
        }
        if !isOnboardingComplete {
            return .onboarding
        }
        if shouldShowAuth {
            return .auth
        }
        if shouldShowPaywall {
            return .paywall
        }
        return .app
    }

    func bootstrap(services: AppServices) async {
        guard !didBootstrap else { return }
        didBootstrap = true
        isLoading = true

        let auth = services.authManager.auth
        self.auth = auth

        if let auth {
            await services.restoreSession(for: auth)
            do {
                currentUser = try await services.userManager.getUser()
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            markAuthDismissed()
        }

        if currentUser?.didCompleteOnboarding == true {
            setOnboardingComplete()
        }

        if FeatureFlags.enablePurchases, let purchaseManager = services.purchaseManager {
            updatePremiumStatus(entitlements: purchaseManager.entitlements)
        }

        isLoading = false
    }

    func setOnboardingComplete() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func markPaywallDismissed() {
        hasDismissedPaywall = true
        _ = keychain.save("true", for: paywallDismissedKey)
    }

    func markAuthDismissed() {
        hasDismissedAuth = true
        _ = keychain.save("true", for: authDismissedKey)
    }

    func resetPaywallDismissal() {
        hasDismissedPaywall = false
        _ = keychain.remove(for: paywallDismissedKey)
    }

    func resetAuthDismissal() {
        hasDismissedAuth = false
        _ = keychain.remove(for: authDismissedKey)
    }

    func resetOnboarding() {
        isOnboardingComplete = false
        UserDefaults.standard.removeObject(forKey: onboardingKey)
    }

    func updatePremiumStatus(entitlements: [PurchasedEntitlement]) {
        isPremium = entitlements.hasActiveEntitlement
        _ = keychain.save(isPremium ? "true" : "false", for: premiumKey)
    }

    func updateAuth(user: UserAuthInfo, currentUser: UserModel?) {
        auth = user
        if let currentUser {
            self.currentUser = currentUser
            if currentUser.didCompleteOnboarding == true {
                setOnboardingComplete()
            }
        }
        markAuthDismissed()
    }

    func resetForSignOut(clearOnboarding: Bool = false, clearAuthDismissal: Bool = false) {
        auth = nil
        currentUser = nil
        isPremium = false
        _ = keychain.remove(for: premiumKey)
        hasDismissedPaywall = false
        _ = keychain.remove(for: paywallDismissedKey)
        lastErrorMessage = nil

        if clearOnboarding {
            isOnboardingComplete = false
            UserDefaults.standard.removeObject(forKey: onboardingKey)
        }

        if clearAuthDismissal {
            resetAuthDismissal()
        }
    }
}
