//
//  AuthorizationHeader.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import Foundation

enum AuthorizationHeader {

    static func bearerToken(
        _ accessToken: String
    ) -> String {
        "Bearer \(accessToken)"
    }
}
