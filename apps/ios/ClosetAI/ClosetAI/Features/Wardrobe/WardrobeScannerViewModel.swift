//
//  WardrobeScannerViewModel.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import Observation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
@Observable
final class WardrobeScannerViewModel {

    private(set) var analysis: WardrobeAnalysis?
    private(set) var isAnalyzing = false
    private(set) var errorMessage: String?

    private let aiService: any WardrobeAIService

    init(
        aiService: any WardrobeAIService
    ) {
        self.aiService = aiService
    }

    func analyze(
        photo: PhotosPickerItem
    ) async {

        guard !isAnalyzing else {
            return
        }

        isAnalyzing = true
        errorMessage = nil
        analysis = nil

        defer {
            isAnalyzing = false
        }

        do {
            guard let data = try await photo.loadTransferable(
                type: Data.self
            ) else {
                errorMessage = "Unable to load the selected photo."
                return
            }

            analysis = try await aiService.analyze(
                image: data
            )

        } catch {
            errorMessage = "Unable to analyze the photo."
        }
    }

    func clearAnalysis() {
        analysis = nil
        errorMessage = nil
    }
}
