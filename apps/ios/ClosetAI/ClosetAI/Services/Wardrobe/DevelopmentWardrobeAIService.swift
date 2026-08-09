//
//  DevelopmentWardrobeAIService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct DevelopmentWardrobeAIService: WardrobeAIService {

    func analyze(image: Data) async throws -> WardrobeAnalysis {
        WardrobeAnalysis(
            name: "White Shirt",
            category: .tops,
            subcategory: "shirt",
            attributes: WardrobeAttributes(
                colors: ["white"],
                material: "cotton",
                pattern: "solid",
                brand: nil,
                style: "casual"
            )
        )
    }
}
