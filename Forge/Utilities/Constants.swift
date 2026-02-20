//
//  Constants.swift
//  Forge
//
//  
//
import FirebaseAnalytics
import FirebaseCore
import Mixpanel

struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let privacyPolicyUrlString = "https://www.google.com"
    static let termsOfServiceUrlString = "https://www.google.com"
    
    static let streakKey = "daily" // daily streaks
    static let xpKey = "general" // general XP
    static let progressKey = "general" // general progress

    static var mixpanelDistinctId: String? {
        #if MOCK
        return nil
        #else
        return Mixpanel.mainInstance().distinctId
        #endif
    }
    
    static var firebaseAnalyticsAppInstanceID: String? {
        #if MOCK
        return nil
        #else
        return Analytics.appInstanceID()
        #endif
    }

    @MainActor
    static var firebaseAppClientId: String? {
        #if MOCK
        return nil
        #else
        return FirebaseApp.app()?.options.clientID
        #endif
    }

}
