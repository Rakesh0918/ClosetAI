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
                AuthenticationView()

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

    let tokenStore = KeychainTokenStore(
        service: "com.rakesh.closetai.preview",
        account: "preview"
    )

    let sessionManager = SessionManager(
        tokenStore: tokenStore
    )

    let container = AppContainer(
        environment: environment,
        apiClient: apiClient,
        sessionManager: sessionManager
    )

    RootView(container: container)
}
