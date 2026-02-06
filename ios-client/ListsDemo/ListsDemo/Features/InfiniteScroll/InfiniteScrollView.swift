//
//  InfiniteScrollView.swift
//  ListsDemo
//

import SwiftUI

struct InfiniteScrollView: View {

    @State private var viewModel = ViewModel()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(postId: post.id)) {
                            PostCardView(post: post, repository: viewModel.repository)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(post.id)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentPost: post)
                        }
                    }

                    if viewModel.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Loading more...")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    if !viewModel.hasMore && !viewModel.posts.isEmpty {
                        Text("You've reached the end!")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.restoreState()
                if viewModel.posts.isEmpty {
                    viewModel.loadPosts()
                }
            }
            .onDisappear {
                viewModel.saveState()
            }
        }
        .navigationTitle("Infinite Scroll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.total > 0 {
                    Text("\(viewModel.posts.count) / \(viewModel.total)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "Unknown error")
        }
    }
}

#Preview {
    NavigationStack {
        InfiniteScrollView()
    }
}
