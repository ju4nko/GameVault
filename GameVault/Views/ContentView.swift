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
    @State private var isShowingSearch: Bool = false
    @State private var searchText: String = ""
    @State private var statusFilter: GameStatus? = nil
    @State private var platformFilter: Platform? = nil
    @State private var sortOption: SortOption = .dateAddedNewest
    
    private var filteredGames: [Game] {
        games.filter { game in
            let matchesSearch = searchText.isEmpty || game.title.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = statusFilter == nil || game.status == statusFilter
            let matchesPlatform = platformFilter == nil || game.platform == platformFilter
            
            return matchesSearch && matchesStatus && matchesPlatform
        }
    }
    
    private var sortedGames: [Game] {
        switch sortOption {
        case .titleAZ:
            return filteredGames.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleZA:
            return filteredGames.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        case .dateAddedNewest:
            return filteredGames.sorted { $0.dateAdded > $1.dateAdded }
        case .dateAddedOldest:
            return filteredGames.sorted { $0.dateAdded < $1.dateAdded }
        case .hoursPlayedMost:
            return filteredGames.sorted { $0.hoursPlayed > $1.hoursPlayed }
        case .hoursPlayedLeast:
            return filteredGames.sorted { $0.hoursPlayed < $1.hoursPlayed }
        case .ratingHighest:
            return filteredGames.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .ratingLowest:
            return filteredGames.sorted { ($0.rating ?? 6) < ($1.rating ?? 6) }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if games.isEmpty {
                    ContentUnavailableView("Tu biblioteca está vacía", systemImage: "gamecontroller", description: Text("Añade tu primer juego con el botón +"))
                } else if filteredGames.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(sortedGames) { game in
                            NavigationLink(value: game) {
                                GameRowView(game: game) {
                                    modelContext.delete(game)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        modelContext.delete(game)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .searchable(text: $searchText, prompt: "Buscar en tu biblioteca")
            .navigationTitle("Mi biblioteca")
            .toolbar {
                ToolbarItem(){
                    Menu {
                        Button {
                            isShowingForm = true
                        } label: {
                            Label("Añadir manualmente", systemImage: "square.and.pencil")
                        }
                        
                        Button {
                            isShowingSearch = true
                        } label: {
                            Label("Buscar en RAWG", systemImage: "magnifyingglass")
                        }
                    } label: {
                        Label("Añadir juego", systemImage: "plus")
                    }
                }
                ToolbarSpacer(.fixed)
                ToolbarItem() {
                    Menu {
                        Picker("Estado", selection: $statusFilter) {
                            Text("Todos los estados").tag(GameStatus?.none)
                            ForEach(GameStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(GameStatus?.some(status))
                            }
                        }
                        
                        Picker("Plataforma", selection: $platformFilter) {
                            Text("Todas las plataformas").tag(Platform?.none)
                            ForEach(Platform.allCases, id: \.self) { platform in
                                Text(platform.displayName).tag(Platform?.some(platform))
                            }
                        }
                        
                        if statusFilter != nil || platformFilter != nil {
                            Divider()
                            Button(role: .destructive) {
                                statusFilter = nil
                                platformFilter = nil
                            } label: {
                                Label("Limpiar filtros", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Label("Filtros", systemImage: (statusFilter != nil || platformFilter != nil)
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease")
                    }
                }
                ToolbarSpacer(.fixed)
                

                ToolbarItem {
                    Menu {
                        Picker("Ordenar por", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Ordenar", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingForm) {
            GameFormView()
        }
        .sheet(isPresented: $isShowingSearch) {
            GameSearchView()
        }
    }
    
}



#Preview {
    ContentView().modelContainer(for: Game.self)
}
