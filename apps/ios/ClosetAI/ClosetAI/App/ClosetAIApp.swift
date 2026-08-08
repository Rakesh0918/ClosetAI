//
//  ClosetAIApp.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import SwiftUI

@main
struct ClosetAIApp: App {
    private let container: AppContainer

    init() {
        let environment = AppEnvironment.development

        let apiClient = URLSessionAPIClient(
            baseURL: environment.apiBaseURL
        )

        let tokenStore = KeychainTokenStore()

        let sessionManager = SessionManager(
            tokenStore: tokenStore
        )

        self.container = AppContainer(
            environment: environment,
            apiClient: apiClient,
            sessionManager: sessionManager
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
