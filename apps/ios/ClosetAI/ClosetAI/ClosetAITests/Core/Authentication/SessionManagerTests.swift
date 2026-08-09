//
//  SessionManagerTests.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

@MainActor
final class SessionManagerTests: XCTestCase {

    private var authenticationService: MockAuthenticationService!
    private var tokenStore: MockTokenStore!
    private var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()

        authenticationService = MockAuthenticationService()
        tokenStore = MockTokenStore()

        sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )
    }

    override func tearDown() {
        authenticationService.reset()
        tokenStore.reset()

        sessionManager = nil
        tokenStore = nil
        authenticationService = nil

        super.tearDown()
    }

    // MARK: - Restore Session

    func testRestoreSessionWithoutTokensBecomesUnauthenticated() {
        sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )
    }

    func testRestoreSessionWithTokensBecomesAuthenticated() throws {
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )
    }

    // MARK: - Sign In with Apple

    func testSignInWithAppleSuccessStoresTokensAndAuthenticates() async {
        authenticationService.signInResponse =
            AuthenticationResponse(
                accessToken: "access-token",
                refreshToken: "refresh-token",
                expiresIn: 3600
            )

        await sessionManager.signInWithApple(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        XCTAssertEqual(
            authenticationService.signInCallCount,
            1
        )

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        XCTAssertEqual(
            tokenStore.tokens?.accessToken,
            "access-token"
        )

        XCTAssertEqual(
            tokenStore.tokens?.refreshToken,
            "refresh-token"
        )
    }

    func testSignInWithAppleFailureBecomesUnauthenticated() async {
        authenticationService.signInError =
            TestAuthenticationError.failed

        await sessionManager.signInWithApple(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        XCTAssertEqual(
            authenticationService.signInCallCount,
            1
        )

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )

        XCTAssertNil(
            tokenStore.tokens
        )
    }

    // MARK: - Refresh

    func testRefreshSessionSuccessStoresNewTokens() async throws {
        try tokenStore.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token"
        )

        sessionManager.restoreSession()

        authenticationService.refreshResponse =
            AuthenticationResponse(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token",
                expiresIn: 3600
            )

        await sessionManager.refreshSession()

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        XCTAssertEqual(
            tokenStore.tokens?.accessToken,
            "new-access-token"
        )

        XCTAssertEqual(
            tokenStore.tokens?.refreshToken,
            "new-refresh-token"
        )
    }

    func testRefreshSessionFailureBecomesExpired() async throws {
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        sessionManager.restoreSession()

        authenticationService.refreshError =
            TestAuthenticationError.failed

        await sessionManager.refreshSession()

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )

        XCTAssertEqual(
            sessionManager.state,
            .expired
        )
    }

    // MARK: - Logout

    func testLogoutClearsLocalTokens() async throws {
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        sessionManager.restoreSession()

        await sessionManager.logout()

        XCTAssertEqual(
            authenticationService.logoutCallCount,
            1
        )

        XCTAssertNil(
            tokenStore.tokens
        )

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )
    }

    func testLogoutClearsLocalTokensWhenServerLogoutFails() async throws {
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        sessionManager.restoreSession()

        authenticationService.logoutError =
            TestAuthenticationError.failed

        await sessionManager.logout()

        XCTAssertEqual(
            authenticationService.logoutCallCount,
            1
        )

        XCTAssertNil(
            tokenStore.tokens
        )

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )
    }
}

// MARK: - Mock Token Store

private final class MockTokenStore:
    TokenStore,
    @unchecked Sendable {

    private(set) var tokens: StoredTokens?

    func save(
        accessToken: String,
        refreshToken: String
    ) throws {
        tokens = StoredTokens(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }

    func load() throws -> StoredTokens? {
        tokens
    }

    func clear() throws {
        tokens = nil
    }

    func reset() {
        tokens = nil
    }
}

// MARK: - Test Error

private enum TestAuthenticationError:
    Error,
    Equatable {

    case failed
}
