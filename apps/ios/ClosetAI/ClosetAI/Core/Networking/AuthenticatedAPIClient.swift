//
//  AuthenticatedAPIClient.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct AuthenticatedAPIClient: Sendable {

    private let apiClient: any APIClient
    private let tokenProvider: any AccessTokenProviding

    init(
        apiClient: any APIClient,
        tokenProvider: any AccessTokenProviding
    ) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
    }

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> Response {

        guard let accessToken = try await tokenProvider.accessToken() else {
            throw NetworkError.unauthorized
        }

        var headers = request.headers

        headers["Authorization"] =
            AuthorizationHeader.bearerToken(accessToken)

        let authenticatedRequest = APIRequest<Response>(
            path: request.path,
            method: request.method,
            queryItems: request.queryItems,
            headers: headers,
            body: request.body
        )

        return try await apiClient.send(
            authenticatedRequest
        )
    }
}
