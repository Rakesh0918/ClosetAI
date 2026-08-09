//
//  WardrobeItem.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct WardrobeItem: Codable, Sendable, Equatable, Identifiable {

    let id: String
    let name: String
    let category: WardrobeCategory
    let subcategory: String?
    let attributes: WardrobeAttributes
    let images: [WardrobeImage]
}
