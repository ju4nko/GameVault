//
//  StatsViewModel.swift
//  GameVault
//
//  Created by Juanjo on 20/06/2026.
//
// ViewModels/StatsViewModel.swift
import Foundation

@MainActor
@Observable
final class StatsViewModel {
    private(set) var games: [Game] = []
    
    func update(with games: [Game]) {
        self.games = games
    }
    
    // MARK: - Agregaciones simples
    
    var totalGames: Int { games.count }
    
    var totalHoursPlayed: Double {
        games.reduce(0) { $0 + $1.hoursPlayed }
    }
    
    var averageRating: Double? {
        let rated = games.compactMap { $0.rating }
        guard !rated.isEmpty else { return nil }
        return Double(rated.reduce(0, +)) / Double(rated.count)
    }
    
    // MARK: - Agregaciones por categoría (para charts)
    
    var gamesByStatus: [(status: GameStatus, count: Int)] {
        GameStatus.allCases.map { status in
            (status, games.filter { $0.status == status }.count)
        }
        .filter { $0.count > 0 }       // omite categorías vacías
    }
    
    var hoursByPlatform: [(platform: Platform, hours: Double)] {
        Platform.allCases.map { platform in
            (platform, games.filter { $0.platform == platform }
                            .reduce(0) { $0 + $1.hoursPlayed })
        }
        .filter { $0.hours > 0 }
    }
    
    var completedByMonth: [(month: Date, count: Int)] {
        let completed = games.compactMap { $0.completionDate }
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: completed) { date in
            calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        }
        
        return grouped
            .map { ($0.key, $0.value.count) }
            .sorted { $0.0 < $1.0 }
    }
    
    var topGamesByHours: [Game] {
        Array(games.sorted { $0.hoursPlayed > $1.hoursPlayed }.prefix(5))
    }
}
