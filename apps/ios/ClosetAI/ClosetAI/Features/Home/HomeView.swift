//
//  HomeView.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 56))

                Text("Welcome to ClosetAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your wardrobe is ready.")
                    .foregroundStyle(.secondary)

                Button("Sign Out") {
                    Task {
                        await viewModel.signOut()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Home")
        }
        .task {
            await viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    let authenticationService =
        DevelopmentAuthenticationService()

    let tokenStore = KeychainTokenStore(
        service: "com.rakesh.closetai.preview",
        account: "home-preview"
    )

    let sessionManager = SessionManager(
        authenticationService: authenticationService,
        tokenStore: tokenStore
    )

    let viewModel = HomeViewModel(
        userService: DevelopmentUserService(),
        sessionManager: sessionManager
    )

    HomeView(
        viewModel: viewModel
    )
}
