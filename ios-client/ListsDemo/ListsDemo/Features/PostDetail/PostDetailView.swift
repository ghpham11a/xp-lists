//
//  PostDetailView.swift
//  ListsDemo
//

import SwiftUI

struct PostDetailView: View {
    let postId: Int

    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                }
            case .error(let message):
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Go Back") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding()
            case .loaded(let post):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        CachedAsyncImage(url: viewModel.repository.imageURL(for: post), height: 300, cornerRadius: 12)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(post.title)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(post.description)
                                .font(.body)
                                .foregroundColor(.secondary)

                            Divider()

                            HStack {
                                Text("Post ID:")
                                    .foregroundColor(.secondary)
                                Text("\(post.id)")
                                    .fontWeight(.medium)
                            }
                            .font(.footnote)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle(viewModel.post?.title ?? "Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPost(postId: postId)
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postId: 1)
    }
}
