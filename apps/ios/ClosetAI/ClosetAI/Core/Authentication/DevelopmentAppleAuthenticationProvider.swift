//
//  DevelopmentAppleAuthenticationProvider.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct DevelopmentAppleAuthenticationProvider:
    AppleAuthenticationProvider {

    func signIn() async throws -> AppleAuthenticationCredential {
        AppleAuthenticationCredential(
            identityToken: "development-identity-token",
            authorizationCode: "development-authorization-code"
        )
    }
}
