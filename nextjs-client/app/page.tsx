import Link from "next/link";

export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 dark:bg-black">
      <main className="flex flex-col items-center gap-8 p-8">
        <h1 className="text-3xl font-bold text-zinc-900 dark:text-zinc-50">
          List Loading Patterns
        </h1>
        <p className="text-zinc-600 dark:text-zinc-400 text-center max-w-md">
          Explore different ways to load and display large lists of data
        </p>
        <div className="flex flex-col sm:flex-row gap-4">
          <Link
            href="/infinite"
            className="flex h-12 items-center justify-center rounded-full bg-zinc-900 px-6 text-white transition-colors hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
          >
            Infinite Scrolling
          </Link>
          <Link
            href="/pagination"
            className="flex h-12 items-center justify-center rounded-full border border-zinc-300 px-6 text-zinc-900 transition-colors hover:bg-zinc-100 dark:border-zinc-700 dark:text-zinc-50 dark:hover:bg-zinc-800"
          >
            Pagination
          </Link>
        </div>
      </main>
    </div>
  );
}
