//
//  AppContainer.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import Foundation

@MainActor
final class AppContainer {
    let environment: AppEnvironment
    let apiClient: any APIClient
    let sessionManager: SessionManager

    init(
        environment: AppEnvironment,
        apiClient: any APIClient,
        sessionManager: SessionManager
    ) {
        self.environment = environment
        self.apiClient = apiClient
        self.sessionManager = sessionManager
    }
}
