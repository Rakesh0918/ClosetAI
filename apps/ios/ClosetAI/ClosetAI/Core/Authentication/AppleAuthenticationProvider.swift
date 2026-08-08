//
//  AppleAuthenticationProvider.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

protocol AppleAuthenticationProvider: Sendable {

    func signIn() async throws -> AppleAuthenticationCredential
}

struct AppleAuthenticationCredential: Sendable {
    let identityToken: String
    let authorizationCode: String
}
