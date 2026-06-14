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
