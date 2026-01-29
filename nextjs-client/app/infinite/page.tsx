"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

interface Post {
  id: number;
  title: string;
  image_url: string;
  description: string;
}

interface PostsResponse {
  posts: Post[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

const API_URL = "http://localhost:6969";
const ITEMS_PER_PAGE = 20;
const STORAGE_KEY = "infinite-scroll-state";

interface StoredState {
  posts: Post[];
  page: number;
  total: number;
  hasMore: boolean;
  scrollY: number;
}

export default function InfiniteScrollPage() {
  const router = useRouter();
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [total, setTotal] = useState(0);
  const [initialized, setInitialized] = useState(false);
  const observerTarget = useRef<HTMLDivElement>(null);

  const pageRef = useRef(1);
  const loadingRef = useRef(false);

  // Restore state from sessionStorage on mount
  useEffect(() => {
    const stored = sessionStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const state: StoredState = JSON.parse(stored);
        setPosts(state.posts);
        pageRef.current = state.page;
        setTotal(state.total);
        setHasMore(state.hasMore);
        setInitialized(true);

        // Restore scroll position after posts are rendered
        requestAnimationFrame(() => {
          window.scrollTo(0, state.scrollY);
        });
      } catch {
        setInitialized(true);
      }
    } else {
      setInitialized(true);
    }

    // Clear storage so it doesn't persist across fresh visits
    return () => {
      // Don't clear on unmount - we need it for back navigation
    };
  }, []);

  const saveState = useCallback(() => {
    const state: StoredState = {
      posts,
      page: pageRef.current,
      total,
      hasMore,
      scrollY: window.scrollY,
    };
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [posts, total, hasMore]);

  const handlePostClick = (postId: number) => {
    saveState();
    router.push(`/posts/${postId}`);
  };

  const loadMore = useCallback(async () => {
    if (loadingRef.current || !hasMore) return;

    loadingRef.current = true;
    setLoading(true);

    try {
      const response = await fetch(
        `${API_URL}/posts?page=${pageRef.current}&per_page=${ITEMS_PER_PAGE}`
      );
      const data: PostsResponse = await response.json();

      setPosts((prev) => [...prev, ...data.posts]);
      setTotal(data.total);

      if (pageRef.current >= data.total_pages) {
        setHasMore(false);
      } else {
        pageRef.current += 1;
      }
    } catch (error) {
      console.error("Failed to fetch posts:", error);
    }

    loadingRef.current = false;
    setLoading(false);
  }, [hasMore]);

  useEffect(() => {
    if (!initialized) return;

    // Only set up observer if we don't have restored data or need more
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !loadingRef.current && hasMore) {
          loadMore();
        }
      },
      { threshold: 0.1 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [loadMore, initialized, hasMore]);

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black p-8">
      <div className="max-w-2xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">
            Infinite Scrolling
          </h1>
          <Link
            href="/"
            className="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50"
          >
            Back
          </Link>
        </div>

        <p className="text-zinc-600 dark:text-zinc-400 mb-6">
          Scroll down to load more posts. Loaded: {posts.length} / {total}
        </p>

        <div className="space-y-4">
          {posts.map((post) => (
            <div
              key={post.id}
              onClick={() => handlePostClick(post.id)}
              className="flex flex-col gap-4 p-4 bg-white dark:bg-zinc-900 rounded-lg border border-zinc-200 dark:border-zinc-800 cursor-pointer hover:border-zinc-300 dark:hover:border-zinc-700 transition-colors"
            >
              <img
                src={`${API_URL}${post.image_url}`}
                alt={post.title}
                className="h-64 rounded-lg mb-6 block mx-auto"
              />
              <div>
                <h2 className="font-semibold text-zinc-900 dark:text-zinc-50">
                  {post.title}
                </h2>
                <p className="text-zinc-600 dark:text-zinc-400 text-sm">
                  {post.description}
                </p>
              </div>
            </div>
          ))}
        </div>

        <div ref={observerTarget} className="py-8 text-center">
          {loading && (
            <div className="flex items-center justify-center gap-2 text-zinc-600 dark:text-zinc-400">
              <div className="w-4 h-4 border-2 border-zinc-400 border-t-transparent rounded-full animate-spin" />
              Loading more...
            </div>
          )}
          {!hasMore && posts.length > 0 && (
            <p className="text-zinc-500 dark:text-zinc-500">
              You've reached the end!
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
