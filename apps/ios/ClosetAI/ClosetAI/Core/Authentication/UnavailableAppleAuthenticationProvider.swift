//
//  UnavailableAppleAuthenticationProvider.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct UnavailableAppleAuthenticationProvider:
    AppleAuthenticationProvider {

    func signIn() async throws -> AppleAuthenticationCredential {
        throw AppleAuthenticationProviderError.unavailable
    }
}

enum AppleAuthenticationProviderError: Error {
    case unavailable
}
