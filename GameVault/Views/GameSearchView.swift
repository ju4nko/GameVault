//
//  GameSearchView.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//

import SwiftUI
import SwiftData

struct GameSearchView: View {
    @State private var vm = GameSearchViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(vm.results) { rawgGame in
                Button() {
                    modelContext.insert(rawgGame.toGame())
                    dismiss()
                } label: {
                    HStack {
                        AsyncImage(url: rawgGame.backgroundImage) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        VStack(alignment: .leading) {
                            Text(rawgGame.name)
                                .font(.headline)
                            if let platforms = rawgGame.platforms {
                                Text(platforms.map { $0.platform.name }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                
            }
            .searchable(text: $vm.query, prompt: "Buscar en RAWG...")
            .task(id: vm.query) {
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                await vm.search()
            }
            .overlay {
                if vm.isLoading {
                    ProgressView()
                } else if let msg = vm.errorMessage {
                    ContentUnavailableView(msg, systemImage: "exclamationmark.triangle")
                } else if vm.query.isEmpty {
                    ContentUnavailableView("Busca un juego", systemImage: "magnifyingglass")
                } else if vm.results.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .navigationTitle("Importar de RAWG")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    GameSearchView()
        .modelContainer(for: Game.self)
}
