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

    func testRestoreSessionWithoutTokensBecomesUnauthenticated() async {
        await sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )
    }

    func testRestoreSessionWithTokensBecomesAuthenticated() async throws {
        let expiresAt = Date().addingTimeInterval(3600)

        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

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
        let expiresAt = Date().addingTimeInterval(3600)
        try tokenStore.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

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
        let expiresAt = Date().addingTimeInterval(3600)
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

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
        let expiresAt = Date().addingTimeInterval(3600)
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

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
        let expiresAt = Date().addingTimeInterval(3600)
        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

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
    
    func testRefreshSessionWithValidRefreshTokenAuthenticatesUser() async {
        let authenticationService = MockAuthenticationService()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )
        
        let expiresAt = Date().addingTimeInterval(3600)

        try? tokenStore.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token",
            expiresAt: expiresAt
        )

        authenticationService.refreshResponse =
            AuthenticationResponse(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token",
                expiresIn: 3600
            )

        await sessionManager.restoreSession()

        await sessionManager.refreshSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )

        XCTAssertEqual(
            authenticationService.lastRefreshToken,
            "old-refresh-token"
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
    
    func testRefreshSessionFailureSetsExpiredState() async {
        let authenticationService = MockAuthenticationService()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )
        
        let expiresAt = Date().addingTimeInterval(3600)

        try? tokenStore.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token",
            expiresAt: expiresAt
        )

        authenticationService.refreshError =
            TestAuthenticationError.failed

        await sessionManager.restoreSession()

        await sessionManager.refreshSession()

        XCTAssertEqual(
            sessionManager.state,
            .expired
        )

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )
    }
    
    func testRefreshSessionDoesNothingWhenSessionIsNotAuthenticated() async {
        let authenticationService = MockAuthenticationService()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        XCTAssertEqual(
            sessionManager.state,
            .unknown
        )

        await sessionManager.refreshSession()

        XCTAssertEqual(
            sessionManager.state,
            .unknown
        )

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            0
        )
    }
    
    func testRefreshSessionWithoutRefreshTokenSetsUnauthenticatedState() async {
        let authenticationService = MockAuthenticationService()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )
        
        let expiresAt = Date().addingTimeInterval(3600)

        try? tokenStore.save(
            accessToken: "access-token",
            refreshToken: "",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

        // Empty refresh token means the restored session
        // should not be considered authenticated.
        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )

        await sessionManager.refreshSession()

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            0
        )
    }
    
    func testRestoreSessionWithValidTokensBecomesAuthenticated() async throws {
        let expiresAt = Date().addingTimeInterval(3600)

        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        await sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )
    }
    
    func testRestoreSessionWithExpiredTokenRefreshesSuccessfully() async throws {
        let expiresAt = Date().addingTimeInterval(-3600)

        try tokenStore.save(
            accessToken: "expired-access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        authenticationService.refreshResponse =
            AuthenticationResponse(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token",
                expiresIn: 3600
            )

        await sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )

        XCTAssertEqual(
            authenticationService.lastRefreshToken,
            "refresh-token"
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
    
    func testRestoreSessionWithExpiredTokenAndFailedRefreshBecomesExpired() async throws {
        let expiresAt = Date().addingTimeInterval(-3600)

        try tokenStore.save(
            accessToken: "expired-access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        authenticationService.refreshError =
            TestAuthenticationError.failed

        await sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .expired
        )

        XCTAssertEqual(
            authenticationService.refreshCallCount,
            1
        )
    }
    
    func testAccessTokenReturnsStoredAccessToken() async throws {
        let expiresAt = Date().addingTimeInterval(3600)

        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        let accessToken = try await sessionManager.accessToken()

        XCTAssertEqual(
            accessToken,
            "access-token"
        )
    }
    
    func testAccessTokenReturnsNilWhenNoTokensExist() async throws {
        let accessToken = try await sessionManager.accessToken()

        XCTAssertNil(accessToken)
    }
}

// MARK: - Test Error

private enum TestAuthenticationError:
    Error,
    Equatable {

    case failed
}
