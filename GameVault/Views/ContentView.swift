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
    
    @State private var isShowingForm: Bool = false
    @State private var gameBeingEdited: Game? = nil
    
    var body: some View {
        
        NavigationStack {
            Group {
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
                            .onTapGesture {
                                gameBeingEdited = game
                            }
                            
                        }
                        
                    }
                    .navigationTitle("Mi biblioteca")
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction){
                    Button {
                        isShowingForm = true
                    } label: {
                        Label("Añadir juego", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingForm) {
            GameFormView()
        }
        .sheet(item: $gameBeingEdited) { game in
            GameFormView(gameToEdit: game)
        }
    }
    
}



#Preview {
    ContentView().modelContainer(for: Game.self)
}
