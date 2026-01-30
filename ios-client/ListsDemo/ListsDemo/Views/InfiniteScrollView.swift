//
//  InfiniteScrollView.swift
//  ListsDemo
//

import SwiftUI

struct InfiniteScrollView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var hasMore = true
    @State private var total = 0
    @State private var currentPage = 1
    @State private var error: String?

    @Environment(\.dismiss) private var dismiss

    private let perPage = 20

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(postId: post.id)) {
                            PostCardView(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(post.id)
                        .onAppear {
                            loadMoreIfNeeded(currentPost: post)
                        }
                    }

                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Loading more...")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    if !hasMore && !posts.isEmpty {
                        Text("You've reached the end!")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .onAppear {
                restoreState()
                if posts.isEmpty {
                    loadPosts()
                }
            }
            .onDisappear {
                saveState()
            }
        }
        .navigationTitle("Infinite Scroll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if total > 0 {
                    Text("\(posts.count) / \(total)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "Unknown error")
        }
    }

    private func loadMoreIfNeeded(currentPost: Post) {
        guard let lastPost = posts.last,
              currentPost.id == lastPost.id,
              !isLoading,
              hasMore else {
            return
        }
        loadPosts()
    }

    private func loadPosts() {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        Task {
            do {
                let response = try await APIService.shared.fetchPosts(page: currentPage, perPage: perPage)
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

    private func saveState() {
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

    private func restoreState() {
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
                let response = try await APIService.shared.fetchPosts(page: page, perPage: perPage)
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

struct InfiniteScrollState: Codable {
    let postIds: [Int]
    let currentPage: Int
    let total: Int
    let hasMore: Bool
}

#Preview {
    NavigationStack {
        InfiniteScrollView()
    }
}
