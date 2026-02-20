//
//  FeatureFlags.swift
//  Forge
//
//  Configure which features are enabled in your app.
//  Set a flag to false to disable the feature — the manager won't be initialized,
//  reducing startup time and memory usage.
//
//  Full reference: docs/features.md
//

enum FeatureFlags {

    // MARK: - Analytics & Monitoring

    /// Enable Mixpanel product analytics.
    ///
    /// When true: Initializes Mixpanel SDK, routes LogManager analytics events to Mixpanel.
    /// Files: AppServices.swift (manager init), Managers/LogManager/
    /// Credentials: MIXPANEL_TOKEN in Configurations/Secrets.xcconfig.local
    static let enableMixpanel = true

    /// Enable Firebase Analytics event tracking.
    ///
    /// When true: Firebase.configure() runs in AppDelegate, LogManager routes events to Firebase.
    /// Files: AppDelegate.swift, AppServices.swift, Managers/LogManager/
    /// Required by: enableCrashlytics, enablePushNotifications, enableABTesting
    /// Credentials: GoogleService-Info-Dev.plist and GoogleService-Info-Prod.plist (Firebase Console)
    static let enableFirebaseAnalytics = true

    /// Enable Firebase Crashlytics crash reporting.
    ///
    /// When true: Crashlytics initialized in AppDelegate. Requires enableFirebaseAnalytics = true.
    /// Files: AppDelegate.swift, AppServices.swift
    /// Depends on: enableFirebaseAnalytics
    /// Credentials: Same GoogleService-Info.plist as Firebase Analytics
    static let enableCrashlytics = true

    // MARK: - Monetization

    /// Enable in-app purchases and subscription management via RevenueCat.
    ///
    /// When true: PurchaseManager initialized, paywall routing active in AppSession.
    /// Files: AppServices.swift, App/AppSession.swift (shouldShowPaywall), Managers/PurchaseManager/
    /// Depends on: enableFirebaseAnalytics (for purchase event tracking)
    /// Credentials: REVENUECAT_API_KEY in Configurations/Secrets.xcconfig.local
    static let enablePurchases = true

    // MARK: - Authentication

    /// Enable the authentication sign-in flow.
    ///
    /// When true: Auth screen shown to unauthenticated users (controlled by AppSession.shouldShowAuth).
    /// Files: App/AppSession.swift (routing logic), Features/Auth/
    /// Note: Auth is always compiled in; this flag controls routing only.
    static let enableAuth = true

    // MARK: - Notifications

    /// Enable push notifications via Firebase Cloud Messaging.
    ///
    /// When true: PushManager initialized, AppDelegate registers for remote notifications.
    /// Files: AppDelegate.swift, AppServices.swift, Managers/PushManager/
    /// Depends on: enableFirebaseAnalytics
    /// Credentials: APNs Key or Certificate uploaded to Firebase Console
    static let enablePushNotifications = true

    // MARK: - A/B Testing

    /// Enable A/B testing and feature flags via Firebase Remote Config.
    ///
    /// When true: ABTestManager initialized with Firebase Remote Config backend.
    /// Files: AppServices.swift, Managers/ABTestManager/
    /// Depends on: enableFirebaseAnalytics
    static let enableABTesting = true
}
