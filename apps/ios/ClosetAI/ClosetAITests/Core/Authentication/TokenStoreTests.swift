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

        try store.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let tokens = try store.load()

        XCTAssertEqual(
            tokens,
            StoredTokens(
                accessToken: "access-token",
                refreshToken: "refresh-token"
            )
        )
    }

    func testSaveUpdatesExistingTokens() throws {
        let store = makeStore()

        try store.save(
            accessToken: "old-access-token",
            refreshToken: "old-refresh-token"
        )

        try store.save(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )

        let tokens = try store.load()

        XCTAssertEqual(
            tokens,
            StoredTokens(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token"
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

        try store.save(
            accessToken: "access-token",
            refreshToken: "refresh-token"
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
