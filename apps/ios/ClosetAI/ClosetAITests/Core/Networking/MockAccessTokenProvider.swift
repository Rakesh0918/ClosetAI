//
//  MockAccessTokenProvider.swift
//  ClosetAITests
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
@testable import ClosetAI

struct MockAccessTokenProvider: AccessTokenProviding {

    let token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func accessToken() async throws -> String? {
        token
    }
}
