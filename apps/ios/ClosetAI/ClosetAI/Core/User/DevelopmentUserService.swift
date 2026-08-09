//
//  DevelopmentUserService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct DevelopmentUserService: UserService {

    func currentUser() async throws -> CurrentUser {
        CurrentUser(
            id: "development-user",
            email: "rakesh@example.com",
            name: "Rakesh"
        )
    }
}
