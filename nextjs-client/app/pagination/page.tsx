"use client";

import { useState, useEffect } from "react";
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
const ITEMS_PER_PAGE = 10;
const STORAGE_KEY = "pagination-state";

export default function PaginationPage() {
  const router = useRouter();
  const [currentPage, setCurrentPage] = useState(1);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(false);
  const [totalPages, setTotalPages] = useState(0);
  const [total, setTotal] = useState(0);
  const [initialized, setInitialized] = useState(false);

  // Restore page from sessionStorage on mount
  useEffect(() => {
    const stored = sessionStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const state = JSON.parse(stored);
        setCurrentPage(state.page);
      } catch {
        // ignore
      }
    }
    setInitialized(true);
  }, []);

  useEffect(() => {
    if (!initialized) return;

    const loadPage = async () => {
      setLoading(true);

      try {
        const response = await fetch(
          `${API_URL}/posts?page=${currentPage}&per_page=${ITEMS_PER_PAGE}`
        );
        const data: PostsResponse = await response.json();

        setPosts(data.posts);
        setTotalPages(data.total_pages);
        setTotal(data.total);
      } catch (error) {
        console.error("Failed to fetch posts:", error);
      }

      setLoading(false);
    };

    loadPage();
  }, [currentPage, initialized]);

  const goToPage = (page: number) => {
    if (page >= 1 && page <= totalPages) {
      setCurrentPage(page);
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  };

  const handlePostClick = (postId: number) => {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ page: currentPage }));
    router.push(`/posts/${postId}`);
  };

  const getPageNumbers = () => {
    const pages: (number | string)[] = [];
    const showEllipsis = totalPages > 7;

    if (!showEllipsis) {
      return Array.from({ length: totalPages }, (_, i) => i + 1);
    }

    pages.push(1);

    if (currentPage > 3) {
      pages.push("...");
    }

    for (
      let i = Math.max(2, currentPage - 1);
      i <= Math.min(totalPages - 1, currentPage + 1);
      i++
    ) {
      pages.push(i);
    }

    if (currentPage < totalPages - 2) {
      pages.push("...");
    }

    pages.push(totalPages);

    return pages;
  };

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black p-8">
      <div className="max-w-2xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">
            Pagination
          </h1>
          <Link
            href="/"
            className="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50"
          >
            Back
          </Link>
        </div>

        <p className="text-zinc-600 dark:text-zinc-400 mb-6">
          Page {currentPage} of {totalPages} ({total} total posts)
        </p>

        <div className="space-y-4 min-h-[500px]">
          {loading ? (
            <div className="flex items-center justify-center py-20">
              <div className="w-6 h-6 border-2 border-zinc-400 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (
            posts.map((post) => (
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
            ))
          )}
        </div>

        {totalPages > 0 && (
          <div className="flex items-center justify-center gap-2 mt-8">
            <button
              onClick={() => goToPage(currentPage - 1)}
              disabled={currentPage === 1}
              className="px-3 py-2 rounded-lg border border-zinc-300 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 disabled:opacity-50 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
            >
              Previous
            </button>

            <div className="flex gap-1">
              {getPageNumbers().map((page, index) =>
                page === "..." ? (
                  <span
                    key={`ellipsis-${index}`}
                    className="px-3 py-2 text-zinc-500"
                  >
                    ...
                  </span>
                ) : (
                  <button
                    key={page}
                    onClick={() => goToPage(page as number)}
                    className={`px-3 py-2 rounded-lg transition-colors ${
                      currentPage === page
                        ? "bg-zinc-900 text-white dark:bg-zinc-50 dark:text-zinc-900"
                        : "border border-zinc-300 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                    }`}
                  >
                    {page}
                  </button>
                )
              )}
            </div>

            <button
              onClick={() => goToPage(currentPage + 1)}
              disabled={currentPage === totalPages}
              className="px-3 py-2 rounded-lg border border-zinc-300 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 disabled:opacity-50 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
            >
              Next
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
