//
//  ContentView.swift
//  GameVault
//
//  Created by Juanjo on 14/06/2026.
//

import SwiftUI

struct ContentView: View {
    let games: [Game] = Game.sampleGames
    var body: some View {
        NavigationStack {
            List(games) { game in
                GameRowView(game: game)
            }
            .navigationTitle("Mi biblioteca")
        }
    }
}

#Preview {
    ContentView()
}
