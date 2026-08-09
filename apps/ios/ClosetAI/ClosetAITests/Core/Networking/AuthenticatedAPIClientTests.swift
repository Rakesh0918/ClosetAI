//
//  AuthenticatedAPIClientTests.swift
//  ClosetAITests
//
//  Created by Rakesh on 09/08/26.
//

import XCTest

@testable import ClosetAI

@MainActor
final class AuthenticatedAPIClientTests: XCTestCase {

    func testSendAddsAuthorizationHeader() async throws {
        let apiClient = MockAPIClient()

        apiClient.responseData = """
        {
            "value": "success"
        }
        """.data(using: .utf8)

        let tokenProvider = MockAccessTokenProvider(
            token: "test-access-token"
        )

        let client = AuthenticatedAPIClient(
            apiClient: apiClient,
            tokenProvider: tokenProvider
        )

        let request = APIRequest<TestResponse>(
            path: "/test"
        )

        _ = try await client.send(request)

        XCTAssertEqual(
            apiClient.lastHeaders?["Authorization"],
            "Bearer test-access-token"
        )

        XCTAssertEqual(
            apiClient.requestCount,
            1
        )
    }
}

private struct TestResponse: Decodable {
    let value: String
}

