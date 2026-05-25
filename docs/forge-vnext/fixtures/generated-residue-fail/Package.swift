// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "GeneratedResidueDeps",
  dependencies: [
    .package(url: "https://github.com/revenuecat/purchases-ios", from: "5.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
    .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.0.0")
  ],
  targets: [
    .target(name: "GeneratedResidueDeps", dependencies: ["FirebaseAuth", "FirebaseFirestore", "FirebaseMessaging", "FirebaseRemoteConfig", "FirebaseStorage", "FirebaseAnalytics", "FirebaseCrashlytics", "GoogleSignIn", "Mixpanel"])
  ]
)
