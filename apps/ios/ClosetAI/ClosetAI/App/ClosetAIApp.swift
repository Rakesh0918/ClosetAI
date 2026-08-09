//
//  ClosetAIApp.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import SwiftUI

@main
struct ClosetAIApp: App {

    private let container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
