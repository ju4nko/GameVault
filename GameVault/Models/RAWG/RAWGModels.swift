//
//  RAWGModels.swift
//  GameVault
//
//  Created by Juanjo on 15/06/2026.
//
import Foundation

struct RAWGSearchResponse : Decodable{
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [RAWGGame]
}

struct RAWGGame: Decodable, Identifiable{
    let id: Int
    let slug: String
    let name: String
    let released: String?
    let backgroundImage: URL?
    let rating: Double
    let platforms: [RAWGPlatformWrapper]?
    
    enum CodingKeys: String, CodingKey {
        case id, slug, name, released
        case backgroundImage = "background_image"
        case rating, platforms
    }
}

struct RAWGPlatformWrapper: Decodable {
    let platform: RAWGPlatform
}

struct RAWGPlatform: Decodable {
    let id: Int
    let name: String
    let slug: String
}
