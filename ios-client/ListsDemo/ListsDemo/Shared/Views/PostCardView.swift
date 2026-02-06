//
//  PostCardView.swift
//  ListsDemo
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    var repository: PostRepository = DIContainer.shared.resolve(PostRepository.self)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CachedAsyncImage(url: repository.imageURL(for: post), height: 200, cornerRadius: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(post.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PostCardView(post: Post(
        id: 1,
        title: "Sample Post Title",
        imageUrl: "/static/pic_1.png",
        description: "This is a sample description for the post."
    ))
    .padding()
}
