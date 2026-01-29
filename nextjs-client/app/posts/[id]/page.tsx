"use client";

import { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";

interface Post {
  id: number;
  title: string;
  image_url: string;
  description: string;
}

const API_URL = "http://localhost:6969";

export default function PostDetailPage() {
  const params = useParams();
  const router = useRouter();
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchPost = async () => {
      try {
        const response = await fetch(`${API_URL}/posts/${params.id}`);
        if (!response.ok) {
          throw new Error("Post not found");
        }
        const data = await response.json();
        setPost(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to load post");
      } finally {
        setLoading(false);
      }
    };

    fetchPost();
  }, [params.id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-zinc-50 dark:bg-black p-8 flex items-center justify-center">
        <div className="w-6 h-6 border-2 border-zinc-400 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !post) {
    return (
      <div className="min-h-screen bg-zinc-50 dark:bg-black p-8">
        <div className="max-w-2xl mx-auto text-center">
          <p className="text-red-500 mb-4">{error || "Post not found"}</p>
          <button
            onClick={() => router.back()}
            className="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50"
          >
            Go back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black p-8">
      <div className="max-w-2xl mx-auto">
        <button
          onClick={() => router.back()}
          className="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50 mb-8 flex items-center gap-2"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M19 12H5M12 19l-7-7 7-7" />
          </svg>
          Back
        </button>

        <article className="bg-white dark:bg-zinc-900 rounded-lg border border-zinc-200 dark:border-zinc-800 p-8">
          <img
            src={`${API_URL}${post.image_url}`}
            alt={post.title}
            className="h-64 rounded-lg mb-6 block mx-auto"
          />
          <h1 className="text-3xl font-bold text-zinc-900 dark:text-zinc-50 mb-4">
            {post.title}
          </h1>
          <p className="text-zinc-600 dark:text-zinc-400 text-lg leading-relaxed">
            {post.description}
          </p>
          <div className="mt-8 pt-8 border-t border-zinc-200 dark:border-zinc-800">
            <p className="text-zinc-500 dark:text-zinc-500 text-sm">
              Post ID: {post.id}
            </p>
          </div>
        </article>
      </div>
    </div>
  );
}
