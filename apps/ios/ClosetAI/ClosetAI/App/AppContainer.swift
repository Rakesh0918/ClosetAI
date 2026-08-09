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
    let authenticationService: any AuthenticationService
    let tokenStore: any TokenStore
    let sessionManager: SessionManager

    init(
        environment: AppEnvironment,
        apiClient: any APIClient,
        authenticationService: any AuthenticationService,
        tokenStore: any TokenStore,
        sessionManager: SessionManager
    ) {
        self.environment = environment
        self.apiClient = apiClient
        self.authenticationService = authenticationService
        self.tokenStore = tokenStore
        self.sessionManager = sessionManager
    }

    static var live: AppContainer {
        let environment = AppEnvironment.development

        let apiClient = URLSessionAPIClient(
            baseURL: environment.apiBaseURL
        )

        let authenticationService = APIAuthenticationService(
            apiClient: apiClient
        )

        let tokenStore = KeychainTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        return AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager
        )
    }
}
