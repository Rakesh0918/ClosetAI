//
//  AuthenticationViewModel.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthenticationViewModel {

    private(set) var isSigningIn = false
    private(set) var errorMessage: String?

    private let sessionManager: SessionManager
    private let appleAuthenticationProvider: any AppleAuthenticationProvider

    init(
        sessionManager: SessionManager,
        appleAuthenticationProvider: any AppleAuthenticationProvider
    ) {
        self.sessionManager = sessionManager
        self.appleAuthenticationProvider = appleAuthenticationProvider
    }

    // MARK: - Sign In

    func signInWithApple() async {
        guard !isSigningIn else {
            return
        }

        isSigningIn = true
        errorMessage = nil

        defer {
            isSigningIn = false
        }

        do {
            let credential = try await appleAuthenticationProvider.signIn()

            await sessionManager.signInWithApple(
                identityToken: credential.identityToken,
                authorizationCode: credential.authorizationCode
            )

            if sessionManager.state != .authenticated {
                errorMessage = "Unable to sign in. Please try again."
            }
        } catch {
            errorMessage = "Sign in with Apple failed. Please try again."
        }
    }

    // MARK: - Error Handling

    func clearError() {
        errorMessage = nil
    }
}
