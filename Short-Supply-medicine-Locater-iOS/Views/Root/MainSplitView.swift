//
//  MainSplitView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// iPad (regular width): sidebar on the left, the chosen section on the right.
struct MainSplitView: View {
    @Binding var selection: AppSection
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List(selection: sidebarSelection) {
                ForEach(AppSection.allCases) { section in
                    NavigationLink(value: section) {
                        Label(section.title, systemImage: section.systemImage)
                    }
                }
            }
            .navigationTitle("Medicine Locator")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            // Detail: the same screens as the iPhone tabs, each with its own navigation stack
            NavigationStack {
                SectionRootView(section: selection)
            }
            .id(selection)        // fresh stack when switching section (no leftover pushed screens)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(Theme.accent)
    }

    /// The sidebar List needs an optional selection; the app always has a section.
    private var sidebarSelection: Binding<AppSection?> {
        Binding(
            get: { selection },
            set: { newValue in
                if let newValue { selection = newValue }
            }
        )
    }
}