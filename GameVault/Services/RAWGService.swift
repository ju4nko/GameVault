//
//  RAWGService.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//
import Foundation

struct RAWGService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func searchGames(query: String, pageSize: Int = 20) async throws -> [RAWGGame] {
        
        // Construir URL con URLComponents
        guard var components = URLComponents(
            url: RAWGConfig.baseURL.appendingPathComponent("games"),
            resolvingAgainstBaseURL: false
        ) else {
            throw RAWGError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: RAWGConfig.apiKey),
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]

        guard let url = components.url else {
            throw RAWGError.invalidURL
        }
        
        // Petición con async/await
        let (data, response) = try await session.data(from: url)
        
        // Validar el status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RAWGError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RAWGError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decodificar
        do {
            let decoded = try decoder.decode(RAWGSearchResponse.self, from: data)
            return decoded.results
        } catch {
            throw RAWGError.decodingFailed(underlying: error)
        }
    }
}

enum RAWGError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "URL malformada"
        case .invalidResponse:
            "Respuesta inválida del servidor"
        case .httpError(let code):
            "Error HTTP \(code)"
        case .decodingFailed(let error):
            "Error al decodificar: \(error.localizedDescription)"
        }
    }
}
