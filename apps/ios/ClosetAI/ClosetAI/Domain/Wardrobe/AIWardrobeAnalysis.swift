//
//  AIWardrobeAnalysis.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation
import FoundationModels

@Generable
struct AIWardrobeAnalysis {

    @Guide(description: "A short name for the wardrobe item.")
    let name: String

    @Guide(description: "The main wardrobe category.")
    let category: String

    @Guide(description: "The specific type of item, such as shirt, jeans, necklace, watch, sneakers, or handbag.")
    let subcategory: String?

    @Guide(description: "The main visible colors of the item.")
    let colors: [String]

    @Guide(description: "The visible or likely material, if identifiable.")
    let material: String?

    @Guide(description: "The visible pattern, such as solid, striped, floral, checked, or unknown.")
    let pattern: String?

    @Guide(description: "The visual style, such as casual, formal, sporty, elegant, minimal, or traditional.")
    let style: String?
}
