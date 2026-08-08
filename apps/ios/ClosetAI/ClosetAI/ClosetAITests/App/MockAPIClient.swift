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

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> Response {
        requestCount += 1

        fatalError(
            "MockAPIClient.send must be configured for the test."
        )
    }
}
