//
//  AuthViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct AuthViewModelTests {

    @Test(arguments: ["ad@example.com", "  AD@Example.com "])
    func acceptsValidEmails(_ email: String) {
        let vm = AuthViewModel(authService: MockAuthService())
        vm.email = email
        #expect(vm.isValidEmail)
    }

    @Test(arguments: ["", "ad", "ad@", "ad@example", "a@b@c.com"])
    func rejectsInvalidEmails(_ email: String) {
        let vm = AuthViewModel(authService: MockAuthService())
        vm.email = email
        #expect(!vm.isValidEmail)
    }

    @Test func shortPasswordIsRejected() {
        let vm = AuthViewModel(authService: MockAuthService())
        vm.email = "ad@example.com"
        vm.password = "12345"
        #expect(!vm.canSignIn)
    }

    @Test func createAccountNeedsMatchingPasswords() {
        let vm = AuthViewModel(authService: MockAuthService())
        vm.email = "ad@example.com"
        vm.password = "secret1"
        vm.confirmPassword = "secret2"
        #expect(!vm.canCreateAccount)
        vm.confirmPassword = "secret1"
        #expect(vm.canCreateAccount)
    }
}
