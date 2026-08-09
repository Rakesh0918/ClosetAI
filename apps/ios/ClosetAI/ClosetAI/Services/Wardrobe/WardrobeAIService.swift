//
//  WardrobeAIService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

protocol WardrobeAIService: Sendable {

    func analyze(
        image: Data
    ) async throws -> WardrobeAnalysis
}
