//
//  PushRouteParser.swift
//  Forge
//
//
//

import Foundation

struct PushRouteParser {

    struct Navigation {
        let tab: AppTab?
        let route: AppRoute?
        let sheet: AppSheet?
        let deepLink: URL?
        let rawTab: String?
        let rawRoute: String?
        let rawSheet: String?
        let rawDeepLink: String?
        let parameters: [String: String]

        var eventParameters: [String: Any] {
            var data: [String: Any] = [:]
            if let rawTab {
                data["tab"] = rawTab
            }
            if let rawRoute {
                data["route"] = rawRoute
            }
            if let rawSheet {
                data["sheet"] = rawSheet
            }
            if let rawDeepLink {
                data["deep_link"] = rawDeepLink
            }
            if !parameters.isEmpty {
                data["params"] = parameters
            }
            return data
        }
    }

    private enum Keys {
        static let tab = "tab"
        static let route = "route"
        static let screen = "screen"
        static let sheet = "sheet"
        static let deepLink = "deep_link"
        static let deepLinkAlt = "deeplink"
        static let url = "url"
        static let params = "params"
    }

    static func parse(userInfo: [AnyHashable: Any]) -> Navigation? {
        let stringValues = normalizedStrings(from: userInfo)
        let parameters = extractParameters(from: userInfo, stringValues: stringValues)

        let rawDeepLink = stringValues[Keys.deepLink] ?? stringValues[Keys.deepLinkAlt] ?? stringValues[Keys.url]
        let deepLink = rawDeepLink.flatMap { URL(string: $0) }

        let rawRoute = stringValues[Keys.route] ?? stringValues[Keys.screen]
        let route = rawRoute.flatMap { AppRoute.from(path: $0, fullPath: [], parameters: parameters) }

        let rawSheet = stringValues[Keys.sheet]
        let sheet = rawSheet.flatMap { mapSheet($0) }

        let rawTab = stringValues[Keys.tab]
        let tab = rawTab.flatMap { AppTab(rawValue: $0.lowercased()) }

        if deepLink == nil && route == nil && sheet == nil && tab == nil {
            return nil
        }

        return Navigation(
            tab: tab,
            route: route,
            sheet: sheet,
            deepLink: deepLink,
            rawTab: rawTab,
            rawRoute: rawRoute,
            rawSheet: rawSheet,
            rawDeepLink: rawDeepLink,
            parameters: parameters
        )
    }

    private static func normalizedStrings(from userInfo: [AnyHashable: Any]) -> [String: String] {
        userInfo.reduce(into: [String: String]()) { result, item in
            guard let key = item.key as? String else { return }
            if let value = item.value as? String {
                result[key] = value
            }
        }
    }

    private static func extractParameters(from userInfo: [AnyHashable: Any], stringValues: [String: String]) -> [String: String] {
        if let params = userInfo[Keys.params] as? [String: String] {
            return params
        }
        if let params = userInfo[Keys.params] as? [AnyHashable: Any] {
            var result: [String: String] = [:]
            for (key, value) in params {
                guard let key = key as? String, let value = value as? String else { continue }
                result[key] = value
            }
            if !result.isEmpty {
                return result
            }
        }

        let reserved: Set<String> = [
            Keys.tab,
            Keys.route,
            Keys.screen,
            Keys.sheet,
            Keys.deepLink,
            Keys.deepLinkAlt,
            Keys.url,
            Keys.params
        ]

        var fallback: [String: String] = [:]
        for (key, value) in stringValues where !reserved.contains(key) {
            fallback[key] = value
        }
        return fallback
    }

    private static func mapSheet(_ value: String) -> AppSheet? {
        switch value.lowercased() {
        case "paywall":
            return .paywall
        case "settings":
            return .settings
        case "debug":
            return .debug
        default:
            return nil
        }
    }
}
