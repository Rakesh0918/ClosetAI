//
//  AppEnvironment.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import Foundation

struct AppEnvironment: Sendable {
    let apiBaseURL: URL
    let appVersion: String
    let buildNumber: String

    static let development = AppEnvironment(
        apiBaseURL: URL(string: "https://api-dev.closetai.com")!,
        appVersion: Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0",
        buildNumber: Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "1"
    )
}
