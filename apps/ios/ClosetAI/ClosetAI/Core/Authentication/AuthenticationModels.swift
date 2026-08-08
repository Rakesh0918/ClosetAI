//
//  AuthenticationModels.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

// MARK: - Sign in with Apple

struct AppleAuthenticationRequest: Codable, Sendable {
    let identityToken: String
    let authorizationCode: String
}

// MARK: - Authentication Response

struct AuthenticationResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

// MARK: - Refresh Token

struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
}

// MARK: - Logout

struct LogoutRequest: Codable, Sendable {
    let refreshToken: String
}

// MARK: - Authentication Error

struct AuthenticationErrorResponse: Codable, Sendable {
    let error: AuthenticationError
}

struct AuthenticationError: Codable, Sendable {
    let code: String
    let message: String
    let requestId: String
}
