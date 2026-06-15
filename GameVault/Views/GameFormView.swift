//
//  GameFormView.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//

import SwiftUI
import SwiftData

struct GameFormView: View {
    
    let gameToEdit: Game?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Estado local (sub-patrón B)
    @State private var title: String = ""
    @State private var platform: Platform = .pc
    @State private var status: GameStatus = .backlog
    @State private var rating: Int? = nil
    @State private var hoursPlayed: Double = 0
    @State private var completionDate: Date = .now
    @State private var notes: String = ""
    
    init(gameToEdit: Game? = nil) {
        self.gameToEdit = gameToEdit
        _title = State(initialValue: gameToEdit?.title ?? "")
        _platform = State(initialValue: gameToEdit?.platform ?? .pc)
        _status = State(initialValue: gameToEdit?.status ?? .backlog)
        _rating = State(initialValue: gameToEdit?.rating)        // ya es Int?
        _hoursPlayed = State(initialValue: gameToEdit?.hoursPlayed ?? 0)
        _completionDate = State(initialValue: gameToEdit?.completionDate ?? .now)
        _notes = State(initialValue: gameToEdit?.notes ?? "")
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información") {
                    TextField("Título", text: $title)
                    Picker("Plataforma", selection: $platform) {
                        ForEach(Platform.allCases, id: \.self) { platform in
                            Text(platform.displayName).tag(platform)
                        }
                    }
                    Picker("Estado", selection: $status) {
                        ForEach(GameStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
                
                Section("Progreso") {
                    Picker("Rating", selection: $rating) {
                        Text("Sin valorar").tag(Int?.none)
                        ForEach(1...5, id: \.self) { value in
                            Text("\(value) ⭐").tag(Int?.some(value))
                        }
                    }
                    TextField("Horas jugadas", value: $hoursPlayed, format: .number)
                    
                    if status == .completed {
                        DatePicker("Fecha finalizado", selection: $completionDate, in: ...Date.now, displayedComponents: .date)
                    }
                }
                Section("Notas") {
                    
                    // Aquí debería ir el coverArtURL
                    TextField("Notas", text: $notes, axis: .vertical) .lineLimit(3...10)
                        .textFieldStyle(.roundedBorder)
                    
                }
                
            }
            .formStyle(.grouped)
            .frame(minWidth: 450, minHeight: 600)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        save()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle(gameToEdit == nil ? "Nuevo juego": "Editar juego")
        }
    }
    
    private func save() {
        if let game = gameToEdit {
            // EDIT: mutar las propiedades del Game existente
            game.title = title
            game.platform = platform
            game.status = status
            game.rating = rating
            game.hoursPlayed = hoursPlayed
            game.completionDate = (status == .completed) ? completionDate : nil
            game.notes = notes.isEmpty ? nil : notes
        } else {
            // CREATE: instanciar un nuevo Game e insertarlo
            let nuevo = Game(
                title: title,
                platform: platform,
                status: status,
                rating: rating,
                hoursPlayed: hoursPlayed,
                completionDate: (status == .completed) ? completionDate : nil,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(nuevo)
        }
    }
}

#Preview {
    GameFormView(gameToEdit: nil)
        .modelContainer(for: Game.self)
}
