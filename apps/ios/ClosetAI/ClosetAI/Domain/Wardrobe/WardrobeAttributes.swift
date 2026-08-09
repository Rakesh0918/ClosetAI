//
//  WardrobeAttributes.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct WardrobeAttributes: Codable, Sendable, Equatable {

    let colors: [String]
    let material: String?
    let pattern: String?
    let brand: String?
    let style: String?
}
