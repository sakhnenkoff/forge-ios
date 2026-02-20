//
//  AuthAdapters.swift
//  Forge
//
//  Local authentication adapters.
//

import AuthenticationServices
import CryptoKit
import Security
import FirebaseAuth
import GoogleSignIn
import UIKit

public struct UserAuthInfo: Sendable {
    public let uid: String
    public let email: String?
    public let isAnonymous: Bool?
    public let authProviders: [SignInOption]
    public let displayName: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let photoURL: URL?
    public let creationDate: Date?
    public let lastSignInDate: Date?

    public init(
        uid: String,
        email: String?,
        isAnonymous: Bool?,
        authProviders: [SignInOption],
        displayName: String?,
        firstName: String?,
        lastName: String?,
        phoneNumber: String?,
        photoURL: URL?,
        creationDate: Date?,
        lastSignInDate: Date?
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }

    init(user: User, fullName: PersonNameComponents? = nil) {
        let providers = user.providerData.map { SignInOption.from(providerId: $0.providerID) }
        var fullNameComponents = fullName
        if fullNameComponents == nil, let displayName = user.displayName {
            fullNameComponents = PersonNameComponentsFormatter().personNameComponents(from: displayName)
        }

        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.authProviders = providers.isEmpty ? [SignInOption.anonymous] : providers
        self.displayName = user.displayName
        self.firstName = fullNameComponents?.givenName
        self.lastName = fullNameComponents?.familyName
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}

public struct SignInOption: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String
    public let googleClientID: String?

    public init(rawValue: String) {
        self.rawValue = rawValue
        self.googleClientID = nil
    }

    public init(rawValue: String, googleClientID: String?) {
        self.rawValue = rawValue
        self.googleClientID = googleClientID
    }

    static let apple = SignInOption(rawValue: "apple.com")
    static let google = SignInOption(rawValue: "google.com")
    static let email = SignInOption(rawValue: "password")
    static let anonymous = SignInOption(rawValue: "anonymous")

    static func google(GIDClientID: String) -> SignInOption {
        SignInOption(rawValue: "google.com", googleClientID: GIDClientID)
    }

    static func from(providerId: String) -> SignInOption {
        switch providerId {
        case SignInOption.apple.rawValue:
            return .apple
        case SignInOption.google.rawValue:
            return .google
        case SignInOption.email.rawValue:
            return .email
        case SignInOption.anonymous.rawValue:
            return .anonymous
        default:
            return SignInOption(rawValue: providerId)
        }
    }

    public static func == (lhs: SignInOption, rhs: SignInOption) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

typealias AuthResult = (user: UserAuthInfo, isNewUser: Bool)

enum AuthLogType {
    case info
    case analytic
    case warning
    case severe
}

protocol AuthLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: AuthLogType { get }
}

protocol AuthLogger {
    func trackEvent(event: any AuthLogEvent)
}

@MainActor
protocol AuthService {
    var currentUser: UserAuthInfo? { get }
    func signInApple() async throws -> AuthResult
    func signInGoogle(GIDClientID: String) async throws -> AuthResult
    func signInAnonymously() async throws -> AuthResult
    func signOut() throws
    func deleteAccountWithReauthentication(
        option: SignInOption,
        revokeToken: Bool,
        onDelete: @escaping () async throws -> Void
    ) async throws
}

@MainActor
final class AuthManager {
    private let service: AuthService
    private let logger: AuthLogger?

    var auth: UserAuthInfo? {
        service.currentUser
    }

    init(service: AuthService, logger: AuthLogger? = nil) {
        self.service = service
        self.logger = logger
    }

    func signInApple() async throws -> AuthResult {
        try await service.signInApple()
    }

    func signInGoogle(GIDClientID: String) async throws -> AuthResult {
        try await service.signInGoogle(GIDClientID: GIDClientID)
    }

    func signInAnonymously() async throws -> AuthResult {
        try await service.signInAnonymously()
    }

    func signOut() throws {
        try service.signOut()
    }

