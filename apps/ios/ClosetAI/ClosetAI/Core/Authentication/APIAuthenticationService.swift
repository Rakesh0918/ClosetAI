//
//  APIAuthenticationService.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

struct APIAuthenticationService: AuthenticationService, Sendable {

    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func signInWithApple(
        identityToken: String,
        authorizationCode: String
    ) async throws -> AuthenticationResponse {

        let body = try JSONEncoder().encode(
            AppleAuthenticationRequest(
                identityToken: identityToken,
                authorizationCode: authorizationCode
            )
        )

        let request = APIRequest<AuthenticationResponse>(
            path: "/v1/auth/apple",
            method: .post,
            body: body
        )

        return try await apiClient.send(request)
    }

    func refresh(
        refreshToken: String
    ) async throws -> AuthenticationResponse {

        let body = try JSONEncoder().encode(
            RefreshTokenRequest(
                refreshToken: refreshToken
            )
        )

        let request = APIRequest<AuthenticationResponse>(
            path: "/v1/auth/refresh",
            method: .post,
            body: body
        )

        return try await apiClient.send(request)
    }

    func logout(
        refreshToken: String
    ) async throws {

        let body = try JSONEncoder().encode(
            LogoutRequest(
                refreshToken: refreshToken
            )
        )

        let request = APIRequest<NoContentResponse>(
            path: "/v1/auth/logout",
            method: .post,
            body: body
        )

        let _: NoContentResponse = try await apiClient.send(request)
    }
}
