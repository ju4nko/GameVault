//
//  ContentView.swift
//  GameVault
//
//  Created by Juanjo on 14/06/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [Game]
    var body: some View {
        
        NavigationStack {
            if games.isEmpty {
                ContentUnavailableView("Tu biblioteca está vacía", systemImage: "gamecontroller", description: Text("Añade tu primer juego con el botón +"))
            } else {
                List {
                    ForEach(games) { game in
                        GameRowView(game: game) {
                            modelContext.delete(game)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(game)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                    
                }
                .navigationTitle("Mi biblioteca")
                .onAppear {
                    if games.isEmpty {
                        for game in Game.sampleGames {
                            modelContext.insert(game)
                        }
                    }
                }
            }
            
        }.toolbar {
            ToolbarItem {
                Button {
                    let nuevo = Game(title: "Nuevo juego", platform: .ps5, status: .playing)
                    modelContext.insert(nuevo)
                } label: {
                    Label("Añadir juego", systemImage: "plus")
                }
            }
        }
    }
    
}



#Preview {
    ContentView().modelContainer(for: Game.self)
}
