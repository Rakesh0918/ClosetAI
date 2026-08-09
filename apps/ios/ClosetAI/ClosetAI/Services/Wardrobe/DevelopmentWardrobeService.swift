//
//  DevelopmentWardrobeService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct DevelopmentWardrobeService: WardrobeService {

    func fetchWardrobeItems() async throws -> [WardrobeItem] {
        [
            WardrobeItem(
                id: "shirt-001",
                name: "White Linen Shirt",
                category: .tops,
                subcategory: "shirt",
                attributes: WardrobeAttributes(
                    colors: ["white"],
                    material: "linen",
                    pattern: "solid",
                    brand: "Development",
                    style: "casual"
                ),
                images: []
            ),

            WardrobeItem(
                id: "jeans-001",
                name: "Blue Jeans",
                category: .bottoms,
                subcategory: "jeans",
                attributes: WardrobeAttributes(
                    colors: ["blue"],
                    material: "denim",
                    pattern: "solid",
                    brand: "Development",
                    style: "casual"
                ),
                images: []
            ),

            WardrobeItem(
                id: "shoes-001",
                name: "White Sneakers",
                category: .footwear,
                subcategory: "sneakers",
                attributes: WardrobeAttributes(
                    colors: ["white"],
                    material: "leather",
                    pattern: "solid",
                    brand: "Development",
                    style: "casual"
                ),
                images: []
            ),

            WardrobeItem(
                id: "necklace-001",
                name: "Gold Necklace",
                category: .jewellery,
                subcategory: "necklace",
                attributes: WardrobeAttributes(
                    colors: ["gold"],
                    material: "gold",
                    pattern: nil,
                    brand: "Development",
                    style: "minimal"
                ),
                images: []
            )
        ]
    }
}
