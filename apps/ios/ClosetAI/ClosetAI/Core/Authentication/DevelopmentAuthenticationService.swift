//
//  DevelopmentAuthenticationService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct DevelopmentAuthenticationService:
    AuthenticationService {

    func signInWithApple(
        identityToken: String,
        authorizationCode: String
    ) async throws -> AuthenticationResponse {

        AuthenticationResponse(
            accessToken: "development-access-token",
            refreshToken: "development-refresh-token",
            expiresIn: 3600
        )
    }

    func refresh(
        refreshToken: String
    ) async throws -> AuthenticationResponse {

        AuthenticationResponse(
            accessToken: "development-refreshed-access-token",
            refreshToken: "development-refresh-token",
            expiresIn: 3600
        )
    }

    func logout(
        refreshToken: String
    ) async throws {
        // Development environment does not require
        // a real backend logout request.
    }
}
