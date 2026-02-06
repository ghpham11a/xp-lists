//
//  CachedAsyncImage.swift
//  ListsDemo
//

import SwiftUI

/// Drop-in replacement for AsyncImage that uses ImageCache for
/// memory + disk caching. Prevents re-downloading images on scroll.
struct CachedAsyncImage: View {
    let url: URL?
    var height: CGFloat = 200
    var cornerRadius: CGFloat = 8

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasFailed = false

    private let cache: ImageCache = DIContainer.shared.resolve(ImageCache.self)

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipped()
            } else if hasFailed {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .cornerRadius(cornerRadius)
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else {
            hasFailed = true
            isLoading = false
            return
        }

        do {
            let loaded = try await cache.image(for: url)
            image = loaded
        } catch {
            hasFailed = true
        }
        isLoading = false
    }
}
