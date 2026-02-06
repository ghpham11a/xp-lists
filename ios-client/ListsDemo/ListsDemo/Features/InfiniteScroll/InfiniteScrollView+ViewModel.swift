//
//  InfiniteScrollView+ViewModel.swift
//  ListsDemo
//

import SwiftUI

extension InfiniteScrollView {
    @Observable
    class ViewModel {

        let repository: PostRepository

        init() {
            repository = DIContainer.shared.resolve(PostRepository.self)
        }

        var posts: [Post] = []
        var isLoading = false
        var hasMore = true
        var total = 0
        var currentPage = 1
        var error: String?

        private let perPage = 20

        func loadMoreIfNeeded(currentPost: Post) {
            guard let lastPost = posts.last,
                  currentPost.id == lastPost.id,
                  !isLoading,
                  hasMore else {
                return
            }
            loadPosts()
        }

        func loadPosts() {
            guard !isLoading else { return }

            isLoading = true
            error = nil

            Task {
                do {
                    let response = try await repository.fetchPosts(page: currentPage, perPage: perPage)
                    await MainActor.run {
                        posts.append(contentsOf: response.posts)
                        total = response.total
                        hasMore = currentPage < response.totalPages
                        currentPage += 1
                        isLoading = false
                        saveState()
                    }
                } catch {
                    await MainActor.run {
                        self.error = error.localizedDescription
                        isLoading = false
                    }
                }
            }
        }

        func saveState() {
            let state = InfiniteScrollState(
                postIds: posts.map { $0.id },
                currentPage: currentPage,
                total: total,
                hasMore: hasMore
            )
            if let encoded = try? JSONEncoder().encode(state) {
                UserDefaults.standard.set(encoded, forKey: "infinite-scroll-state")
            }
        }

        func restoreState() {
            guard let data = UserDefaults.standard.data(forKey: "infinite-scroll-state"),
                  let state = try? JSONDecoder().decode(InfiniteScrollState.self, from: data) else {
                return
            }

            currentPage = state.currentPage
            total = state.total
            hasMore = state.hasMore

            if !state.postIds.isEmpty && posts.isEmpty {
                Task {
                    await loadSavedPosts(ids: state.postIds)
                }
            }
        }

        private func loadSavedPosts(ids: [Int]) async {
            var loadedPosts: [Post] = []

            let pagesToLoad = (ids.count + perPage - 1) / perPage
            for page in 1...pagesToLoad {
                do {
                    let response = try await repository.fetchPosts(page: page, perPage: perPage)
                    loadedPosts.append(contentsOf: response.posts)
                } catch {
                    break
                }
            }

            await MainActor.run {
                posts = loadedPosts.filter { ids.contains($0.id) }
            }
        }
    }
}

struct InfiniteScrollState: Codable {
    let postIds: [Int]
    let currentPage: Int
    let total: Int
    let hasMore: Bool
}
