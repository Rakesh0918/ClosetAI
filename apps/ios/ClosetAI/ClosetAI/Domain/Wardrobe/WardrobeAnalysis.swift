//
//  WardrobeAnalysis.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct WardrobeAnalysis: Codable, Sendable, Equatable {

    let name: String
    let category: WardrobeCategory
    let subcategory: String?
    let attributes: WardrobeAttributes
}
