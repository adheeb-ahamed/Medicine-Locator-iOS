//
//  AppSectionTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import SwiftUI
@testable import Short_Supply_medicine_Locater_iOS

struct AppSectionTests {

    @Test func wideScreensUseTheSidebar() {
        #expect(AdaptiveLayout.usesSplitView(.regular))
    }

    @Test(arguments: [UserInterfaceSizeClass.compact, nil])
    func narrowScreensUseTabs(sizeClass: UserInterfaceSizeClass?) {
        #expect(!AdaptiveLayout.usesSplitView(sizeClass))
    }

    @Test func savedSectionNamesNeverChange() {
        // @SceneStorage saves these strings — renaming one would lose the user's saved tab.
        #expect(AppSection.allCases.map(\.rawValue) == ["home", "help", "map", "requests", "profile"])
    }

    @Test func everySectionHasATitleAndIcon() {
        for section in AppSection.allCases {
            #expect(!section.title.isEmpty)
            #expect(!section.tabTitle.isEmpty)
            #expect(!section.systemImage.isEmpty)
        }
        #expect(Set(AppSection.allCases.map(\.title)).count == AppSection.allCases.count)   // no duplicates
    }
}
