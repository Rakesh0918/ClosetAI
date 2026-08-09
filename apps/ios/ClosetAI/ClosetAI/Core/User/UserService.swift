//
//  UserService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

protocol UserService: Sendable {
    func currentUser() async throws -> CurrentUser
}
