//
//  AppServices.swift
//  Forge
//
//
//

import SwiftUI
import Core
import CoreMock

private struct ServiceBundle {
    let logManager: LogManager
    let authManager: AuthManager
    let userManager: UserManager
    let keychainService: KeychainCacheServiceProtocol
    let userDefaultsService: UserDefaultsCacheServiceProtocol
    let networkingService: NetworkingServiceProtocol
    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
}

private struct OptionalManagers {
    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
}

@MainActor
@Observable
final class AppServices {
    let configuration: BuildConfiguration
    let consentManager: ConsentManager

    let logManager: LogManager
    let authManager: AuthManager
    let userManager: UserManager
    let keychainService: KeychainCacheServiceProtocol
    let userDefaultsService: UserDefaultsCacheServiceProtocol
    let networkingService: NetworkingServiceProtocol

    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
    let pushManager: PushManager?

    init(configuration: BuildConfiguration = .current) {
        self.configuration = configuration

        let isMock: Bool
        if case .mock = configuration {
            isMock = true
        } else {
            isMock = false
        }

        let consentManager = ConsentManager(isMock: isMock)
        let analyticsEnabled = consentManager.shouldEnableAnalytics

        let bundle: ServiceBundle
        switch configuration {
        case .mock(isSignedIn: let isSignedIn):
            bundle = Self.makeMockServices(isSignedIn: isSignedIn)
        case .dev:
            bundle = Self.makeDevServices(analyticsEnabled: analyticsEnabled)
        case .prod:
            bundle = Self.makeProdServices(analyticsEnabled: analyticsEnabled)
        }

        let pushManager = FeatureFlags.enablePushNotifications
            ? PushManager(logManager: bundle.logManager)
            : nil

        self.consentManager = consentManager
        self.logManager = bundle.logManager
        self.authManager = bundle.authManager
        self.userManager = bundle.userManager
        self.keychainService = bundle.keychainService
        self.userDefaultsService = bundle.userDefaultsService
        self.networkingService = bundle.networkingService
        self.abTestManager = bundle.abTestManager
        self.purchaseManager = bundle.purchaseManager
        self.pushManager = pushManager
        bundle.logManager.addUserProperties(dict: consentManager.eventParameters, isHighPriority: false)
    }

    private static func makeMockServices(isSignedIn: Bool) -> ServiceBundle {
        let logManager = LogManager(services: [
            ConsoleService(printParameters: true, system: .stdout)
        ])
        let authManager = AuthManager(
            service: MockAuthService(user: isSignedIn ? .mock() : nil),
            logger: logManager
        )
        let userManager = UserManager(
            services: MockUserServices(document: isSignedIn ? .mock : nil),
            configuration: Self.userManagerConfiguration,
            logger: logManager
        )
        let managers = Self.makeMockOptionalManagers(logManager: logManager)

        return ServiceBundle(
            logManager: logManager,
            authManager: authManager,
            userManager: userManager,
            keychainService: MockKeychainCacheService(),
            userDefaultsService: MockUserDefaultsCacheService(),
            networkingService: NetworkingService(),
            abTestManager: managers.abTestManager,
            purchaseManager: managers.purchaseManager
        )
    }

    private static func makeDevServices(analyticsEnabled: Bool) -> ServiceBundle {
        let logManager = Self.makeDevLogManager(analyticsEnabled: analyticsEnabled)
        let managers = Self.makeLiveOptionalManagers(
            logManager: logManager,
            abTestService: LocalABTestService()
        )

        return Self.makeLiveServices(logManager: logManager, managers: managers)
    }

    private static func makeProdServices(analyticsEnabled: Bool) -> ServiceBundle {
        let logManager = Self.makeProdLogManager(analyticsEnabled: analyticsEnabled)
        let managers = Self.makeLiveOptionalManagers(
            logManager: logManager,
            abTestService: FirebaseABTestService()
        )

        return Self.makeLiveServices(logManager: logManager, managers: managers)
    }

