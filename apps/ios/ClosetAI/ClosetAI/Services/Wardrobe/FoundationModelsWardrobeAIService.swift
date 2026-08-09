//
//  FoundationModelsWardrobeAIService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import FoundationModels
import ImageIO

struct FoundationModelsWardrobeAIService: WardrobeAIService {

    func analyze(image: Data) async throws -> WardrobeAnalysis {
        let model = SystemLanguageModel.default

        guard model.isAvailable else {
            throw WardrobeAIError.modelUnavailable
        }

        let cgImage = try makeCGImage(from: image)

        let session = LanguageModelSession(
            instructions: """
            You are ClosetAI's wardrobe analysis assistant.

            Analyze wardrobe items from photos.

            The item can be clothing, footwear, bags, jewellery,
            watches, or accessories.

            Do not invent information that cannot reasonably
            be determined from the image.
            """
        )

        let response = try await session.respond(
            generating: AIWardrobeAnalysis.self
        ) {
            """
            Analyze this wardrobe item.

            Identify:
            - item name
            - category
            - specific type
            - visible colors
            - material if identifiable
            - pattern if identifiable
            - visual style

            The category must be one of:
            tops, bottoms, dresses, outerwear, footwear,
            bags, jewellery, watches, accessories, other.
            """

        }

        return mapToWardrobeAnalysis(response.content)
    }

    private func mapToWardrobeAnalysis(
        _ analysis: AIWardrobeAnalysis
    ) -> WardrobeAnalysis {

        WardrobeAnalysis(
            name: analysis.name,
            category: mapCategory(analysis.category),
            subcategory: analysis.subcategory,
            attributes: WardrobeAttributes(
                colors: analysis.colors,
                material: analysis.material,
                pattern: analysis.pattern,
                brand: nil,
                style: analysis.style
            )
        )
    }
    
    private func makeCGImage(from data: Data) throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(
            data as CFData,
            nil
        ),
        let image = CGImageSourceCreateImageAtIndex(
            source,
            0,
            nil
        ) else {
            throw WardrobeAIError.invalidImage
        }

        return image
    }

    private func mapCategory(
        _ category: String
    ) -> WardrobeCategory {

        switch category
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines) {

        case "tops", "top", "shirt", "t-shirt", "tshirt":
            return .tops

        case "bottoms", "bottom", "pants", "trousers", "jeans":
            return .bottoms

        case "dresses", "dress":
            return .dresses

        case "outerwear", "jacket", "coat", "blazer":
            return .outerwear

        case "footwear", "shoes", "shoe", "sneakers", "boots":
            return .footwear

        case "bags", "bag", "handbag", "purse":
            return .bags

        case "jewellery", "jewelry", "necklace", "ring",
             "bracelet", "earrings":
            return .jewellery

        case "watches", "watch":
            return .watches

        case "accessories", "accessory", "sunglasses",
             "belt", "hat", "cap", "scarf":
            return .accessories

        default:
            return .other
        }
    }
}


enum WardrobeAIError: Error, Sendable, Equatable {
    case modelUnavailable
    case invalidImage
    case noClassification
}
