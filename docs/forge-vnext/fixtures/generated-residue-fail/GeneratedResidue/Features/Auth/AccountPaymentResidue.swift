import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseRemoteConfig
import FirebaseStorage
import Mixpanel
import SwiftUI

struct AccountView: View { var body: some View { Text("Account") } }
final class AccountViewModel {}
final class AuthenticationManager {}
final class AuthManager {}
final class AuthViewModel {}
final class PaymentManager {}
final class PurchaseManager {}
final class PurchaseService {}

enum ExternalPushSigningResidue {
  static let proxyFlag = "FirebaseAppDelegateProxyEnabled"
  static let plistBucket = "GoogleServicePLists"
}
