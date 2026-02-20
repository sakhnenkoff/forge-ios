//
//  AppSheet.swift
//  Forge
//
//
//

import SwiftUI
import AppRouter

enum AppSheet: SheetType {
    case paywall
    case settings
    case debug

    var id: Int {
        hashValue
    }
}
