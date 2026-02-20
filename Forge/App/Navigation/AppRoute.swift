//
//  AppRoute.swift
//  Forge
//
//

import SwiftUI
import AppRouter

enum AppRoute: DestinationType {
    case settingsDetail

    static func from(path: String, fullPath: [String], parameters: [String: String]) -> AppRoute? {
        switch path {
        case "settings":
            return .settingsDetail
        default:
            return nil
        }
    }
}
