//
//  AccessTokenProviding.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

protocol AccessTokenProviding: Sendable {
    func accessToken() async throws -> String?
}
