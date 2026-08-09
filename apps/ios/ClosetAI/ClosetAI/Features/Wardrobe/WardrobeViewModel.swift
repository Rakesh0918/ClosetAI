//
//  WardrobeViewModel.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class WardrobeViewModel {

    private(set) var items: [WardrobeItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let wardrobeService: any WardrobeService
    private let wardrobeAIService: any WardrobeAIService
    private(set) var selectedFilter: WardrobeFilter = .all
    
    var filteredItems: [WardrobeItem] {
        switch selectedFilter {
        case .all:
            return items

        case .category(let category):
            return items.filter {
                $0.category == category
            }
        }
    }

    init(
        wardrobeService: any WardrobeService,
        wardrobeAIService: any WardrobeAIService
    ) {
        self.wardrobeService = wardrobeService
        self.wardrobeAIService = wardrobeAIService
    }
    
    func loadWardrobe() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            items = try await wardrobeService.fetchWardrobeItems()
        } catch {
            errorMessage = "Unable to load your wardrobe."
        }
    }
    
    func selectFilter(_ filter: WardrobeFilter) {
        selectedFilter = filter
    }

    func retry() async {
        await loadWardrobe()
    }
    
    func makeScannerViewModel() -> WardrobeScannerViewModel {
        WardrobeScannerViewModel(
            aiService: wardrobeAIService
        )
    }
}
