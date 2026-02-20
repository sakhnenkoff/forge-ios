import Foundation

public struct Authorization {
    public let type: AuthorizationType
    public let token: String

    public init(type: AuthorizationType, token: String) {
        self.type = type
        self.token = token
    }

    public var headerValue: String {
        switch type {
        case .bearer:
            return "Bearer \(token)"
        case .basic:
            return "Basic \(token)"
        case .apiKey:
            return token
        }
    }

    public var headerKey: String {
        switch type {
        case .bearer, .basic:
            return "Authorization"
        case .apiKey(let keyName):
            return keyName
        }
    }
}

public enum AuthorizationType {
    case bearer
    case basic
    case apiKey(keyName: String)
}
