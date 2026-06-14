//
//  GameRowView.swift
//  GameVault
//
//  Created by Juanjo on 14/06/2026.
//

import SwiftUI

struct GameRowView: View {
    let game: Game
    var body: some View {
        HStack {
            Image(systemName: "gamecontroller.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading) {
                Text(game.title)
                    .font(.headline) // Título
                Text(game.platform.displayName)
                    .font(.subheadline) // Plataforma
                    .foregroundStyle(.secondary)
                Label(game.status.displayName, systemImage: game.status.iconName)
                Text("\(game.hoursPlayed.formatted())h") // Horas jugadas
                if let rating = game.rating {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < rating ? "star.fill": "star")
                        }
                        
                    }
                    .foregroundStyle(.orange)
                
                }
            }
            Spacer()
        }
        
    }
}

#Preview {
    GameRowView(game: Game.sampleGames[4])
}
