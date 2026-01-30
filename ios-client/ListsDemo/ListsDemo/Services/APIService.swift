//
//  APIService.swift
//  ListsDemo
//

import Foundation

class APIService {
    static let shared = APIService()

    let baseURL = "http://localhost:6969"

    private init() {}

    func fetchPosts(page: Int, perPage: Int = 10) async throws -> PostsResponse {
        guard let url = URL(string: "\(baseURL)/posts?page=\(page)&per_page=\(perPage)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(PostsResponse.self, from: data)
    }

    func fetchPost(id: Int) async throws -> Post {
        guard let url = URL(string: "\(baseURL)/posts/\(id)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Post.self, from: data)
    }

    func imageURL(for post: Post) -> URL? {
        URL(string: "\(baseURL)\(post.imageUrl)")
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
