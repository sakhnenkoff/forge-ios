//
//  AppDelegate.swift
//  Forge
//
//
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseMessaging
import DesignSystem

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppConfiguration.validateConfiguration()
        DesignSystem.configure(theme: AdaptiveTheme())

        #if DEBUG
        UserDefaults.standard.set(false, forKey: "com.apple.CoreData.SQLDebug")
        UserDefaults.standard.set(false, forKey: "com.apple.CoreData.Logging.stderr")
        #endif

        registerForRemotePushNotifications(application: application)
        return true
    }

    private func registerForRemotePushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        #if !MOCK
        Messaging.messaging().delegate = self
        #endif
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if !MOCK
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        #if DEBUG
        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        #endif
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: .pushNotification, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NotificationCenter.default.postFCMToken(token: fcmToken ?? "")
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod

    static var current: BuildConfiguration {
        var config: BuildConfiguration

        #if MOCK
        config = .mock(isSignedIn: false)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        let isUITesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || ProcessInfo.processInfo.arguments.contains("UI-TESTING")

        if isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            config = .mock(isSignedIn: isSignedIn)
        }

        return config
    }

    func configureFirebase() {
        switch self {
        case .mock:
            break
        case .dev:
            guard
                let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: plist)
            else {
                assertionFailure("Missing GoogleService-Info-Dev.plist")
                return
            }
            FirebaseApp.configure(options: options)
        case .prod:
            guard
                let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: plist)
            else {
                assertionFailure("Missing GoogleService-Info-Prod.plist")
                return
            }
            FirebaseApp.configure(options: options)
        }
    }
}
