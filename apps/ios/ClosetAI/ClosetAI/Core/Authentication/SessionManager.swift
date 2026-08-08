//
//  SessionManager.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionManager {

    private(set) var state: AuthenticationState = .unknown

    private let tokenStore: any TokenStore

    init(tokenStore: any TokenStore) {
        self.tokenStore = tokenStore
    }

    func restoreSession() {
        do {
            guard let tokens = try tokenStore.load() else {
                state = .unauthenticated
                return
            }

            guard !tokens.accessToken.isEmpty,
                  !tokens.refreshToken.isEmpty else {
                state = .unauthenticated
                return
            }

            state = .authenticated
        } catch {
            state = .unauthenticated
        }
    }

    func setAuthenticated(
        accessToken: String,
        refreshToken: String
    ) throws {
        try tokenStore.save(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        state = .authenticated
    }

    func logout() throws {
        try tokenStore.clear()
        state = .unauthenticated
    }
}
