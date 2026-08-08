//
//  AppContainerTests.swift
//  ClosetAITests
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

final class AppContainerTests: XCTestCase {

    @MainActor func testContainerStoresEnvironment() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient
        )

        XCTAssertEqual(
            container.environment.apiBaseURL,
            environment.apiBaseURL
        )
    }

    @MainActor func testContainerStoresInjectedAPIClient() {
        let environment = AppEnvironment.development
        let apiClient = MockAPIClient()

        let container = AppContainer(
            environment: environment,
            apiClient: apiClient
        )

        XCTAssertTrue(
            container.apiClient is MockAPIClient
        )
    }
}
