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
        let authenticationService = MockAuthenticationService()
        let appleAuthenticationProvider =
            MockAppleAuthenticationProvider()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
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
        let authenticationService = MockAuthenticationService()
        let appleAuthenticationProvider =
            MockAppleAuthenticationProvider()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
        )

        XCTAssertTrue(
            container.apiClient is MockAPIClient
        )
    }

    func testContainerStoresInjectedSessionManager() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()
        let tokenStore = MockTokenStore()
        let authenticationService = MockAuthenticationService()
        let appleAuthenticationProvider =
            MockAppleAuthenticationProvider()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
        )

        XCTAssertTrue(
            container.sessionManager === sessionManager
        )
    }

    func testContainerStoresInjectedAppleAuthenticationProvider() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()
        let tokenStore = MockTokenStore()
        let authenticationService = MockAuthenticationService()
        let appleAuthenticationProvider =
            MockAppleAuthenticationProvider()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
        )

        XCTAssertTrue(
            container.appleAuthenticationProvider
                is MockAppleAuthenticationProvider
        )
    }
}
