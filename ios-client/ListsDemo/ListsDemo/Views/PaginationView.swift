//
//  PaginationView.swift
//  ListsDemo
//

import SwiftUI

struct PaginationView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var currentPage = 1
    @State private var totalPages = 1
    @State private var total = 0
    @State private var error: String?

    private let perPage = 10

    var body: some View {
        VStack(spacing: 0) {
            if isLoading && posts.isEmpty {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                NavigationLink(destination: PostDetailView(postId: post.id)) {
                                    PostCardView(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .id(post.id)
                            }
                        }
                        .padding()
                        .id("top")
                    }
                    .onChange(of: currentPage) { _, _ in
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }

            paginationControls
        }
        .navigationTitle("Pagination")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            restoreState()
            loadPage()
        }
        .onDisappear {
            saveState()
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "Unknown error")
        }
    }

    private var paginationControls: some View {
        VStack(spacing: 8) {
            Divider()

            HStack(spacing: 8) {
                Button {
                    if currentPage > 1 {
                        currentPage -= 1
                        loadPage()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .disabled(currentPage <= 1 || isLoading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(pageNumbers, id: \.self) { page in
                            if page == -1 {
                                Text("...")
                                    .foregroundColor(.secondary)
                                    .frame(width: 44, height: 44)
                            } else {
                                Button {
                                    currentPage = page
                                    loadPage()
                                } label: {
                                    Text("\(page)")
                                        .frame(width: 44, height: 44)
                                        .background(currentPage == page ? Color.blue : Color.clear)
                                        .foregroundColor(currentPage == page ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .disabled(isLoading)
                            }
                        }
                    }
                }

                Button {
                    if currentPage < totalPages {
                        currentPage += 1
                        loadPage()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                }
                .disabled(currentPage >= totalPages || isLoading)
            }
            .padding(.horizontal)

            Text("Page \(currentPage) of \(totalPages) (\(total) total posts)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private var pageNumbers: [Int] {
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

    private func loadPage() {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        Task {
            do {
                let response = try await APIService.shared.fetchPosts(page: currentPage, perPage: perPage)
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

    private func saveState() {
        UserDefaults.standard.set(currentPage, forKey: "pagination-state")
    }

    private func restoreState() {
        let savedPage = UserDefaults.standard.integer(forKey: "pagination-state")
        if savedPage > 0 {
            currentPage = savedPage
        }
    }
}

#Preview {
    NavigationStack {
        PaginationView()
    }
}
