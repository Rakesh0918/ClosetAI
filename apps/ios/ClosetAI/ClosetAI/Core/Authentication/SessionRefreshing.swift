//
//  SessionRefreshing.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

protocol SessionRefreshing: Sendable {
    func refreshSession() async
}
