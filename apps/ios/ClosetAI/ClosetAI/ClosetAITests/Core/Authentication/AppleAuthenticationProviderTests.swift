//
//  AppleAuthenticationProviderTests.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

final class AppleAuthenticationProviderTests: XCTestCase {

    private var provider: MockAppleAuthenticationProvider!

    override func setUp() {
        super.setUp()

        provider = MockAppleAuthenticationProvider()
    }

    override func tearDown() {
        provider.reset()
        provider = nil

        super.tearDown()
    }

    func testSignInReturnsAppleCredential() async throws {
        provider.credential = AppleAuthenticationCredential(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        let credential = try await provider.signIn()

        XCTAssertEqual(
            provider.signInCallCount,
            1
        )

        XCTAssertEqual(
            credential.identityToken,
            "identity-token"
        )

        XCTAssertEqual(
            credential.authorizationCode,
            "authorization-code"
        )
    }

    func testSignInThrowsConfiguredError() async {
        let expectedError = TestAuthenticationError.failed

        provider.error = expectedError

        do {
            _ = try await provider.signIn()

            XCTFail("Expected signIn() to throw.")
        } catch {
            XCTAssertEqual(
                error as? TestAuthenticationError,
                expectedError
            )
        }

        XCTAssertEqual(
            provider.signInCallCount,
            1
        )
    }

}

// MARK: - Test Helpers

private enum TestAuthenticationError: Error, Equatable {
    case failed
}
