//
//  HomeView.swift
//  ListsDemo
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("List Loading Patterns")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose a pattern to explore")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                NavigationLink(destination: InfiniteScrollView()) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Infinite Scrolling")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                NavigationLink(destination: PaginationView()) {
                    HStack {
                        Image(systemName: "book.pages.fill")
                        Text("Pagination")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
