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

    func testRestoreSessionWithoutTokensBecomesUnauthenticated() {
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )
    }

    func testRestoreSessionWithTokensBecomesAuthenticated() throws {
        let tokenStore = MockTokenStore()

        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )
    }

    func testSetAuthenticatedStoresTokensAndUpdatesState() throws {
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        try sessionManager.setAuthenticated(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        let storedTokens = try tokenStore.load()

        XCTAssertEqual(
            storedTokens,
            StoredTokens(
                accessToken: "access-token",
                refreshToken: "refresh-token"
            )
        )
    }

    func testLogoutClearsTokensAndUpdatesState() throws {
        let tokenStore = MockTokenStore()

        try tokenStore.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        sessionManager.restoreSession()

        XCTAssertEqual(
            sessionManager.state,
            .authenticated
        )

        try sessionManager.logout()

        XCTAssertEqual(
            sessionManager.state,
            .unauthenticated
        )

        XCTAssertNil(
            try tokenStore.load()
        )
    }
}

// MARK: - Mock Token Store

private final class MockTokenStore: TokenStore, @unchecked Sendable {

    private var tokens: StoredTokens?

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
}
