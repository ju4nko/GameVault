//
//  GameVaultApp.swift
//  GameVault
//
//  Created by Juanjo on 14/06/2026.
//

import SwiftUI
import SwiftData

@main
struct GameVaultApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Game.self)
        }
    }
}
