# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftUI iOS client for the lists demo app, showcasing infinite scrolling and traditional pagination patterns. Mirrors the functionality of the NextJS frontend. Requires the FastAPI backend server running (see parent repo's CLAUDE.md).

## Development

Open `ListsDemo/ListsDemo.xcodeproj` in Xcode and run on simulator or device.

- **Xcode 26.1.1+** required (iOS 26.1 deployment target, Swift 5)
- **Swinject 2.10.0** is the only external dependency (via SPM)
- Backend must be running at the URL configured in `Data/Networking/APIService.swift` (`baseURL` property)
- For simulator: set `baseURL` to `http://localhost:6969`
- For physical device: run `ngrok http --hostname=feedback-test.ngrok.io 6969` and use the ngrok URL

Command-line build:
```bash
xcodebuild -project ListsDemo/ListsDemo.xcodeproj -scheme ListsDemo -sdk iphonesimulator build
```

## Architecture

```
ListsDemo/ListsDemo/
├── App/                                # Entry point + DI setup
│   ├── ListsDemoApp.swift              # @main → ContentView
│   ├── ContentView.swift               # NavigationStack → HomeView
│   └── DIContainer.swift               # Swinject container (all registrations here)
├── Data/
│   ├── Models/Post.swift               # Post + PostsResponse (Codable, snake_case mapping)
│   ├── Networking/
│   │   ├── APIService.swift            # Singleton HTTP client (baseURL configured here)
│   │   └── ImageCache.swift            # Memory (NSCache) + disk (FileManager) image cache
│   └── Repositories/PostRepository.swift  # Protocol + APIPostRepository implementation
├── Features/                           # One directory per screen, each has View + ViewModel
│   ├── Home/HomeView.swift
│   ├── InfiniteScroll/                 # InfiniteScrollView.swift + InfiniteScrollView+ViewModel.swift
│   ├── Pagination/                     # PaginationView.swift + PaginationView+ViewModel.swift
│   └── PostDetail/                     # PostDetailView.swift + PostDetailView+ViewModel.swift
└── Shared/Views/
    ├── PostCardView.swift              # Reusable card component
    └── CachedAsyncImage.swift          # Drop-in AsyncImage replacement with caching
```

## Key Patterns

### View + ViewModel

Each feature uses an `@Observable` ViewModel class defined as a nested type in a `*+ViewModel.swift` extension file. Views own their ViewModel via `@State private var viewModel = ViewModel()`. Views are pure UI; all state and logic live in the ViewModel.

### Dependency Injection

Swinject-based DI via `DIContainer.shared`. All registrations are in `App/DIContainer.swift`. ViewModels resolve dependencies in `init()`:
```swift
let repository: PostRepository
init() { repository = DIContainer.shared.resolve(PostRepository.self) }
```
- `PostRepository` — transient scope (new instance per resolution)
- `ImageCache` — `.container` scope (single shared instance)

### Repository Pattern

`PostRepository` protocol abstracts API access. `APIPostRepository` wraps `APIService.shared`. All ViewModels depend on the protocol, not the concrete class.

### Image Caching

`CachedAsyncImage` replaces SwiftUI's `AsyncImage`. Backed by `ImageCache` with two layers: NSCache (memory, 100 entry limit) and FileManager disk cache (`Caches/ImageCache/`). Lookup: memory → disk → network.

### ViewState Enum

`PostDetailView` uses an enum (`ViewState.loading | .error(String) | .loaded(Post)`) instead of separate boolean/optional state properties. Switch exhaustively in the view body.

### State Persistence

Both list views save scroll state to UserDefaults (`"infinite-scroll-state"` and `"pagination-state"` keys) so position is restored when navigating back from post detail.

### API JSON Mapping

Models use `CodingKeys` to convert between the API's snake_case (`image_url`, `per_page`, `total_pages`) and Swift's camelCase properties.
