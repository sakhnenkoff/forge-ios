//
//  PurchaseAdapters.swift
//  Forge
//
//  Local purchasing adapters.
//

import Foundation
import RevenueCat
import StoreKit

struct PurchaseProfileAttributes {
    let email: String?
    let mixpanelDistinctId: String?
    let firebaseAppInstanceId: String?
}

struct PurchasedEntitlement: Identifiable, Sendable {
    let id: String
    let productId: String?
    let isActive: Bool
    let expirationDate: Date?
}

extension Array where Element == PurchasedEntitlement {
    var hasActiveEntitlement: Bool {
        contains { $0.isActive }
    }
}

struct AnyProduct: Identifiable, Sendable {
    let id: String
    let title: String
    let details: String
    let price: Decimal
    let currencyCode: String?
    let priceString: String
    let subscriptionPeriodValue: Int?
    let subscriptionPeriodUnit: SubscriptionUnit?

    init(storeKitProduct: StoreKit.Product) {
        self.id = storeKitProduct.id
        self.title = storeKitProduct.displayName
        self.details = storeKitProduct.description
        self.price = storeKitProduct.price
        self.currencyCode = storeKitProduct.priceFormatStyle.currencyCode
        self.priceString = storeKitProduct.displayPrice
        if let period = storeKitProduct.subscription?.subscriptionPeriod {
            self.subscriptionPeriodValue = period.value
            self.subscriptionPeriodUnit = SubscriptionUnit(storeKitUnit: period.unit)
        } else {
            self.subscriptionPeriodValue = nil
            self.subscriptionPeriodUnit = nil
        }
    }

    init(id: String, title: String, details: String, price: Decimal, currencyCode: String?) {
        self.id = id
        self.title = title
        self.details = details
        self.price = price
        self.currencyCode = currencyCode
        self.priceString = Self.formatPrice(price: price, currencyCode: currencyCode)
        self.subscriptionPeriodValue = nil
        self.subscriptionPeriodUnit = nil
    }

    init(revenueCatProduct: StoreProduct) {
        self.id = revenueCatProduct.productIdentifier
        self.title = revenueCatProduct.localizedTitle
        self.details = revenueCatProduct.localizedDescription
        self.price = revenueCatProduct.price
        self.currencyCode = revenueCatProduct.currencyCode
        self.priceString = revenueCatProduct.localizedPriceString
        if let period = revenueCatProduct.subscriptionPeriod {
            self.subscriptionPeriodValue = period.value
            self.subscriptionPeriodUnit = SubscriptionUnit(revenueCatUnit: period.unit)
        } else {
            self.subscriptionPeriodValue = nil
            self.subscriptionPeriodUnit = nil
        }
    }

    var subtitle: String {
        details
    }

    var priceStringWithDuration: String {
        guard let value = subscriptionPeriodValue,
              let unit = subscriptionPeriodUnit else {
            return priceString
        }
        let unitText = value == 1 ? unit.singular : "\(value) \(unit.plural)"
        return "\(priceString) / \(unitText)"
    }

    var eventParameters: [String: Any] {
        [
            "product_id": id,
            "product_title": title,
            "product_price": price as NSDecimalNumber,
            "product_currency": currencyCode as Any
        ]
    }
}

enum SubscriptionUnit: Sendable {
    case day
    case week
    case month
    case year

    init?(storeKitUnit unit: StoreKit.Product.SubscriptionPeriod.Unit) {
        switch unit {
        case .day:
            self = .day
        case .week:
            self = .week
        case .month:
            self = .month
        case .year:
            self = .year
        @unknown default:
            return nil
        }
    }

    init?(revenueCatUnit unit: RevenueCat.SubscriptionPeriod.Unit) {
        switch unit {
        case .day:
            self = .day
        case .week:
            self = .week
        case .month:
            self = .month
        case .year:
            self = .year
        @unknown default:
            return nil
        }
    }

    var singular: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }

    var plural: String {
        switch self {
        case .day:
            return "days"
        case .week:
            return "weeks"
        case .month:
            return "months"
        case .year:
            return "years"
        }
    }
}

extension AnyProduct {
    private static func formatPrice(price: Decimal, currencyCode: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode {
            formatter.currencyCode = currencyCode
        }
        return formatter.string(from: price as NSDecimalNumber) ?? "\(price)"
    }
}

extension AnyProduct {
    static var mocks: [AnyProduct] {
        [
            AnyProduct(
                id: "mock.monthly",
                title: "Monthly",
                details: "Monthly premium access",
                price: 9.99,
                currencyCode: "USD"
            ),
            AnyProduct(
                id: "mock.yearly",
                title: "Yearly",
                details: "Yearly premium access",
                price: 59.99,
                currencyCode: "USD"
            )
        ]
    }
}

enum PurchaseLogType {
    case info
    case analytic
    case warning
    case severe
}

protocol PurchaseLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: PurchaseLogType { get }
}

protocol PurchaseLogger {
    func trackEvent(event: any PurchaseLogEvent)
}

@MainActor
protocol PurchaseService {
    var entitlements: [PurchasedEntitlement] { get }
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func purchase(productId: String) async throws -> [PurchasedEntitlement]
    func restore() async throws -> [PurchasedEntitlement]
    func logIn(userId: String, attributes: PurchaseProfileAttributes?) async throws -> [PurchasedEntitlement]
    func logOut() async throws
}

@MainActor
final class PurchaseManager {
    private let service: PurchaseService
    private let logger: PurchaseLogger?
    private var currentEntitlements: [PurchasedEntitlement]