    func deleteAccountWithReauthentication(
        option: SignInOption,
        revokeToken: Bool,
        onDelete: @escaping () async throws -> Void
    ) async throws {
        try await service.deleteAccountWithReauthentication(
            option: option,
            revokeToken: revokeToken,
            onDelete: onDelete
        )
    }
}

@MainActor
final class FirebaseAuthService: NSObject, AuthService {
    private let appleCoordinator = AppleSignInCoordinator()

    var currentUser: UserAuthInfo? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserAuthInfo(user: user)
    }

    func signInApple() async throws -> AuthResult {
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let credential = try await appleCoordinator.signIn(request: request)
        guard let idToken = credential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8)
        else {
            throw AuthError.invalidAppleToken
        }

        let oauthCredential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
        let result = try await Auth.auth().signIn(with: oauthCredential)
        let authInfo = UserAuthInfo(user: result.user, fullName: credential.fullName)
        return (user: authInfo, isNewUser: result.additionalUserInfo?.isNewUser ?? false)
    }

    func signInGoogle(GIDClientID: String) async throws -> AuthResult {
        guard let presenting = UIApplication.shared.topMostViewController else {
            throw AuthError.missingPresentationContext
        }
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.invalidGoogleToken
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        return (user: UserAuthInfo(user: authResult.user), isNewUser: authResult.additionalUserInfo?.isNewUser ?? false)
    }

    func signInAnonymously() async throws -> AuthResult {
        let result = try await Auth.auth().signInAnonymously()
        return (user: UserAuthInfo(user: result.user), isNewUser: result.additionalUserInfo?.isNewUser ?? false)
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    func deleteAccountWithReauthentication(
        option: SignInOption,
        revokeToken: Bool,
        onDelete: @escaping () async throws -> Void
    ) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.missingCurrentUser
        }

        switch option.rawValue {
        case SignInOption.apple.rawValue:
            let credential = try await makeAppleCredential()
            _ = try await user.reauthenticate(with: credential)
        case SignInOption.google.rawValue:
            let credential = try await makeGoogleCredential(clientID: option.googleClientID)
            _ = try await user.reauthenticate(with: credential)
            if revokeToken {
                await revokeGoogleAccess()
            }
        case SignInOption.anonymous.rawValue:
            break
        case SignInOption.email.rawValue:
            throw AuthError.unsupportedReauthentication
        default:
            throw AuthError.unsupportedReauthentication
        }

        try await onDelete()
        try await user.delete()
    }

    enum AuthError: LocalizedError, CustomNSError {
        case invalidAppleToken
        case invalidGoogleToken
        case missingPresentationContext
        case missingGoogleClientId
        case missingCurrentUser
        case unsupportedReauthentication
        case networkError(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .invalidAppleToken:
                return "Unable to read Apple identity token"
            case .invalidGoogleToken:
                return "Unable to read Google identity token"
            case .missingPresentationContext:
                return "Missing presentation context"
            case .missingGoogleClientId:
                return "Missing Google client id"
            case .missingCurrentUser:
                return "Missing current user"
            case .unsupportedReauthentication:
                return "Unsupported reauthentication provider"
            case .networkError:
                return "Network error occurred during authentication"
            }
        }

        static var errorDomain: String { "AuthErrorDomain" }

        var errorCode: Int {
            switch self {
            case .invalidAppleToken: return 1001
            case .invalidGoogleToken: return 1002
            case .missingPresentationContext: return 1003
            case .missingGoogleClientId: return 1004
            case .missingCurrentUser: return 1005
            case .unsupportedReauthentication: return 1006
            case .networkError: return 1007
            }
        }

        var errorUserInfo: [String: Any] {
            var userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorDescription ?? ""]
            if let underlying = underlyingError {
                userInfo[NSUnderlyingErrorKey] = underlying
            }
            return userInfo
        }

        var underlyingError: Error? {
            switch self {
            case .networkError(let error):
                return error
            default:
                return nil
            }
        }
    }

    private func makeAppleCredential() async throws -> AuthCredential {
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let credential = try await appleCoordinator.signIn(request: request)
        guard let idToken = credential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8)
        else {
            throw AuthError.invalidAppleToken
        }

        return OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
    }

    private func makeGoogleCredential(clientID: String?) async throws -> AuthCredential {
        guard let presenting = UIApplication.shared.topMostViewController else {
            throw AuthError.missingPresentationContext
        }
        let resolvedClientId = clientID ?? GIDSignIn.sharedInstance.configuration?.clientID
        guard let resolvedClientId, !resolvedClientId.isEmpty else {
            throw AuthError.missingGoogleClientId
        }

        let config = GIDConfiguration(clientID: resolvedClientId)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidGoogleToken
        }

        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
    }

    private func revokeGoogleAccess() async {
        await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.disconnect { _ in
                continuation.resume()
            }
        }
    }
}

