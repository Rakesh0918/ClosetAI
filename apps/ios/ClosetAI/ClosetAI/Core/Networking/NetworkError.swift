//
//  NetworkError.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

enum NetworkError: Error, Sendable, Equatable {
    case invalidURL
    case requestFailed(underlying: String)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: String)
    case encodingFailed(underlying: String)
    case noInternetConnection
    case requestCancelled
    case unknown
    case unauthorized
}