    var entitlements: [PurchasedEntitlement] {
        currentEntitlements
    }

    init(service: PurchaseService, logger: PurchaseLogger? = nil) {
        self.service = service
        self.logger = logger
        self.currentEntitlements = service.entitlements
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await service.getProducts(productIds: productIds)
    }

    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let entitlements = try await service.purchase(productId: productId)
        currentEntitlements = entitlements
        return entitlements
    }

    func restorePurchase() async throws -> [PurchasedEntitlement] {
        let entitlements = try await service.restore()
        currentEntitlements = entitlements
        return entitlements
    }

    func logIn(userId: String, userAttributes: PurchaseProfileAttributes) async throws -> [PurchasedEntitlement] {
        let entitlements = try await service.logIn(userId: userId, attributes: userAttributes)
        currentEntitlements = entitlements
        return entitlements
    }

    func logOut() async throws {
        try await service.logOut()
        currentEntitlements = []
    }
}

@MainActor
final class RevenueCatPurchaseService: PurchaseService {
    @MainActor private static var isConfigured = false
    private(set) var entitlements: [PurchasedEntitlement] = []

    init(apiKey: String) {
        if !Self.isConfigured {
            Purchases.configure(withAPIKey: apiKey)
            Self.isConfigured = true
        }
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = await Purchases.shared.products(productIds)
        return products.map { AnyProduct(revenueCatProduct: $0) }
    }

    func purchase(productId: String) async throws -> [PurchasedEntitlement] {
        let storeProducts = await Purchases.shared.products([productId])
        guard let storeProduct = storeProducts.first else {
            throw PurchaseError.productNotFound
        }
        let customerInfo = try await purchase(storeProduct: storeProduct)
        let mapped = mapEntitlements(customerInfo)
        entitlements = mapped
        return mapped
    }

    func restore() async throws -> [PurchasedEntitlement] {
        do {
            let info = try await Purchases.shared.restorePurchases()
            let mapped = mapEntitlements(info)
            entitlements = mapped
            return mapped
        } catch {
            throw PurchaseError.restoreFailed(underlying: error)
        }
    }

    func logIn(userId: String, attributes: PurchaseProfileAttributes?) async throws -> [PurchasedEntitlement] {
        do {
            if let attributes {
                var collected: [String: String] = [:]
                if let email = attributes.email { collected["email"] = email }
                if let mixpanelDistinctId = attributes.mixpanelDistinctId { collected["mixpanel_distinct_id"] = mixpanelDistinctId }
                if let firebaseAppInstanceId = attributes.firebaseAppInstanceId { collected["firebase_app_instance_id"] = firebaseAppInstanceId }
                Purchases.shared.attribution.setAttributes(collected)
            }

            let (info, _) = try await Purchases.shared.logIn(userId)
            let mapped = mapEntitlements(info)
            entitlements = mapped
            return mapped
        } catch {
            throw PurchaseError.revenueCatError(underlying: error)
        }
    }

    func logOut() async throws {
        do {
            _ = try await Purchases.shared.logOut()
        } catch {
            throw PurchaseError.revenueCatError(underlying: error)
        }
    }

    private func purchase(storeProduct: StoreProduct) async throws -> CustomerInfo {
        let (_, info, userCancelled) = try await Purchases.shared.purchase(product: storeProduct)
        if userCancelled {
            throw PurchaseError.userCancelled
        }
        return info
    }

    private func mapEntitlements(_ info: CustomerInfo) -> [PurchasedEntitlement] {
        info.entitlements.all.values.map {
            PurchasedEntitlement(
                id: $0.identifier,
                productId: $0.productIdentifier,
                isActive: $0.isActive,
                expirationDate: $0.expirationDate
            )
        }
    }

    enum PurchaseError: LocalizedError, CustomNSError {
        case productNotFound
        case userCancelled
        case unknown
        case revenueCatError(underlying: Error)
        case restoreFailed(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Product not found"
            case .userCancelled:
                return "Purchase cancelled"
            case .unknown:
                return "Purchase failed"
            case .revenueCatError:
                return "Purchase service error"
            case .restoreFailed:
                return "Failed to restore purchases"
            }
        }

        static var errorDomain: String { "PurchaseErrorDomain" }

        var errorCode: Int {
            switch self {
            case .productNotFound: return 3001
            case .userCancelled: return 3002
            case .unknown: return 3003
            case .revenueCatError: return 3004
            case .restoreFailed: return 3005
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
            case .revenueCatError(let error),
                 .restoreFailed(let error):
                return error
            default:
                return nil
            }
        }
    }
}

@MainActor
final class MockPurchaseService: PurchaseService {
    private(set) var entitlements: [PurchasedEntitlement]

    init(entitlements: [PurchasedEntitlement] = []) {
        self.entitlements = entitlements
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        productIds.map {
            AnyProduct(
                id: $0,
                title: "Mock \($0)",
                details: "Mock product",
                price: 0.0,
                currencyCode: "USD"
            )
        }
    }

    func purchase(productId: String) async throws -> [PurchasedEntitlement] {
        let entitlement = PurchasedEntitlement(id: productId, productId: productId, isActive: true, expirationDate: nil)
        entitlements = [entitlement]
        return entitlements
    }

    func restore() async throws -> [PurchasedEntitlement] {
        entitlements
    }

    func logIn(userId: String, attributes: PurchaseProfileAttributes?) async throws -> [PurchasedEntitlement] {
        entitlements
    }

    func logOut() async throws {
        entitlements = []
    }
}

extension PurchaseLogType {
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

extension LogManager: PurchaseLogger {
    public func trackEvent(event: any PurchaseLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