    private static func makeDevLogManager(analyticsEnabled: Bool) -> LogManager {
        var loggingServices: [any LogService] = [
            ConsoleService(printParameters: true)
        ]
        if analyticsEnabled && FeatureFlags.enableFirebaseAnalytics {
            loggingServices.append(FirebaseAnalyticsService())
        }
        if analyticsEnabled && FeatureFlags.enableMixpanel {
            loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
        }
        if FeatureFlags.enableCrashlytics {
            loggingServices.append(FirebaseCrashlyticsService())
        }

        return LogManager(services: loggingServices)
    }

    private static func makeProdLogManager(analyticsEnabled: Bool) -> LogManager {
        var loggingServices: [any LogService] = []
        if analyticsEnabled && FeatureFlags.enableFirebaseAnalytics {
            loggingServices.append(FirebaseAnalyticsService())
        }
        if analyticsEnabled && FeatureFlags.enableMixpanel {
            loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
        }
        if FeatureFlags.enableCrashlytics {
            loggingServices.append(FirebaseCrashlyticsService())
        }

        return LogManager(services: loggingServices)
    }

    private static func makeLiveServices(
        logManager: LogManager,
        managers: OptionalManagers
    ) -> ServiceBundle {
        let authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
        let userManager = UserManager(
            services: ProductionUserServices(),
            configuration: Self.userManagerConfiguration,
            logger: logManager
        )

        return ServiceBundle(
            logManager: logManager,
            authManager: authManager,
            userManager: userManager,
            keychainService: KeychainCacheService(),
            userDefaultsService: UserDefaultsCacheService(),
            networkingService: NetworkingService(),
            abTestManager: managers.abTestManager,
            purchaseManager: managers.purchaseManager
        )
    }

    private static func makeMockOptionalManagers(logManager: LogManager) -> OptionalManagers {
        let abTestManager = FeatureFlags.enableABTesting
            ? ABTestManager(service: MockABTestService(), logManager: logManager)
            : nil
        let purchaseManager = FeatureFlags.enablePurchases
            ? PurchaseManager(service: MockPurchaseService(), logger: logManager)
            : nil

        return OptionalManagers(
            abTestManager: abTestManager,
            purchaseManager: purchaseManager
        )
    }

    private static func makeLiveOptionalManagers(
        logManager: LogManager,
        abTestService: ABTestService
    ) -> OptionalManagers {
        let abTestManager = FeatureFlags.enableABTesting
            ? ABTestManager(service: abTestService, logManager: logManager)
            : nil
        let purchaseManager = FeatureFlags.enablePurchases
            ? PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            : nil

        return OptionalManagers(
            abTestManager: abTestManager,
            purchaseManager: purchaseManager
        )
    }

    func restoreSession(for user: UserAuthInfo) async {
        do {
            try await userManager.logIn(user.uid)
        } catch {
            logManager.trackEvent(eventName: "UserManager_LogIn_Fail", parameters: error.eventParameters, type: .warning)
        }

        if let purchaseManager {
            _ = try? await purchaseManager.logIn(
                userId: user.uid,
                userAttributes: PurchaseProfileAttributes(
                    email: user.email,
                    mixpanelDistinctId: Constants.mixpanelDistinctId,
                    firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
                )
            )
        }

        logManager.addUserProperties(dict: AppUtilities.eventParameters, isHighPriority: false)
    }

    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.signIn(auth: user, isNewUser: isNewUser)
        await restoreSession(for: user)
    }

    func signOut() async throws {
        try authManager.signOut()
        userManager.signOut()

        if let purchaseManager {
            try await purchaseManager.logOut()
        }

        logManager.deleteUserProfile()
    }
}

extension AppServices {
    static let userManagerConfiguration = DataManagerSyncConfiguration(
        managerKey: "UserMan",
        enablePendingWrites: true
    )
}
