//
//  MockAPIClient.swift
//  ClosetAITests
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

@testable import ClosetAI

final class MockAPIClient: APIClient, @unchecked Sendable {

    var requestCount = 0

    private(set) var lastPath: String?
    private(set) var lastMethod: HTTPMethod?
    private(set) var lastBody: Data?

    var responseData: Data?

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> Response {

        requestCount += 1

        lastPath = request.path
        lastMethod = request.method
        lastBody = request.body

        guard let responseData else {
            fatalError(
                "MockAPIClient.responseData must be configured before calling send."
            )
        }

        if responseData.isEmpty {
            guard let emptyResponse = NoContentResponse() as? Response else {
                fatalError(
                    "Expected response data for this response type."
                )
            }

            return emptyResponse
        }

        return try JSONDecoder().decode(
            Response.self,
            from: responseData
        )
    }

    func reset() {
        requestCount = 0
        lastPath = nil
        lastMethod = nil
        lastBody = nil
        responseData = nil
    }
}
