//
//  Post.swift
//  ListsDemo
//

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let imageUrl: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl = "image_url"
        case description
    }
}

struct PostsResponse: Codable {
    let posts: [Post]
    let total: Int
    let page: Int
    let perPage: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case posts
        case total
        case page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
}