@MainActor
final class MockAuthService: AuthService {
    private var user: UserAuthInfo?

    init(user: UserAuthInfo? = nil) {
        self.user = user
    }

    var currentUser: UserAuthInfo? {
        user
    }

    func signInApple() async throws -> AuthResult {
        let user = MockAuthService.makeMockUser(isAnonymous: false)
        self.user = user
        return (user: user, isNewUser: false)
    }

    func signInGoogle(GIDClientID: String) async throws -> AuthResult {
        let user = MockAuthService.makeMockUser(isAnonymous: false)
        self.user = user
        return (user: user, isNewUser: false)
    }

    func signInAnonymously() async throws -> AuthResult {
        let user = MockAuthService.makeMockUser(isAnonymous: true)
        self.user = user
        return (user: user, isNewUser: false)
    }

    func signOut() throws {
        user = nil
    }

    func deleteAccountWithReauthentication(
        option: SignInOption,
        revokeToken: Bool,
        onDelete: @escaping () async throws -> Void
    ) async throws {
        _ = option
        _ = revokeToken
        try await onDelete()
        user = nil
    }

    private static func makeMockUser(isAnonymous: Bool) -> UserAuthInfo {
        UserAuthInfo(
            uid: UUID().uuidString,
            email: isAnonymous ? nil : "demo@example.com",
            isAnonymous: isAnonymous,
            authProviders: isAnonymous ? [.anonymous] : [.apple],
            displayName: isAnonymous ? nil : "Demo User",
            firstName: isAnonymous ? nil : "Demo",
            lastName: isAnonymous ? nil : "User",
            phoneNumber: nil,
            photoURL: nil,
            creationDate: Date(),
            lastSignInDate: Date()
        )
    }
}

@MainActor
private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    func signIn(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.invalidAppleToken)
            continuation = nil
            return
        }
        continuation?.resume(returning: credential)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            return UIWindow(windowScene: scene)
        }
        preconditionFailure("Missing window scene for Apple Sign In presentation.")
    }

    private enum AuthError: LocalizedError {
        case invalidAppleToken
    }
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        var randoms = [UInt8](repeating: 0, count: 16)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.map { String(format: "%02x", $0) }.joined()
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    var topMostViewController: UIViewController? {
        guard let root = keyWindow?.rootViewController else { return nil }
        return UIApplication.topViewController(for: root)
    }

    static func topViewController(for root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(for: presented)
        }
        if let nav = root as? UINavigationController, let visible = nav.visibleViewController {
            return topViewController(for: visible)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(for: selected)
        }
        return root
    }
}

extension UserAuthInfo {
    static func mock() -> UserAuthInfo {
        UserAuthInfo(
            uid: UUID().uuidString,
            email: "demo@example.com",
            isAnonymous: false,
            authProviders: [.apple],
            displayName: "Demo User",
            firstName: "Demo",
            lastName: "User",
            phoneNumber: nil,
            photoURL: nil,
            creationDate: Date(),
            lastSignInDate: Date()
        )
    }
}

extension AuthLogType {
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
}

extension LogManager: AuthLogger {
    public func trackEvent(event: any AuthLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
