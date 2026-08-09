//
//  WardrobeFilter.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

enum WardrobeFilter: Equatable, Sendable {
    case all
    case category(WardrobeCategory)
}
