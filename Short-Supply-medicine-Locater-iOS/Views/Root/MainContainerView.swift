//
//  MainContainerView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// Picks tabs (iPhone) or sidebar (iPad) and adds what both share:
/// the offline banner and the background answer check.
struct MainContainerView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Remembered by iOS — reopening the app returns to the same section.
    @SceneStorage("selectedSection") private var selection: AppSection = .home
    private let router = IntentRouter.shared   // Siri asks to open a section

    var body: some View {
        VStack(spacing: 0) {
            if !services.connectivity.isOnline {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if AdaptiveLayout.usesSplitView(horizontalSizeClass) {
                MainSplitView(selection: $selection)
            } else {
                MainTabView(selection: $selection)
            }
        }
        .animation(.default, value: services.connectivity.isOnline)
        // initial: true → also runs when this view first appears.
        // That matters when Siri launched the app, or the app was locked with Face ID:
        // the request waits in the router until this screen exists.
        .onChange(of: router.pendingSection, initial: true) { _, section in
            if let section {
                selection = section           // switch tab (iPhone) / sidebar (iPad)
                router.pendingSection = nil   // done — don't do it again
            }
        }
        .task {
            // Phase 7: check for new answers every 60 s while the app is open
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await services.answerWatcher.checkForNewAnswers()
            }
        }
    }
}
