//
//  AuthenticationState.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

enum AuthenticationState: Sendable, Equatable {
    case unknown
    case unauthenticated
    case authenticating
    case authenticated
    case refreshing
    case expired
}
