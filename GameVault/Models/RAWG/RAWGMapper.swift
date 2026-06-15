//
//  RAWGMapper.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//
// Models/RAWG/RAWGMapper.swift
import Foundation

extension RAWGGame {
    func toGame() -> Game {
        Game(
            rawgID: self.id,
            title: self.name,
            platform: inferredPlatform,
            status: .backlog,
            coverArtURL: self.backgroundImage
        )
    }
    
    private var inferredPlatform: Platform {
        guard let platforms else { return .pc }
        for wrapper in platforms {
            switch wrapper.platform.slug {
            case "playstation5":         return .ps5
            case "playstation4":         return .ps4
            case "xbox-series-x":        return .xboxSeries
            case "xbox-one":             return .xboxOne
            case "nintendo-switch":      return .nintendoSwitch
            case "pc":                   return .pc
            case "ios", "android":       return .mobile
            default:                     continue
            }
        }
        return .pc
    }
}


