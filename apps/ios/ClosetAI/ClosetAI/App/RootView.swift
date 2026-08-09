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

    var body: some View {
        Group {
            switch container.sessionManager.state {

            case .unknown:
                loadingView

            case .unauthenticated,
                 .authenticating,
                 .expired:

                AuthenticationView(
                    viewModel: AuthenticationViewModel(
                        sessionManager: container.sessionManager,
                        appleAuthenticationProvider:
                            container.appleAuthenticationProvider
                    )
                )

            case .authenticated,
                 .refreshing:

                HomeView()
            }
        }
        .task {
            container.sessionManager.restoreSession()
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

    let authenticationService = APIAuthenticationService(
        apiClient: apiClient
    )

    let tokenStore = KeychainTokenStore(
        service: "com.rakesh.closetai.preview",
        account: "preview"
    )

    let sessionManager = SessionManager(
        authenticationService: authenticationService,
        tokenStore: tokenStore
    )

    let appleAuthenticationProvider =
        UnavailableAppleAuthenticationProvider()

    let container = AppContainer(
        environment: environment,
        apiClient: apiClient,
        authenticationService: authenticationService,
        tokenStore: tokenStore,
        sessionManager: sessionManager,
        appleAuthenticationProvider: appleAuthenticationProvider
    )

    RootView(container: container)
}
