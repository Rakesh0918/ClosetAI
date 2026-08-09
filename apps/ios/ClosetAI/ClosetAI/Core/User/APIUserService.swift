//
//  APIUserService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct APIUserService: UserService, Sendable {

    private let apiClient: AuthenticatedAPIClient

    init(apiClient: AuthenticatedAPIClient) {
        self.apiClient = apiClient
    }

    func currentUser() async throws -> CurrentUser {
        let request = APIRequest<CurrentUser>(
            path: "/me",
            method: .get
        )

        return try await apiClient.send(request)
    }
}
