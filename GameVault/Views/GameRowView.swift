//
//  GameRowView.swift
//  GameVault
//
//  Created by Juanjo on 14/06/2026.
//

import SwiftUI
import SwiftData

struct GameRowView: View {
    
    @State private var isHovered: Bool = false
    let game: Game
    let onDelete: () -> Void
    var body: some View {
        HStack {
            CachedAsyncImage(url: game.coverArtURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    Image(systemName:"gamecontroller.fill")
                @unknown default:
                    Color.clear
                }
            }
            .frame(width: 60,height: 60 )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading) {
                Text(game.title)
                    .font(.headline) // Título
                Text(game.platform.displayName)
                    .font(.subheadline) // Plataforma
                    .foregroundStyle(.secondary)
                Label(game.status.displayName, systemImage: game.status.iconName).foregroundStyle(game.status.iconColor)
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
            #if os(macOS)
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .opacity(isHovered ? 1: 0)
            #endif
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        
    }
}

#Preview {
    GameRowView(game: Game.sampleGames[0]) {}
}
