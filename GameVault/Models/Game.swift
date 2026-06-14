import Foundation

enum Platform: String, CaseIterable, Codable, Hashable {
    case ps5
    case ps4
    case xboxSeries
    case xboxOne
    case nintendoSwitch
    case pc
    case mobile
    
    var displayName: String {
        switch self {
        case .ps5: "PlayStation 5"
        case .ps4: "PlayStation 4"
        case .xboxSeries: "Xbox Series X|S"
        case .xboxOne: "Xbox One"
        case .nintendoSwitch: "Nintendo Switch"
        case .pc: "PC"
        case .mobile: "Mobile"
        }
        
    }
    
}

enum GameStatus: String, CaseIterable, Codable, Hashable {
    case backlog
    case playing
    case completed
    case abandoned
    case wishlist
    
    var displayName: String {
        switch self {
        case .backlog: "Backlog"
        case .playing: "Jugando"
        case .completed: "Completado"
        case .abandoned: "Abandonado"
        case .wishlist: "En lista de deseados"
        }
    }
}

struct Game: Identifiable, Hashable, Codable {
    let id: UUID = UUID()
    let rawgID: Int?
    var title: String
    var platform: Platform
    var status: GameStatus
    var rating: Int?
    var hoursPlayed: Double
    var coverArtURL: URL?
    var completionDate: Date?
    let dateAdded: Date = .now
    var notes: String?
    
}

extension Game {
    static let sampleGames: [Game] =
        [Game(rawgID: nil, title: "Hollow Knight", platform: .nintendoSwitch, status: .playing, rating: 5, hoursPlayed: 120.5, coverArtURL: nil, completionDate: nil, notes: "Juego de plataformas de acción en el que controlas a un personaje hueco El Hollow Knight, que puede desciende a través de las sombras para atacar."),
         
         Game(rawgID: nil, title: "Clair Obscure: Expedition 33", platform: .pc, status: .completed, rating: 5, hoursPlayed: 60.5, coverArtURL: nil, completionDate: Date(timeIntervalSinceNow: -86400 * 30), notes: "Menudo drama de juego. Además de parrys muy adictivos, hay un sistema de combate muy bien hecho."),
         
         Game(rawgID: nil, title: "AstroBot", platform: .ps5, status: .wishlist, rating: nil, hoursPlayed: 0.0, coverArtURL: nil, completionDate: nil, notes: "No lo sé, aún no he jugado. Pero es un juego de acción de combate en primera persona en el que controlas a un robot que se convierte en un humano para proteger a la humanidad."),
         
         Game(rawgID: nil, title: "Disco Elysium", platform: .ps4, status: .abandoned, rating: 5, hoursPlayed: 20.0, coverArtURL: nil, completionDate: nil, notes: "Aventura conversacional que trata sobre un señor ahorcado y tu tienes que investigar su asesinato. Muy divertido."),
         
         Game(rawgID: nil, title: "Batman Arkham Asylum", platform: .xboxSeries, status: .backlog, rating: 4, hoursPlayed: 20.5, coverArtURL: nil, completionDate: nil, notes: "Contorlas a batman. Nada más que argumentar"),
         
         Game(rawgID: nil, title: "Forza Horizon 5", platform: .xboxOne, status: .playing, rating: 3, hoursPlayed: 12.5, coverArtURL: nil, completionDate: nil, notes: "Son coches. Muy buenos. Muy buenos. Muy buenos."),
         
         Game(rawgID: nil, title: "Pragmata", platform: .mobile, status: .playing, rating: 1, hoursPlayed: 2, coverArtURL: nil, completionDate: nil, notes: "Como va a estar pragmata en mobile. Te estoy tomando el pelo. Juegazao por cierto.")]
}
