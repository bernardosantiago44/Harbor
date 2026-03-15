//
//  HarborApp.swift
//  Harbor
//
//  Created by Bernardo Santiago Marin on 14/03/26.
//

import SwiftUI

@main
struct HarborApp: App {
    @State private var router = AppRouter()
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(container)
        }
    }
}
