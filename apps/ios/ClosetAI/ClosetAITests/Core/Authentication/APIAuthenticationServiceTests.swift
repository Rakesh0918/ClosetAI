//
//  APIAuthenticationServiceTests.swift
//  ClosetAITests
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

final class APIAuthenticationServiceTests: XCTestCase {

    private var apiClient: MockAPIClient!
    private var service: APIAuthenticationService!

    override func setUp() {
        super.setUp()

        apiClient = MockAPIClient()

        service = APIAuthenticationService(
            apiClient: apiClient
        )
    }

    override func tearDown() {
        apiClient.reset()

        service = nil
        apiClient = nil

        super.tearDown()
    }

    // MARK: - Sign in with Apple

    func testSignInWithAppleCreatesCorrectRequest() async throws {
        apiClient.responseData = authenticationResponseData()

        let response = try await service.signInWithApple(
            identityToken: "identity-token",
            authorizationCode: "authorization-code"
        )

        XCTAssertEqual(
            apiClient.requestCount,
            1
        )

        XCTAssertEqual(
            apiClient.lastPath,
            "/v1/auth/apple"
        )

        XCTAssertEqual(
            apiClient.lastMethod,
            .post
        )

        let body = try XCTUnwrap(
            apiClient.lastBody
        )

        let request: AppleAuthenticationRequest = try await MainActor.run {
            try JSONDecoder().decode(
                AppleAuthenticationRequest.self,
                from: body
            )
        }

        let identityToken = await MainActor.run { request.identityToken }
        let authorizationCode = await MainActor.run { request.authorizationCode }

        XCTAssertEqual(
            identityToken,
            "identity-token"
        )

        XCTAssertEqual(
            authorizationCode,
            "authorization-code"
        )

        let responseAccessToken = await MainActor.run { response.accessToken }
        let responseRefreshToken = await MainActor.run { response.refreshToken }
        let responseExpiresIn = await MainActor.run { response.expiresIn }

        XCTAssertEqual(
            responseAccessToken,
            "access-token"
        )

        XCTAssertEqual(
            responseRefreshToken,
            "refresh-token"
        )

        XCTAssertEqual(
            responseExpiresIn,
            3600
        )
    }

    // MARK: - Refresh

    func testRefreshCreatesCorrectRequest() async throws {
        apiClient.responseData = authenticationResponseData(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let response = try await service.refresh(
            refreshToken: "refresh-token"
        )

        XCTAssertEqual(
            apiClient.requestCount,
            1
        )

        XCTAssertEqual(
            apiClient.lastPath,
            "/v1/auth/refresh"
        )

        XCTAssertEqual(
            apiClient.lastMethod,
            .post
        )

        let body = try XCTUnwrap(
            apiClient.lastBody
        )

        let request: RefreshTokenRequest = try await MainActor.run {
            try JSONDecoder().decode(
                RefreshTokenRequest.self,
                from: body
            )
        }

        let requestedRefreshToken = await MainActor.run { request.refreshToken }
        XCTAssertEqual(requestedRefreshToken, "refresh-token")

        let newAccessToken = await MainActor.run { response.accessToken }
        let newRefreshToken = await MainActor.run { response.refreshToken }
        let expectedAccessToken = "new-access-token"
        let expectedRefreshToken = "new-refresh-token"

        XCTAssertEqual(newAccessToken, expectedAccessToken)
        XCTAssertEqual(newRefreshToken, expectedRefreshToken)
    }

    // MARK: - Logout

    func testLogoutCreatesCorrectRequest() async throws {
        apiClient.responseData = Data()

        try await service.logout(
            refreshToken: "refresh-token"
        )

        XCTAssertEqual(
            apiClient.requestCount,
            1
        )

        XCTAssertEqual(
            apiClient.lastPath,
            "/v1/auth/logout"
        )

        XCTAssertEqual(
            apiClient.lastMethod,
            .post
        )

        let body = try XCTUnwrap(
            apiClient.lastBody
        )

        let request = try JSONDecoder().decode(
            LogoutRequest.self,
            from: body
        )

        XCTAssertEqual(
            request.refreshToken,
            "refresh-token"
        )
    }

    // MARK: - Helpers

    private func authenticationResponseData(
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token"
    ) -> Data {
        Data(
            """
            {
                "accessToken": "\(accessToken)",
                "refreshToken": "\(refreshToken)",
                "expiresIn": 3600
            }
            """.utf8
        )
    }
}

