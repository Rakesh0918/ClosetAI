//
//  AppRouter.swift
//  ClosetAI
//
//  Created by Rakesh on 06/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum Route: Hashable {
    case authentication
    case home
}
