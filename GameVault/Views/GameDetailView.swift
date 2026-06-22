//
//  GameDetailView.swift
//  GameVault
//
//  Created by Juanjo on 17/06/2026.
//

import SwiftUI
import SwiftData

struct GameDetailView: View {
    let game: Game
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Hero image
                CachedAsyncImage(url: game.coverArtURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default:
                        ZStack {
                            LinearGradient(
                                colors: [game.status.iconColor.opacity(0.6), game.status.iconColor.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: game.status.iconName)
                                .font(.system(size: 100))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    }
                }
                .frame(height: 240)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // 2. Título + plataforma
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.title).font(.largeTitle).bold()
                        Text(game.platform.displayName).foregroundStyle(.secondary)
                    }
                    
                    // 3. Badge de estado
                    Label(game.status.displayName, systemImage: game.status.iconName)
                        .foregroundStyle(game.status.iconColor)
                        .font(.headline)
                    
                    Divider()
                    
                    // 4. Stats
                    statRow("Horas jugadas", value: "\(game.hoursPlayed.formatted())h")
                    if let rating = game.rating {
                        statRow("Rating", value: String(repeating: "⭐", count: rating))
                    }
                    statRow("Añadido", value: game.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    if let completed = game.completionDate {
                        statRow("Completado", value: completed.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                    // 5. Notas
                    if let notes = game.notes, !notes.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas").font(.headline)
                            Text(notes).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)   // iOS
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    isEditing = true
                }.buttonStyle(.glass)
            }
        }
        .sheet(isPresented: $isEditing) {
            GameFormView(gameToEdit: game)
        }
    }
    
    @ViewBuilder
    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: Game.sampleGames[0])
            
    }
    .modelContainer(for: Game.self)
}
