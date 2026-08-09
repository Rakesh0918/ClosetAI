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
    let appleAuthenticationProvider: any AppleAuthenticationProvider

    let authenticationViewModel: AuthenticationViewModel

    init(
        environment: AppEnvironment,
        apiClient: any APIClient,
        authenticationService: any AuthenticationService,
        tokenStore: any TokenStore,
        sessionManager: SessionManager,
        appleAuthenticationProvider: any AppleAuthenticationProvider
    ) {
        self.environment = environment
        self.apiClient = apiClient
        self.authenticationService = authenticationService
        self.tokenStore = tokenStore
        self.sessionManager = sessionManager
        self.appleAuthenticationProvider = appleAuthenticationProvider

        self.authenticationViewModel = AuthenticationViewModel(
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
        )
    }

    static var live: AppContainer {
        let environment = AppEnvironment.development

        let apiClient = URLSessionAPIClient(
            baseURL: environment.apiBaseURL
        )

        let authenticationService: any AuthenticationService

        switch environment.mode {
        case .development:
            authenticationService = DevelopmentAuthenticationService()

        case .production:
            authenticationService = APIAuthenticationService(
                apiClient: apiClient
            )
        }

        let tokenStore = KeychainTokenStore()

        let sessionManager = SessionManager(
            authenticationService: authenticationService,
            tokenStore: tokenStore
        )

        let appleAuthenticationProvider =
            Self.makeAppleAuthenticationProvider(
                environment: environment
            )

        return AppContainer(
            environment: environment,
            apiClient: apiClient,
            authenticationService: authenticationService,
            tokenStore: tokenStore,
            sessionManager: sessionManager,
            appleAuthenticationProvider: appleAuthenticationProvider
        )
    }
    
    private static func makeAppleAuthenticationProvider(
        environment: AppEnvironment
    ) -> any AppleAuthenticationProvider {

        switch environment.mode {
        case .development:
            return DevelopmentAppleAuthenticationProvider()

        case .production:
            return UnavailableAppleAuthenticationProvider()
        }
    }
}
