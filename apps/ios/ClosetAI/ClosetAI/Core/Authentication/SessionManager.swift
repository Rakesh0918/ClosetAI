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

    private let authenticationService: any AuthenticationService
    private let tokenStore: any TokenStore

    init(
        authenticationService: any AuthenticationService,
        tokenStore: any TokenStore
    ) {
        self.authenticationService = authenticationService
        self.tokenStore = tokenStore
    }

    // MARK: - Session Restoration

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

    // MARK: - Sign In with Apple

    func signInWithApple(
        identityToken: String,
        authorizationCode: String
    ) async {
        state = .authenticating

        do {
            let response = try await authenticationService.signInWithApple(
                identityToken: identityToken,
                authorizationCode: authorizationCode
            )

            try tokenStore.save(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )

            state = .authenticated
        } catch {
            state = .unauthenticated
        }
    }

    // MARK: - Refresh

    func refreshSession() async {
        guard state == .authenticated else {
            return
        }

        guard let tokens = try? tokenStore.load(),
              !tokens.refreshToken.isEmpty else {
            state = .unauthenticated
            return
        }

        state = .refreshing

        do {
            let response = try await authenticationService.refresh(
                refreshToken: tokens.refreshToken
            )

            try tokenStore.save(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )

            state = .authenticated
        } catch {
            state = .expired
        }
    }

    // MARK: - Logout

    func logout() async {
        guard let tokens = try? tokenStore.load(),
              !tokens.refreshToken.isEmpty else {
            state = .unauthenticated
            return
        }

        do {
            try await authenticationService.logout(
                refreshToken: tokens.refreshToken
            )
        } catch {
            // Local credentials must still be cleared even if
            // the server logout request fails.
        }

        do {
            try tokenStore.clear()
        } catch {
            state = .expired
            return
        }

        state = .unauthenticated
    }
}
