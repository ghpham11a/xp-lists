//
//  PostRepository.swift
//  ListsDemo
//

import Foundation

protocol PostRepository {
    func fetchPosts(page: Int, perPage: Int) async throws -> PostsResponse
    func fetchPost(id: Int) async throws -> Post
    func imageURL(for post: Post) -> URL?
}

class APIPostRepository: PostRepository {
    private let api = APIService.shared

    func fetchPosts(page: Int, perPage: Int = 10) async throws -> PostsResponse {
        try await api.fetchPosts(page: page, perPage: perPage)
    }

    func fetchPost(id: Int) async throws -> Post {
        try await api.fetchPost(id: id)
    }

    func imageURL(for post: Post) -> URL? {
        api.imageURL(for: post)
    }
}
