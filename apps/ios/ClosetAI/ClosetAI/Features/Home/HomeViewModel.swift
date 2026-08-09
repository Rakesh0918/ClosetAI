//
//  HomeViewModel.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    private(set) var user: CurrentUser?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let userService: any UserService
    private let sessionManager: SessionManager
    private let wardrobeService: any WardrobeService
    private let wardrobeAIService: any WardrobeAIService

    init(
        userService: any UserService,
        sessionManager: SessionManager,
        wardrobeService: any WardrobeService,
        wardrobeAIService: any WardrobeAIService
    ) {
        self.userService = userService
        self.sessionManager = sessionManager
        self.wardrobeService = wardrobeService
        self.wardrobeAIService = wardrobeAIService
    }

    func loadCurrentUser() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            user = try await userService.currentUser()
        } catch {
            errorMessage = "Unable to load your profile."
        }
    }

    func signOut() async {
        await sessionManager.logout()
    }
    
    func makeWardrobeViewModel() -> WardrobeViewModel {
        WardrobeViewModel(
            wardrobeService: wardrobeService,
            wardrobeAIService: wardrobeAIService
        )
    }
}
