//
//  PostDetailView+ViewModel.swift
//  ListsDemo
//
//  Created by Anthony Pham on 2/6/26.
//
import SwiftUI

extension PostDetailView {

    enum ViewState {
        case loading
        case error(String)
        case loaded(Post)
    }

    @Observable
    class ViewModel {

        let repository: PostRepository

        init() {
            repository = DIContainer.shared.resolve(PostRepository.self)
        }

        var state: ViewState = .loading

        var post: Post? {
            if case .loaded(let post) = state { return post }
            return nil
        }

        func loadPost(postId: Int) {
            state = .loading
            Task {
                do {
                    let fetchedPost = try await repository.fetchPost(id: postId)
                    await MainActor.run {
                        state = .loaded(fetchedPost)
                    }
                } catch {
                    await MainActor.run {
                        state = .error(error.localizedDescription)
                    }
                }
            }
        }
    }
}
