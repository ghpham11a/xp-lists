//
//  PostDetailView.swift
//  ListsDemo
//

import SwiftUI

struct PostDetailView: View {
    let postId: Int

    @State private var post: Post?
    @State private var isLoading = true
    @State private var error: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                }
            } else if let error = error {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.headline)
                    Text(error)
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
            } else if let post = post {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: APIService.shared.imageURL(for: post)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 300)
                                    .overlay {
                                        ProgressView()
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 300)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                    }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(12)

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
        .navigationTitle(post?.title ?? "Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPost()
        }
    }

    private func loadPost() {
        Task {
            do {
                let fetchedPost = try await APIService.shared.fetchPost(id: postId)
                await MainActor.run {
                    post = fetchedPost
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postId: 1)
    }
}
