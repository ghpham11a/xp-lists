# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a demo application showcasing list loading patterns (infinite scrolling and pagination). It consists of two parts:
- **NextJS frontend** (`nextjs-client/`) - React 19 with Next.js 16, Tailwind CSS 4
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

## Architecture

### Frontend Structure
- `app/page.tsx` - Home page with links to both list patterns
- `app/infinite/page.tsx` - Infinite scroll implementation using IntersectionObserver
- `app/pagination/page.tsx` - Traditional pagination with page numbers
- `app/posts/[id]/page.tsx` - Individual post detail view

All list pages use sessionStorage to preserve scroll position and page state when navigating to/from post details.

### Backend Structure
- `server/app/main.py` - FastAPI app with CORS config, mounts `/static` for images
- `server/app/routers/posts.py` - Posts API endpoints, generates 500 mock posts dynamically
- `server/app/models.py` - Pydantic Post model (id, title, image_url, description)
- `server/data/` - Static images (pic_1.png through pic_500.png)

### API Endpoints
- `GET /posts?page=1&per_page=10` - Paginated posts list
- `GET /posts/{id}` - Single post by ID
- `GET /static/pic_{id}.png` - Post images

### Frontend-Backend Communication
- Frontend uses `API_URL = "http://localhost:6969"` constant
- Images are loaded as `${API_URL}${post.image_url}` (e.g., `http://localhost:6969/static/pic_1.png`)
- CORS configured for localhost:3000 and localhost:5173
