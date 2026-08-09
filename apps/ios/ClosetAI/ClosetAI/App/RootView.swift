//
//  RootView.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import SwiftUI

struct RootView: View {

    let container: AppContainer

    @State private var router = AppRouter()

    @State private var authenticationViewModel:
        AuthenticationViewModel

    init(container: AppContainer) {
        self.container = container

        _authenticationViewModel = State(
            initialValue: AuthenticationViewModel(
                sessionManager: container.sessionManager,
                appleAuthenticationProvider:
                    container.appleAuthenticationProvider
            )
        )
    }

    var body: some View {
        Group {
            switch container.sessionManager.state {

            case .unknown:
                loadingView

            case .unauthenticated,
                 .authenticating,
                 .expired:

                AuthenticationView(
                    viewModel: authenticationViewModel
                )

            case .authenticated,
                 .refreshing:

                HomeView(
                    viewModel: HomeViewModel(
                        userService: container.userService,
                        sessionManager: container.sessionManager,
                        wardrobeService: container.wardrobeService,
                        wardrobeAIService: container.wardrobeAIService
                    )
                )
            }
        }
        .task {
            await container.sessionManager.restoreSession()
        }
    }

    private var loadingView: some View {
        ProgressView("Loading...")
    }
}

#Preview {
    let environment = AppEnvironment.development

    let apiClient = URLSessionAPIClient(
        baseURL: environment.apiBaseURL
    )

    let authenticationService =
        DevelopmentAuthenticationService()

    let tokenStore = KeychainTokenStore(
        service: "com.rakesh.closetai.preview",
        account: "preview"
    )

    let sessionManager = SessionManager(
        authenticationService: authenticationService,
        tokenStore: tokenStore
    )

    let appleAuthenticationProvider =
        DevelopmentAppleAuthenticationProvider()

    let authenticatedAPIClient = AuthenticatedAPIClient(
        apiClient: apiClient,
        tokenProvider: sessionManager
    )

    let userService = APIUserService(
        apiClient: authenticatedAPIClient
    )

    let wardrobeService: any WardrobeService =
        DevelopmentWardrobeService()
    
    let wardrobeAIService: any WardrobeAIService =
        DevelopmentWardrobeAIService()

    let container = AppContainer(
        environment: environment,
        apiClient: apiClient,
        authenticationService: authenticationService,
        tokenStore: tokenStore,
        sessionManager: sessionManager,
        appleAuthenticationProvider:
            appleAuthenticationProvider,
        authenticatedAPIClient:
            authenticatedAPIClient,
        userService: userService,
        wardrobeService: wardrobeService,
        wardrobeAIService: wardrobeAIService
    )

    RootView(container: container)
}
