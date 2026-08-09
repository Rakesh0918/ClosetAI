//
//  TokenStoreTests.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

final class TokenStoreTests: XCTestCase {

    private let service = "com.rakesh.closetai.tests"
    private let account = "token-store-tests"

    override func tearDown() {
        super.tearDown()

        try? makeStore().clear()
    }

    func testSaveAndLoadTokens() throws {
        let store = makeStore()
        
        let expiresAt = Date().addingTimeInterval(3600)

        try store.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        let tokens = try store.load()

        XCTAssertEqual(
            tokens,
            StoredTokens(
                accessToken: "access-token",
                refreshToken: "refresh-token",
                expiresAt: expiresAt
            )
        )
    }

    func testSaveUpdatesExistingTokens() throws {
        let store = makeStore()
        
        let expiresAt = Date().addingTimeInterval(3600)

        try store.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token",
            expiresAt: expiresAt
        )

        try store.save(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresAt: expiresAt
        )

        let tokens = try store.load()

        XCTAssertEqual(
            tokens,
            StoredTokens(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token",
                expiresAt: expiresAt
            )
        )
    }

    func testLoadReturnsNilWhenNoTokensExist() throws {
        let store = makeStore()

        let tokens = try store.load()

        XCTAssertNil(tokens)
    }

    func testClearRemovesTokens() throws {
        let store = makeStore()
        
        let expiresAt = Date().addingTimeInterval(3600)

        try store.save(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: expiresAt
        )

        try store.clear()

        let tokens = try store.load()

        XCTAssertNil(tokens)
    }

    private func makeStore() -> KeychainTokenStore {
        KeychainTokenStore(
            service: service,
            account: account
        )
    }
}
