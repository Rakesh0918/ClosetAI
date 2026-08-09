//
//  WardrobeService.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

protocol WardrobeService: Sendable {

    func fetchWardrobeItems() async throws -> [WardrobeItem]
}
