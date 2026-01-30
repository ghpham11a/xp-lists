# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a demo application showcasing list loading patterns (infinite scrolling and pagination). It consists of three parts:
- **NextJS frontend** (`nextjs-client/`) - React 19 with Next.js 16, Tailwind CSS 4
- **iOS client** (`ios-client/ListsDemo/`) - SwiftUI app with identical functionality
- **FastAPI backend** (`server/`) - Python API serving mock post data and static images

## Development Commands

### Frontend (nextjs-client/)
```bash
cd nextjs-client
npm install
npm run dev      # Runs on http://localhost:3000
npm run build    # Production build
npm run lint     # ESLint
```

### Backend (server/)
```bash
cd server/app
# Activate virtualenv first (env/ directory exists)
uvicorn main:app --host 0.0.0.0 --port 6969 --reload
```

### iOS Client (ios-client/ListsDemo/)
Open `ListsDemo.xcodeproj` in Xcode and run on simulator or device. Requires the backend server running.

### Tunneling for mobile testing
```bash
ngrok http --hostname=feedback-test.ngrok.io 6969
```
Update `APIService.swift` baseURL to use the ngrok URL for physical device testing.

## Architecture

### Frontend Structure
- `app/page.tsx` - Home page with links to both list patterns
- `app/infinite/page.tsx` - Infinite scroll implementation using IntersectionObserver
- `app/pagination/page.tsx` - Traditional pagination with page numbers
- `app/posts/[id]/page.tsx` - Individual post detail view

All list pages use sessionStorage to preserve scroll position and page state when navigating to/from post details.

### iOS Client Structure
- `Models/Post.swift` - Post and PostsResponse Codable models
- `Services/APIService.swift` - Singleton API client, baseURL configured here
- `Views/HomeView.swift` - Landing page with NavigationLinks
- `Views/InfiniteScrollView.swift` - LazyVStack with onAppear trigger for loading
- `Views/PaginationView.swift` - Page controls with smart ellipsis logic
- `Views/PostDetailView.swift` - Single post display
- `Views/PostCardView.swift` - Reusable card component with AsyncImage

iOS uses UserDefaults for state persistence (equivalent to sessionStorage).

### Backend Structure
- `server/app/main.py` - FastAPI app with CORS config, mounts `/static` for images
- `server/app/routers/posts.py` - Posts API endpoints, generates 500 mock posts dynamically
- `server/app/models.py` - Pydantic Post model (id, title, image_url, description)
- `server/data/` - Static images (pic_1.png through pic_500.png)

### API Endpoints
- `GET /posts?page=1&per_page=10` - Paginated posts list
- `GET /posts/{id}` - Single post by ID
- `GET /static/pic_{id}.png` - Post images

### Client-Backend Communication
- NextJS uses `API_URL = "http://localhost:6969"` constant
- iOS uses `APIService.shared.baseURL` (defaults to `http://localhost:6969`)
- Images are loaded as `{baseURL}{post.image_url}` (e.g., `http://localhost:6969/static/pic_1.png`)
- CORS configured for localhost:3000 and localhost:5173
- iOS requires `NSAllowsLocalNetworking` in Info.plist for localhost HTTP
