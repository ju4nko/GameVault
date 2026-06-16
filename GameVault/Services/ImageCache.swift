//
//  ImageCache.swift
//  GameVault
//
//  Created by Juanjo on 16/06/2026.
//
// Services/ImageCache.swift
import Foundation

actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, NSData>()
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 200          // máximo 200 imágenes en memoria
    }
    
    func data(for url: URL) async throws -> Data {
        // 1. Check cache
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }
        // 2. Download
        let (data, _) = try await session.data(from: url)
        // 3. Store
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }
}
