//
//  PaginationView.swift
//  ListsDemo
//

import SwiftUI

struct PaginationView: View {

    @State private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                NavigationLink(destination: PostDetailView(postId: post.id)) {
                                    PostCardView(post: post, repository: viewModel.repository)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .id(post.id)
                            }
                        }
                        .padding()
                        .id("top")
                    }
                    .onChange(of: viewModel.currentPage) { _, _ in
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
            viewModel.restoreState()
            viewModel.loadPage()
        }
        .onDisappear {
            viewModel.saveState()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "Unknown error")
        }
    }

    private var paginationControls: some View {
        VStack(spacing: 8) {
            Divider()

            HStack(spacing: 8) {
                Button {
                    if viewModel.currentPage > 1 {
                        viewModel.currentPage -= 1
                        viewModel.loadPage()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.currentPage <= 1 || viewModel.isLoading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.pageNumbers, id: \.self) { page in
                            if page == -1 {
                                Text("...")
                                    .foregroundColor(.secondary)
                                    .frame(width: 44, height: 44)
                            } else {
                                Button {
                                    viewModel.currentPage = page
                                    viewModel.loadPage()
                                } label: {
                                    Text("\(page)")
                                        .frame(width: 44, height: 44)
                                        .background(viewModel.currentPage == page ? Color.blue : Color.clear)
                                        .foregroundColor(viewModel.currentPage == page ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                    }
                }

                Button {
                    if viewModel.currentPage < viewModel.totalPages {
                        viewModel.currentPage += 1
                        viewModel.loadPage()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.currentPage >= viewModel.totalPages || viewModel.isLoading)
            }
            .padding(.horizontal)

            Text("Page \(viewModel.currentPage) of \(viewModel.totalPages) (\(viewModel.total) total posts)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        PaginationView()
    }
}
