//
//  AuthenticationService.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

protocol AuthenticationService: Sendable {

    func signInWithApple(
        identityToken: String,
        authorizationCode: String
    ) async throws -> AuthenticationResponse

    func refresh(
        refreshToken: String
    ) async throws -> AuthenticationResponse

    func logout(
        refreshToken: String
    ) async throws
}
