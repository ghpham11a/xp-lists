//
//  ImageCache.swift
//  ListsDemo
//

import UIKit

/// Two-layer image cache: NSCache (memory) + FileManager (disk).
/// Memory cache is automatically evicted under memory pressure.
/// Disk cache persists in the Caches directory across app launches.
final class ImageCache: @unchecked Sendable {

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)

        memoryCache.countLimit = 100
    }

    /// Returns a cached image or fetches from network, caching the result in both layers.
    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString

        // 1. Memory cache
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        // 2. Disk cache
        let filePath = diskCacheURL.appendingPathComponent(diskKey(for: key))
        if let data = try? Data(contentsOf: filePath),
           let diskImage = UIImage(data: data) {
            memoryCache.setObject(diskImage, forKey: key as NSString)
            return diskImage
        }

        // 3. Network fetch
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let networkImage = UIImage(data: data) else {
            throw ImageCacheError.decodingFailed
        }

        memoryCache.setObject(networkImage, forKey: key as NSString)
        try? data.write(to: filePath)

        return networkImage
    }

    /// SHA256-based filename to avoid invalid filesystem characters.
    private func diskKey(for key: String) -> String {
        let data = Data(key.utf8)
        let hash = data.withUnsafeBytes { bytes -> String in
            var result = ""
            for byte in bytes {
                result += String(format: "%02x", byte)
            }
            return result
        }
        return hash
    }
}

enum ImageCacheError: Error {
    case decodingFailed
}
