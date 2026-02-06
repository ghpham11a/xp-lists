//
//  PaginationView+ViewModel.swift
//  ListsDemo
//
//  Created by Anthony Pham on 2/6/26.
//
import SwiftUI

extension PaginationView {
    @Observable
    class ViewModel {

        let repository: PostRepository

        init() {
            repository = DIContainer.shared.resolve(PostRepository.self)
        }

        var posts: [Post] = []
        var isLoading = false
        var currentPage = 1
        var totalPages = 1
        var total = 0
        var error: String?

        private let perPage = 10

        var pageNumbers: [Int] {
            guard totalPages > 0 else { return [] }

            if totalPages <= 7 {
                return Array(1...totalPages)
            }

            var pages: [Int] = []

            pages.append(1)

            if currentPage > 3 {
                pages.append(-1)
            }

            let start = max(2, currentPage - 1)
            let end = min(totalPages - 1, currentPage + 1)

            for page in start...end {
                if !pages.contains(page) {
                    pages.append(page)
                }
            }

            if currentPage < totalPages - 2 {
                pages.append(-1)
            }

            if !pages.contains(totalPages) {
                pages.append(totalPages)
            }

            return pages
        }

        func loadPage() {
            guard !isLoading else { return }

            isLoading = true
            error = nil

            Task {
                do {
                    let response = try await repository.fetchPosts(page: currentPage, perPage: perPage)
                    await MainActor.run {
                        posts = response.posts
                        totalPages = response.totalPages
                        total = response.total
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
            UserDefaults.standard.set(currentPage, forKey: "pagination-state")
        }

        func restoreState() {
            let savedPage = UserDefaults.standard.integer(forKey: "pagination-state")
            if savedPage > 0 {
                currentPage = savedPage
            }
        }
    }
}
