//
//  VisionWardrobeAIService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import Vision
import ImageIO

struct VisionWardrobeAIService: WardrobeAIService {

    func analyze(image: Data) async throws -> WardrobeAnalysis {

        guard let imageSource = CGImageSourceCreateWithData(
            image as CFData,
            nil
        ),
        let cgImage = CGImageSourceCreateImageAtIndex(
            imageSource,
            0,
            nil
        ) else {
            throw WardrobeAIError.invalidImage
        }

        let request = VNClassifyImageRequest()

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            options: [:]
        )

        try handler.perform([request])

        guard let observations = request.results,
              let bestMatch = observations.first else {
            throw WardrobeAIError.noClassification
        }

        return makeWardrobeAnalysis(
            from: bestMatch
        )
    }

    private func makeWardrobeAnalysis(
        from observation: VNClassificationObservation
    ) -> WardrobeAnalysis {

        let identifier = observation.identifier.lowercased()

        let category = mapCategory(
            from: identifier
        )

        return WardrobeAnalysis(
            name: identifier.capitalized,
            category: category,
            subcategory: identifier,
            attributes: WardrobeAttributes(
                colors: [],
                material: nil,
                pattern: nil,
                brand: nil,
                style: nil
            )
        )
    }

    private func mapCategory(
        from identifier: String
    ) -> WardrobeCategory {

        if identifier.contains("shirt") ||
           identifier.contains("t-shirt") ||
           identifier.contains("jersey") {
            return .tops
        }

        if identifier.contains("jean") ||
           identifier.contains("trouser") ||
           identifier.contains("pants") ||
           identifier.contains("shorts") {
            return .bottoms
        }

        if identifier.contains("dress") {
            return .dresses
        }

        if identifier.contains("jacket") ||
           identifier.contains("coat") ||
           identifier.contains("blazer") {
            return .outerwear
        }

        if identifier.contains("shoe") ||
           identifier.contains("sneaker") ||
           identifier.contains("boot") {
            return .footwear
        }

        if identifier.contains("bag") ||
           identifier.contains("handbag") ||
           identifier.contains("purse") {
            return .bags
        }

        if identifier.contains("necklace") ||
           identifier.contains("ring") ||
           identifier.contains("bracelet") ||
           identifier.contains("earring") ||
           identifier.contains("jewelry") ||
           identifier.contains("jewellery") {
            return .jewellery
        }

        if identifier.contains("watch") {
            return .watches
        }

        return .other
    }
}
