//
//  GameSearchViewModel.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//
import Foundation

@MainActor
@Observable
final class GameSearchViewModel {
    
    // Estado expuesto
    var query: String = ""
    var results: [RAWGGame] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // Dependencias
    private let service: RAWGService
    
    init(service: RAWGService? = nil) {
        self.service = service ?? RAWGService()
    }
    
    func search() async {
        // Si query vacío, limpiar resultados
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }    // se ejecuta SIEMPRE al salir, éxito o error
        
        do {
            results = try await service.searchGames(query: query, pageSize: 20)
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
    }
}

