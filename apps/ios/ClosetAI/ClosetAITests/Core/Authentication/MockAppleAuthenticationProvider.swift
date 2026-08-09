//
//  MockAppleAuthenticationProvider.swift
//  ClosetAITests
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

@testable import ClosetAI

final class MockAppleAuthenticationProvider:
    AppleAuthenticationProvider,
    @unchecked Sendable {

    var signInCallCount = 0

    var credential: AppleAuthenticationCredential?

    var error: Error?

    func signIn() async throws -> AppleAuthenticationCredential {
        signInCallCount += 1

        if let error {
            throw error
        }

        guard let credential else {
            fatalError(
                "MockAppleAuthenticationProvider.credential must be configured."
            )
        }

        return credential
    }

    func reset() {
        signInCallCount = 0
        credential = nil
        error = nil
    }
}
