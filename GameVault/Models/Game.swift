import Foundation
import SwiftData
import SwiftUI


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
    
    var iconName: String {
        switch self {
        case .backlog: "tray.full"
        case .playing: "play.fill"
        case .completed: "checkmark.circle.fill"
        case .abandoned: "xmark.circle"
        case .wishlist: "heart.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .backlog: .orange
        case .playing: .blue
        case .completed: .green
        case .abandoned: .gray
        case .wishlist: .pink
        }
    }
}

@Model
final class Game {
    var id: UUID
    var rawgID: Int?
    var title: String
    var platform: Platform
    var status: GameStatus
    var rating: Int?
    var hoursPlayed: Double
    var coverArtURL: URL?
    var completionDate: Date?
    var dateAdded: Date
    var notes: String?
    
    init(id: UUID = UUID(),
         rawgID: Int? = nil,
         title: String,
         platform: Platform,
         status: GameStatus,
         rating: Int? = nil,
         hoursPlayed: Double = 0,
         coverArtURL: URL? = nil,
         completionDate: Date? = nil,
         dateAdded: Date = .now,
         notes: String? = nil) {
        
        self.id = id
        self.rawgID = rawgID
        self.title = title
        self.platform = platform
        self.status = status
        self.rating = rating
        self.hoursPlayed = hoursPlayed
        self.coverArtURL = coverArtURL
        self.completionDate = completionDate
        self.dateAdded = dateAdded
        self.notes = notes
        
    }
    
}

extension Game {
    static let sampleGames: [Game] = [
        Game(
            title: "Hollow Knight",
            platform: .nintendoSwitch,
            status: .playing,
            rating: 5,
            hoursPlayed: 120.5,
            notes: "Juego de plataformas de acción en el que controlas a un personaje hueco El Hollow Knight, que puede desciende a través de las sombras para atacar."
        ),
        Game(
            title: "Clair Obscure: Expedition 33",
            platform: .pc,
            status: .completed,
            rating: 5,
            hoursPlayed: 60.5,
            completionDate: Date(timeIntervalSinceNow: -86400 * 30),
            notes: "Menudo drama de juego. Además de parrys muy adictivos, hay un sistema de combate muy bien hecho."
        ),
        Game(
            title: "AstroBot",
            platform: .ps5,
            status: .wishlist,
            notes: "No lo sé, aún no he jugado. Pero es un juego de acción de combate en primera persona en el que controlas a un robot que se convierte en un humano para proteger a la humanidad."
        ),
        Game(
            title: "Disco Elysium",
            platform: .ps4,
            status: .abandoned,
            rating: 5,
            hoursPlayed: 20,
            notes: "Aventura conversacional que trata sobre un señor ahorcado y tu tienes que investigar su asesinato. Muy divertido."
        ),
        Game(
            title: "Batman Arkham Asylum",
            platform: .xboxSeries,
            status: .backlog,
            rating: 4,
            hoursPlayed: 20.5,
            notes: "Contorlas a batman. Nada más que argumentar"
        ),
        Game(
            title: "Forza Horizon 5",
            platform: .xboxOne,
            status: .playing,
            rating: 3,
            hoursPlayed: 12.5,
            notes: "Son coches. Muy buenos. Muy buenos. Muy buenos."
        ),
        Game(
            title: "Pragmata",
            platform: .mobile,
            status: .playing,
            rating: 1,
            hoursPlayed: 2,
            notes: "Como va a estar pragmata en mobile. Te estoy tomando el pelo. Juegazao por cierto."
        )
    ]
}
