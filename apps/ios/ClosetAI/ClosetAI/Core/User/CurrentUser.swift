//
//  CurrentUser.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

struct CurrentUser: Codable, Sendable, Equatable {
    let id: String
    let email: String
    let name: String
}
