//
//  MockAuthenticationService.swift
//  ClosetAITests
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

@testable import ClosetAI

final class MockAuthenticationService:
    AuthenticationService,
    @unchecked Sendable {

    var signInCallCount = 0
    var refreshCallCount = 0
    var logoutCallCount = 0

    var signInResponse: AuthenticationResponse?
    var refreshResponse: AuthenticationResponse?

    var signInError: Error?
    var refreshError: Error?
    var logoutError: Error?
    
    private(set) var lastRefreshToken: String?

    func signInWithApple(
        identityToken: String,
        authorizationCode: String
    ) async throws -> AuthenticationResponse {
        signInCallCount += 1

        if let signInError {
            throw signInError
        }

        guard let signInResponse else {
            fatalError(
                "MockAuthenticationService.signInResponse must be configured."
            )
        }

        return signInResponse
    }

    func refresh(
        refreshToken: String
    ) async throws -> AuthenticationResponse {
        refreshCallCount += 1
        lastRefreshToken = refreshToken

        if let refreshError {
            throw refreshError
        }

        guard let refreshResponse else {
            fatalError(
                "MockAuthenticationService.refreshResponse must be configured."
            )
        }

        return refreshResponse
    }

    func logout(
        refreshToken: String
    ) async throws {
        logoutCallCount += 1

        if let logoutError {
            throw logoutError
        }
    }

    func reset() {
        signInCallCount = 0
        refreshCallCount = 0
        logoutCallCount = 0

        signInResponse = nil
        refreshResponse = nil

        signInError = nil
        refreshError = nil
        logoutError = nil
        lastRefreshToken = nil
    }
}
