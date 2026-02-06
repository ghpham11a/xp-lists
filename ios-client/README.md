# ListsDemo - iOS Client

SwiftUI app demonstrating infinite scrolling and traditional pagination patterns. Companion to the NextJS frontend in this monorepo.

## Getting Started

1. Start the backend server (see root `CLAUDE.md`)
2. Open `ListsDemo/ListsDemo.xcodeproj` in Xcode 26.1.1+
3. Update `APIService.swift` `baseURL`:
   - Simulator: `http://localhost:6969`
   - Physical device: run ngrok (`ngrok http --hostname=feedback-test.ngrok.io 6969`) and use the ngrok URL
4. Build and run (iOS 26.1+ deployment target)

No external dependencies besides **Swinject 2.10.0** (managed via Swift Package Manager).

## Architecture

```
ListsDemo/
├── App/                              # Entry point + DI setup
│   ├── ListsDemoApp.swift            # @main
│   ├── ContentView.swift             # NavigationStack root
│   └── DIContainer.swift             # Swinject container
├── Data/
│   ├── Models/Post.swift             # Codable models
│   ├── Networking/
│   │   ├── APIService.swift          # HTTP client (baseURL configured here)
│   │   └── ImageCache.swift          # Memory + disk image cache
│   └── Repositories/
│       └── PostRepository.swift      # Protocol + API implementation
├── Features/                         # One directory per screen
│   ├── Home/
│   ├── InfiniteScroll/               # View + ViewModel
│   ├── Pagination/                   # View + ViewModel
│   └── PostDetail/                   # View + ViewModel (uses ViewState enum)
└── Shared/Views/
    ├── PostCardView.swift            # Reusable card component
    └── CachedAsyncImage.swift        # Cached image view
```

Each feature follows the **View + ViewModel** pattern. Views are pure UI — all state and logic live in `@Observable` ViewModel classes defined in `*+ViewModel.swift` extension files.

## Dependency Injection

Dependencies are managed via **Swinject**. All registrations live in `App/DIContainer.swift`:

```swift
container.register(PostRepository.self) { _ in APIPostRepository() }
container.register(ImageCache.self) { _ in ImageCache() }.inObjectScope(.container)
```

ViewModels resolve dependencies in their `init()`:

```swift
let repository: PostRepository

init() {
    repository = DIContainer.shared.resolve(PostRepository.self)
}
```

To swap an implementation (e.g. for testing), change the registration in `DIContainer` — no other code needs to change.

**Object scopes:**
- `PostRepository` — transient (new instance per resolution)
- `ImageCache` — `.container` scope (single shared instance)

## Image Caching

`CachedAsyncImage` is a drop-in replacement for SwiftUI's `AsyncImage` with two-layer caching:

1. **Memory** — `NSCache` (auto-evicted under memory pressure, up to 100 entries)
2. **Disk** — files in `Caches/ImageCache/` (persists across app launches, purgeable by the OS)

Lookup order: memory -> disk -> network. Results are stored back into both layers.

Usage:
```swift
CachedAsyncImage(url: imageURL, height: 200, cornerRadius: 8)
```

This replaces `AsyncImage` in both `PostCardView` (200pt) and `PostDetailView` (300pt), preventing re-downloads when scrolling through the feed.

## State Persistence

Both list views save their scroll position to `UserDefaults` so navigating to a post detail and back restores the previous state:

- **Infinite scroll** — saves loaded post IDs, current page, and total count (`"infinite-scroll-state"` key)
- **Pagination** — saves current page number (`"pagination-state"` key)
