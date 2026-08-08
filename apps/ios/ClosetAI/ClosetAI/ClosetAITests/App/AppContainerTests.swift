//
//  AppContainerTests.swift
//  ClosetAITests
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

@MainActor
final class AppContainerTests: XCTestCase {

    func testContainerStoresEnvironment() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            sessionManager: sessionManager
        )

        XCTAssertEqual(
            container.environment.apiBaseURL,
            environment.apiBaseURL
        )
    }

    func testContainerStoresInjectedAPIClient() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            sessionManager: sessionManager
        )

        XCTAssertTrue(
            container.apiClient is MockAPIClient
        )
    }

    func testContainerStoresInjectedSessionManager() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()
        let tokenStore = MockTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            sessionManager: sessionManager
        )

        XCTAssertTrue(
            container.sessionManager === sessionManager
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
