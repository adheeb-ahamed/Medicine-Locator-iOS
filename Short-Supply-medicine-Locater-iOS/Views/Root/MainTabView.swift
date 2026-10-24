//
//  MainTabView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// iPhone (compact width): a tab bar built from AppSection.
struct MainTabView: View {
    @Binding var selection: AppSection

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    SectionRootView(section: section)
                }
                .tabItem { Label(section.tabTitle, systemImage: section.systemImage) }
                .tag(section)
            }
        }
        .tint(Theme.accent)
    }
}
