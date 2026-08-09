//
//  AuthenticationViewModelTests.swift
//  ClosetAITests
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

@MainActor
final class AuthenticationViewModelTests: XCTestCase {

    private var authenticationService: MockAuthenticationService!
    private var tokenStore: MockTokenStore!
    private var sessionManager: SessionManager!
    private var appleProvider: MockAppleAuthenticationProvider!
    private var viewModel: AuthenticationViewModel!

    override func setUp() {
        super.setUp()

        authenticationService = MockAuthenticationService()
        tokenStore = MockTokenStore()

        sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        appleProvider = MockAppleAuthenticationProvider()

        viewModel = AuthenticationViewModel(
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleProvider
        )
    }

    override func tearDown() {
        authenticationService.reset()
        tokenStore.reset()
        appleProvider.reset()

        viewModel = nil
        sessionManager = nil
        appleProvider = nil
        tokenStore = nil
        authenticationService = nil

        super.tearDown()
    }

    // MARK: - Successful Sign In

    func testSignInWithAppleSuccessAuthenticatesUser() async {
        appleProvider.credential = AppleAuthenticationCredential(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        authenticationService.signInResponse =
            AuthenticationResponse(
                accessToken: "access-token",
                refreshToken: "refresh-token",
                expiresIn: 3600
            )

        await viewModel.signInWithApple()

        XCTAssertEqual(
            appleProvider.signInCallCount,
            1
        )

        XCTAssertEqual(
            authenticationService.signInCallCount,
            1
        )

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        XCTAssertFalse(
            viewModel.isSigningIn
        )

        XCTAssertNil(
            viewModel.errorMessage
        )
    }

    // MARK: - Apple Authentication Failure

    func testSignInWithAppleFailureShowsError() async {
        appleProvider.error =
            TestAuthenticationError.failed

        await viewModel.signInWithApple()

        XCTAssertEqual(
            appleProvider.signInCallCount,
            1
        )

        XCTAssertEqual(
            authenticationService.signInCallCount,
            0
        )

        XCTAssertFalse(
            viewModel.isSigningIn
        )

        XCTAssertEqual(
            viewModel.errorMessage,
            "Sign in with Apple failed. Please try again."
        )
    }

    // MARK: - Backend Authentication Failure

    func testBackendAuthenticationFailureShowsError() async {
        appleProvider.credential = AppleAuthenticationCredential(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        authenticationService.signInError =
            TestAuthenticationError.failed

        await viewModel.signInWithApple()

        XCTAssertEqual(
            appleProvider.signInCallCount,
            1
        )

        XCTAssertEqual(
            authenticationService.signInCallCount,
            1
        )

        XCTAssertFalse(
            viewModel.isSigningIn
        )

        XCTAssertEqual(
            viewModel.errorMessage,
            "Unable to sign in. Please try again."
        )
    }

    // MARK: - Duplicate Sign In

    func testDuplicateSignInIsIgnoredWhileSigningIn() async {
        appleProvider.credential = AppleAuthenticationCredential(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        authenticationService.signInResponse =
            AuthenticationResponse(
                accessToken: "access-token",
                refreshToken: "refresh-token",
                expiresIn: 3600
            )

        await viewModel.signInWithApple()
        await viewModel.signInWithApple()

        XCTAssertEqual(
            appleProvider.signInCallCount,
            2
        )
    }

    // MARK: - Clear Error

    func testClearErrorRemovesErrorMessage() async {
        appleProvider.error =
            TestAuthenticationError.failed

        await viewModel.signInWithApple()

        XCTAssertNotNil(
            viewModel.errorMessage
        )

        viewModel.clearError()

        XCTAssertNil(
            viewModel.errorMessage
        )
    }
}

// MARK: - Test Error

private enum TestAuthenticationError:
    Error,
    Equatable {

    case failed
}
