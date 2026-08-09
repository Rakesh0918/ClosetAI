//
//  MockTokenStore.swift
//  ClosetAITests
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

@testable import ClosetAI

final class MockTokenStore: TokenStore, @unchecked Sendable {

    private(set) var tokens: StoredTokens?

    func save(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date
    ) throws {
        tokens = StoredTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
    
    func load() throws -> StoredTokens? {
        tokens
    }

    func clear() throws {
        tokens = nil
    }

    func reset() {
        tokens = nil
    }
}
