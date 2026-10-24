//
//  AppSection.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// The five top-level areas of the app.
/// BOTH the iPhone tab bar and the iPad sidebar are built from this one list.
enum AppSection: String, CaseIterable, Identifiable {
    case home, help, map, requests, profile

    var id: String { rawValue }

    /// Full name (iPad sidebar).
    var title: String {
        switch self {
        case .home:     "Home"
        case .help:     "Help nearby"
        case .map:      "Map"
        case .requests: "My Requests"
        case .profile:  "Profile"
        }
    }

    /// Short name (iPhone tab bar has little space).
    var tabTitle: String {
        self == .help ? "Help" : title
    }

    var systemImage: String {
        switch self {
        case .home:     "house"
        case .help:     "hand.raised"
        case .map:      "map"
        case .requests: "tray.full"
        case .profile:  "person.crop.circle"
        }
    }
}

/// Which layout to use. Based on available WIDTH, not on "is this an iPad?".
enum AdaptiveLayout {
    static func usesSplitView(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        horizontalSizeClass == .regular
    }
}