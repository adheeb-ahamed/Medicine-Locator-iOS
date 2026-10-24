//
//  AccountViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct AccountViewModelTests {

    private func makeSUT() -> (AccountViewModel, MockAuthService, MockUserService,
                               MockSearchHistoryService, MockSourceCache) {
        let auth = MockAuthService()
        auth.currentUserID = "me"
        let users = MockUserService()
        let history = MockSearchHistoryService()
        history.record("Imatinib")
        let cache = MockSourceCache()
        cache.saved["medicine:imatinib"] = []
        let vm = AccountViewModel(authService: auth, userService: users,
                                  searchHistory: history, sourceCache: cache)
        return (vm, auth, users, history, cache)
    }

    @Test func deletingRemovesProfileSignInAndLocalData() async {
        let (vm, auth, users, history, cache) = makeSUT()
        let ok = await vm.deleteAccount()

        #expect(ok)
        #expect(users.deletedUIDs == ["me"])
        #expect(auth.didDelete)
        #expect(history.recentSearches().isEmpty)
        #expect(cache.saved.isEmpty)
    }

    @Test func recentLoginErrorIsShownAndLocalDataKept() async {
        let (vm, auth, _, history, _) = makeSUT()
        auth.deleteError = AccountError.requiresRecentLogin

        let ok = await vm.deleteAccount()

        #expect(!ok)
        #expect(vm.errorMessage?.contains("sign in again") == true)
        #expect(!history.recentSearches().isEmpty)      // nothing local was wiped
    }
}