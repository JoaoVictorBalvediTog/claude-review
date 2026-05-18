# Review Input

This file is exactly the context passed to Claude through stdin.

Repository: JoaoVictorBalvediTog/Reviewer_test
PR number: 1
Run mode: comment_review
Output directory: outputs/JoaoVictorBalvediTog_Reviewer_test

Generated at: 2026-05-18T13:34:30Z

---
# Pull Request Context

- PR title: feat: creating shop page
- PR URL: https://github.com/JoaoVictorBalvediTog/Reviewer_test/pull/1
- Head branch: staging
- Base branch: main
- Author: JoaoVictorBalvediTog
- Changed files: 1
- Additions: 159
- Deletions: 58

## PR Body

No PR body provided.

---
# Jira Context

- Status: NOT_FOUND

No Jira key was found in PR title, branch name, or PR body.

You can force one with:

```bash
JIRA_KEY=RER-123 ./review-pr.sh git@github.com:JoaoVictorBalvediTog/Reviewer_test.git 1
```

---
# Application Context

- Status: CONFIGURED
- Base ref used: main
- Files requested: README.md

## README.md

\```text
This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
\```


---
# Changed Files Full Content

- Repository: JoaoVictorBalvediTog/Reviewer_test
- PR number: 1
- Status: FETCHED_FROM_PR_HEAD
- Ref used: 4cb3c52121c305f177caccefa9965c201ce6b4dc
- Max chars per file: 20000
- Max total chars: 120000

## app/page.tsx

- Change type: MODIFIED
- Additions: 159
- Deletions: 58

```text
"use client";

import { useState } from "react";

const DISCOUNT_PERCENT = 10;

const products = [
  { id: 1, name: "Mechanical Keyboard", price: 149.99, category: "Electronics" },
  { id: 2, name: "Wireless Mouse", price: 79.99, category: "Electronics" },
  { id: 3, name: "4K Monitor", price: 499.99, category: "Electronics" },
  { id: 4, name: "Standing Desk", price: 599.99, category: "Furniture" },
  { id: 5, name: "Ergonomic Chair", price: 349.99, category: "Furniture" },
  { id: 6, name: "Monitor Stand", price: 49.99, category: "Furniture" },
  { id: 7, name: "Notebook Pack", price: 12.99, category: "Stationery" },
  { id: 8, name: "Pen Set", price: 8.99, category: "Stationery" },
];

type Product = (typeof products)[0];

export default function Home() {
  const [cart, setCart] = useState<Product[]>([]);
  const [filter, setFilter] = useState("All");

  const categories = ["All", ...Array.from(new Set(products.map((p) => p.category)))];

  const filtered =
    filter === "All" ? products : products.filter((p) => p.category === filter);

  const addToCart = (product: Product) => {
    if (!cart.find((item) => item.id === product.id)) {
      setCart([...cart, product]);
    }
  };

  const removeFromCart = (id: number) => {
    setCart(cart.filter((item) => item.id !== id));
  };

  const subtotal = cart.reduce((acc, item) => acc + item.price, 0);

  // BUG: calculates the discount amount instead of the discounted total
  // Should be: subtotal * (1 - DISCOUNT_PERCENT / 100)
  const total = subtotal * (DISCOUNT_PERCENT / 100);

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 font-sans">
      <header className="bg-white dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 px-8 py-4 flex items-center justify-between">
        <h1 className="text-xl font-bold text-zinc-900 dark:text-zinc-50">Dev Shop</h1>
        <span className="text-sm text-zinc-500 dark:text-zinc-400">
          {cart.length} item{cart.length !== 1 ? "s" : ""} in cart
        </span>
      </header>

      <main className="max-w-6xl mx-auto px-8 py-10 grid grid-cols-1 lg:grid-cols-3 gap-10">
        <section className="lg:col-span-2">
          <div className="flex gap-2 mb-6 flex-wrap">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setFilter(cat)}
                className={`px-4 py-1.5 rounded-full text-sm font-medium border transition-colors ${
                  filter === cat
                    ? "bg-zinc-900 text-white border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50"
                    : "bg-white text-zinc-600 border-zinc-200 hover:border-zinc-400 dark:bg-zinc-900 dark:text-zinc-400 dark:border-zinc-700"
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {filtered.map((product) => {
              const inCart = cart.some((item) => item.id === product.id);
              return (
                <div
                  key={product.id}
                  className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5 flex flex-col gap-3"
                >
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-xs font-medium text-zinc-400 uppercase tracking-wide">
                        {product.category}
                      </p>
                      <h2 className="text-base font-semibold text-zinc-900 dark:text-zinc-50 mt-0.5">
                        {product.name}
                      </h2>
                    </div>
                    <span className="text-lg font-bold text-zinc-900 dark:text-zinc-50">
                      ${product.price.toFixed(2)}
                    </span>
                  </div>
                  <button
                    onClick={() => addToCart(product)}
                    disabled={inCart}
                    className={`mt-auto w-full py-2 rounded-lg text-sm font-medium transition-colors ${
                      inCart
                        ? "bg-zinc-100 text-zinc-400 cursor-not-allowed dark:bg-zinc-800 dark:text-zinc-600"
                        : "bg-zinc-900 text-white hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
                    }`}
                  >
                    {inCart ? "Added" : "Add to Cart"}
                  </button>
                </div>
              );
            })}
          </div>
        </section>

        <aside className="lg:col-span-1">
          <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-6 sticky top-8">
            <h2 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">
              Your Cart
            </h2>

            {cart.length === 0 ? (
              <p className="text-sm text-zinc-400">No items yet. Add something!</p>
            ) : (
              <ul className="flex flex-col gap-3 mb-6">
                {cart.map((item) => (
                  <li
                    key={item.id}
                    className="flex items-center justify-between text-sm"
                  >
                    <span className="text-zinc-700 dark:text-zinc-300">{item.name}</span>
                    <div className="flex items-center gap-3">
                      <span className="font-medium text-zinc-900 dark:text-zinc-50">
                        ${item.price.toFixed(2)}
                      </span>
                      <button
                        onClick={() => removeFromCart(item.id)}
                        className="text-zinc-400 hover:text-red-500 transition-colors text-xs"
                      >
                        Remove
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            )}

            {cart.length > 0 && (
              <div className="border-t border-zinc-100 dark:border-zinc-800 pt-4 flex flex-col gap-2">
                <div className="flex justify-between text-sm text-zinc-500">
                  <span>Subtotal</span>
                  <span>${subtotal.toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-sm text-green-600">
                  <span>Discount ({DISCOUNT_PERCENT}%)</span>
                  <span>-${(subtotal * DISCOUNT_PERCENT / 100).toFixed(2)}</span>
                </div>
                <div className="flex justify-between font-bold text-zinc-900 dark:text-zinc-50 text-base mt-1">
                  <span>Total</span>
                  <span>${total.toFixed(2)}</span>
                </div>
                <button className="mt-4 w-full py-2.5 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 transition-colors">
                  Checkout
                </button>
              </div>
            )}
          </div>
        </aside>
      </main>
    </div>
  );
}

```

---
# Allowed Inline Review Targets

Claude may only create inline comments using path, line, and side values present in this JSON list.

```json
[
  {
    "path": "app/page.tsx",
    "line": 1,
    "side": "LEFT",
    "kind": "deletion",
    "text": "import Image from \"next/image\";"
  },
  {
    "path": "app/page.tsx",
    "line": 1,
    "side": "RIGHT",
    "kind": "addition",
    "text": "\"use client\";"
  },
  {
    "path": "app/page.tsx",
    "line": 2,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 3,
    "side": "RIGHT",
    "kind": "addition",
    "text": "import { useState } from \"react\";"
  },
  {
    "path": "app/page.tsx",
    "line": 4,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 5,
    "side": "RIGHT",
    "kind": "addition",
    "text": "const DISCOUNT_PERCENT = 10;"
  },
  {
    "path": "app/page.tsx",
    "line": 6,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 7,
    "side": "RIGHT",
    "kind": "addition",
    "text": "const products = ["
  },
  {
    "path": "app/page.tsx",
    "line": 8,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 1, name: \"Mechanical Keyboard\", price: 149.99, category: \"Electronics\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 9,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 2, name: \"Wireless Mouse\", price: 79.99, category: \"Electronics\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 10,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 3, name: \"4K Monitor\", price: 499.99, category: \"Electronics\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 11,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 4, name: \"Standing Desk\", price: 599.99, category: \"Furniture\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 12,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 5, name: \"Ergonomic Chair\", price: 349.99, category: \"Furniture\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 13,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 6, name: \"Monitor Stand\", price: 49.99, category: \"Furniture\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 14,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 7, name: \"Notebook Pack\", price: 12.99, category: \"Stationery\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 15,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  { id: 8, name: \"Pen Set\", price: 8.99, category: \"Stationery\" },"
  },
  {
    "path": "app/page.tsx",
    "line": 16,
    "side": "RIGHT",
    "kind": "addition",
    "text": "];"
  },
  {
    "path": "app/page.tsx",
    "line": 17,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 18,
    "side": "RIGHT",
    "kind": "addition",
    "text": "type Product = (typeof products)[0];"
  },
  {
    "path": "app/page.tsx",
    "line": 19,
    "side": "RIGHT",
    "kind": "context",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 20,
    "side": "RIGHT",
    "kind": "context",
    "text": "export default function Home() {"
  },
  {
    "path": "app/page.tsx",
    "line": 21,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const [cart, setCart] = useState<Product[]>([]);"
  },
  {
    "path": "app/page.tsx",
    "line": 22,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const [filter, setFilter] = useState(\"All\");"
  },
  {
    "path": "app/page.tsx",
    "line": 23,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 24,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const categories = [\"All\", ...Array.from(new Set(products.map((p) => p.category)))];"
  },
  {
    "path": "app/page.tsx",
    "line": 25,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 26,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const filtered ="
  },
  {
    "path": "app/page.tsx",
    "line": 27,
    "side": "RIGHT",
    "kind": "addition",
    "text": "    filter === \"All\" ? products : products.filter((p) => p.category === filter);"
  },
  {
    "path": "app/page.tsx",
    "line": 28,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 29,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const addToCart = (product: Product) => {"
  },
  {
    "path": "app/page.tsx",
    "line": 30,
    "side": "RIGHT",
    "kind": "addition",
    "text": "    if (!cart.find((item) => item.id === product.id)) {"
  },
  {
    "path": "app/page.tsx",
    "line": 31,
    "side": "RIGHT",
    "kind": "addition",
    "text": "      setCart([...cart, product]);"
  },
  {
    "path": "app/page.tsx",
    "line": 32,
    "side": "RIGHT",
    "kind": "addition",
    "text": "    }"
  },
  {
    "path": "app/page.tsx",
    "line": 33,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  };"
  },
  {
    "path": "app/page.tsx",
    "line": 34,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 35,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const removeFromCart = (id: number) => {"
  },
  {
    "path": "app/page.tsx",
    "line": 36,
    "side": "RIGHT",
    "kind": "addition",
    "text": "    setCart(cart.filter((item) => item.id !== id));"
  },
  {
    "path": "app/page.tsx",
    "line": 37,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  };"
  },
  {
    "path": "app/page.tsx",
    "line": 38,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 39,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const subtotal = cart.reduce((acc, item) => acc + item.price, 0);"
  },
  {
    "path": "app/page.tsx",
    "line": 40,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 41,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  // BUG: calculates the discount amount instead of the discounted total"
  },
  {
    "path": "app/page.tsx",
    "line": 42,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  // Should be: subtotal * (1 - DISCOUNT_PERCENT / 100)"
  },
  {
    "path": "app/page.tsx",
    "line": 43,
    "side": "RIGHT",
    "kind": "addition",
    "text": "  const total = subtotal * (DISCOUNT_PERCENT / 100);"
  },
  {
    "path": "app/page.tsx",
    "line": 44,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 45,
    "side": "RIGHT",
    "kind": "context",
    "text": "  return ("
  },
  {
    "path": "app/page.tsx",
    "line": 5,
    "side": "LEFT",
    "kind": "deletion",
    "text": "    <div className=\"flex flex-col flex-1 items-center justify-center bg-zinc-50 font-sans dark:bg-black\">"
  },
  {
    "path": "app/page.tsx",
    "line": 6,
    "side": "LEFT",
    "kind": "deletion",
    "text": "      <main className=\"flex flex-1 w-full max-w-3xl flex-col items-center justify-between py-32 px-16 bg-white dark:bg-black sm:items-start\">"
  },
  {
    "path": "app/page.tsx",
    "line": 7,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        <Image"
  },
  {
    "path": "app/page.tsx",
    "line": 8,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          className=\"dark:invert\""
  },
  {
    "path": "app/page.tsx",
    "line": 9,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          src=\"/next.svg\""
  },
  {
    "path": "app/page.tsx",
    "line": 10,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          alt=\"Next.js logo\""
  },
  {
    "path": "app/page.tsx",
    "line": 11,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          width={100}"
  },
  {
    "path": "app/page.tsx",
    "line": 12,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          height={20}"
  },
  {
    "path": "app/page.tsx",
    "line": 13,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          priority"
  },
  {
    "path": "app/page.tsx",
    "line": 14,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        />"
  },
  {
    "path": "app/page.tsx",
    "line": 15,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        <div className=\"flex flex-col items-center gap-6 text-center sm:items-start sm:text-left\">"
  },
  {
    "path": "app/page.tsx",
    "line": 16,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          <h1 className=\"max-w-xs text-3xl font-semibold leading-10 tracking-tight text-black dark:text-zinc-50\">"
  },
  {
    "path": "app/page.tsx",
    "line": 17,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            To get started, edit the page.tsx file."
  },
  {
    "path": "app/page.tsx",
    "line": 18,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          </h1>"
  },
  {
    "path": "app/page.tsx",
    "line": 19,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          <p className=\"max-w-md text-lg leading-8 text-zinc-600 dark:text-zinc-400\">"
  },
  {
    "path": "app/page.tsx",
    "line": 20,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            Looking for a starting point or more instructions? Head over to{\" \"}"
  },
  {
    "path": "app/page.tsx",
    "line": 21,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            <a"
  },
  {
    "path": "app/page.tsx",
    "line": 22,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              href=\"https://vercel.com/templates?framework=next.js&utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app\""
  },
  {
    "path": "app/page.tsx",
    "line": 23,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              className=\"font-medium text-zinc-950 dark:text-zinc-50\""
  },
  {
    "path": "app/page.tsx",
    "line": 24,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            >"
  },
  {
    "path": "app/page.tsx",
    "line": 25,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              Templates"
  },
  {
    "path": "app/page.tsx",
    "line": 26,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            </a>{\" \"}"
  },
  {
    "path": "app/page.tsx",
    "line": 27,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            or the{\" \"}"
  },
  {
    "path": "app/page.tsx",
    "line": 28,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            <a"
  },
  {
    "path": "app/page.tsx",
    "line": 29,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              href=\"https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app\""
  },
  {
    "path": "app/page.tsx",
    "line": 30,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              className=\"font-medium text-zinc-950 dark:text-zinc-50\""
  },
  {
    "path": "app/page.tsx",
    "line": 31,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            >"
  },
  {
    "path": "app/page.tsx",
    "line": 32,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              Learning"
  },
  {
    "path": "app/page.tsx",
    "line": 33,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            </a>{\" \"}"
  },
  {
    "path": "app/page.tsx",
    "line": 34,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            center."
  },
  {
    "path": "app/page.tsx",
    "line": 35,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          </p>"
  },
  {
    "path": "app/page.tsx",
    "line": 36,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 37,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        <div className=\"flex flex-col gap-4 text-base font-medium sm:flex-row\">"
  },
  {
    "path": "app/page.tsx",
    "line": 38,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          <a"
  },
  {
    "path": "app/page.tsx",
    "line": 39,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            className=\"flex h-12 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] "
  },
  {
    "path": "app/page.tsx",
    "line": 40,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            href=\"https://vercel.com/new?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app\""
  },
  {
    "path": "app/page.tsx",
    "line": 41,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            target=\"_blank\""
  },
  {
    "path": "app/page.tsx",
    "line": 42,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            rel=\"noopener noreferrer\""
  },
  {
    "path": "app/page.tsx",
    "line": 43,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          >"
  },
  {
    "path": "app/page.tsx",
    "line": 44,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            <Image"
  },
  {
    "path": "app/page.tsx",
    "line": 45,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              className=\"dark:invert\""
  },
  {
    "path": "app/page.tsx",
    "line": 46,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              src=\"/vercel.svg\""
  },
  {
    "path": "app/page.tsx",
    "line": 47,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              alt=\"Vercel logomark\""
  },
  {
    "path": "app/page.tsx",
    "line": 48,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              width={16}"
  },
  {
    "path": "app/page.tsx",
    "line": 49,
    "side": "LEFT",
    "kind": "deletion",
    "text": "              height={16}"
  },
  {
    "path": "app/page.tsx",
    "line": 50,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            />"
  },
  {
    "path": "app/page.tsx",
    "line": 51,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            Deploy Now"
  },
  {
    "path": "app/page.tsx",
    "line": 52,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          </a>"
  },
  {
    "path": "app/page.tsx",
    "line": 53,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          <a"
  },
  {
    "path": "app/page.tsx",
    "line": 54,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            className=\"flex h-12 w-full items-center justify-center rounded-full border border-solid border-black/[.08] px-5 transition-colors hover:border-transparent hover:bg-bla"
  },
  {
    "path": "app/page.tsx",
    "line": 55,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            href=\"https://nextjs.org/docs?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app\""
  },
  {
    "path": "app/page.tsx",
    "line": 56,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            target=\"_blank\""
  },
  {
    "path": "app/page.tsx",
    "line": 57,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            rel=\"noopener noreferrer\""
  },
  {
    "path": "app/page.tsx",
    "line": 58,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          >"
  },
  {
    "path": "app/page.tsx",
    "line": 59,
    "side": "LEFT",
    "kind": "deletion",
    "text": "            Documentation"
  },
  {
    "path": "app/page.tsx",
    "line": 60,
    "side": "LEFT",
    "kind": "deletion",
    "text": "          </a>"
  },
  {
    "path": "app/page.tsx",
    "line": 61,
    "side": "LEFT",
    "kind": "deletion",
    "text": "        </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 46,
    "side": "RIGHT",
    "kind": "addition",
    "text": "    <div className=\"min-h-screen bg-zinc-50 dark:bg-zinc-950 font-sans\">"
  },
  {
    "path": "app/page.tsx",
    "line": 47,
    "side": "RIGHT",
    "kind": "addition",
    "text": "      <header className=\"bg-white dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 px-8 py-4 flex items-center justify-between\">"
  },
  {
    "path": "app/page.tsx",
    "line": 48,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        <h1 className=\"text-xl font-bold text-zinc-900 dark:text-zinc-50\">Dev Shop</h1>"
  },
  {
    "path": "app/page.tsx",
    "line": 49,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        <span className=\"text-sm text-zinc-500 dark:text-zinc-400\">"
  },
  {
    "path": "app/page.tsx",
    "line": 50,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          {cart.length} item{cart.length !== 1 ? \"s\" : \"\"} in cart"
  },
  {
    "path": "app/page.tsx",
    "line": 51,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        </span>"
  },
  {
    "path": "app/page.tsx",
    "line": 52,
    "side": "RIGHT",
    "kind": "addition",
    "text": "      </header>"
  },
  {
    "path": "app/page.tsx",
    "line": 53,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 54,
    "side": "RIGHT",
    "kind": "addition",
    "text": "      <main className=\"max-w-6xl mx-auto px-8 py-10 grid grid-cols-1 lg:grid-cols-3 gap-10\">"
  },
  {
    "path": "app/page.tsx",
    "line": 55,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        <section className=\"lg:col-span-2\">"
  },
  {
    "path": "app/page.tsx",
    "line": 56,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          <div className=\"flex gap-2 mb-6 flex-wrap\">"
  },
  {
    "path": "app/page.tsx",
    "line": 57,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            {categories.map((cat) => ("
  },
  {
    "path": "app/page.tsx",
    "line": 58,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              <button"
  },
  {
    "path": "app/page.tsx",
    "line": 59,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                key={cat}"
  },
  {
    "path": "app/page.tsx",
    "line": 60,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                onClick={() => setFilter(cat)}"
  },
  {
    "path": "app/page.tsx",
    "line": 61,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                className={`px-4 py-1.5 rounded-full text-sm font-medium border transition-colors ${"
  },
  {
    "path": "app/page.tsx",
    "line": 62,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  filter === cat"
  },
  {
    "path": "app/page.tsx",
    "line": 63,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    ? \"bg-zinc-900 text-white border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50\""
  },
  {
    "path": "app/page.tsx",
    "line": 64,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    : \"bg-white text-zinc-600 border-zinc-200 hover:border-zinc-400 dark:bg-zinc-900 dark:text-zinc-400 dark:border-zinc-700\""
  },
  {
    "path": "app/page.tsx",
    "line": 65,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                }`}"
  },
  {
    "path": "app/page.tsx",
    "line": 66,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              >"
  },
  {
    "path": "app/page.tsx",
    "line": 67,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                {cat}"
  },
  {
    "path": "app/page.tsx",
    "line": 68,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              </button>"
  },
  {
    "path": "app/page.tsx",
    "line": 69,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            ))}"
  },
  {
    "path": "app/page.tsx",
    "line": 70,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 71,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 72,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          <div className=\"grid grid-cols-1 sm:grid-cols-2 gap-4\">"
  },
  {
    "path": "app/page.tsx",
    "line": 73,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            {filtered.map((product) => {"
  },
  {
    "path": "app/page.tsx",
    "line": 74,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              const inCart = cart.some((item) => item.id === product.id);"
  },
  {
    "path": "app/page.tsx",
    "line": 75,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              return ("
  },
  {
    "path": "app/page.tsx",
    "line": 76,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                <div"
  },
  {
    "path": "app/page.tsx",
    "line": 77,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  key={product.id}"
  },
  {
    "path": "app/page.tsx",
    "line": 78,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  className=\"bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5 flex flex-col gap-3\""
  },
  {
    "path": "app/page.tsx",
    "line": 79,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                >"
  },
  {
    "path": "app/page.tsx",
    "line": 80,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <div className=\"flex items-start justify-between\">"
  },
  {
    "path": "app/page.tsx",
    "line": 81,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    <div>"
  },
  {
    "path": "app/page.tsx",
    "line": 82,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      <p className=\"text-xs font-medium text-zinc-400 uppercase tracking-wide\">"
  },
  {
    "path": "app/page.tsx",
    "line": 83,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        {product.category}"
  },
  {
    "path": "app/page.tsx",
    "line": 84,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      </p>"
  },
  {
    "path": "app/page.tsx",
    "line": 85,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      <h2 className=\"text-base font-semibold text-zinc-900 dark:text-zinc-50 mt-0.5\">"
  },
  {
    "path": "app/page.tsx",
    "line": 86,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        {product.name}"
  },
  {
    "path": "app/page.tsx",
    "line": 87,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      </h2>"
  },
  {
    "path": "app/page.tsx",
    "line": 88,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 89,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    <span className=\"text-lg font-bold text-zinc-900 dark:text-zinc-50\">"
  },
  {
    "path": "app/page.tsx",
    "line": 90,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      ${product.price.toFixed(2)}"
  },
  {
    "path": "app/page.tsx",
    "line": 91,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    </span>"
  },
  {
    "path": "app/page.tsx",
    "line": 92,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 93,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <button"
  },
  {
    "path": "app/page.tsx",
    "line": 94,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    onClick={() => addToCart(product)}"
  },
  {
    "path": "app/page.tsx",
    "line": 95,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    disabled={inCart}"
  },
  {
    "path": "app/page.tsx",
    "line": 96,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    className={`mt-auto w-full py-2 rounded-lg text-sm font-medium transition-colors ${"
  },
  {
    "path": "app/page.tsx",
    "line": 97,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      inCart"
  },
  {
    "path": "app/page.tsx",
    "line": 98,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        ? \"bg-zinc-100 text-zinc-400 cursor-not-allowed dark:bg-zinc-800 dark:text-zinc-600\""
  },
  {
    "path": "app/page.tsx",
    "line": 99,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        : \"bg-zinc-900 text-white hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200\""
  },
  {
    "path": "app/page.tsx",
    "line": 100,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    }`}"
  },
  {
    "path": "app/page.tsx",
    "line": 101,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  >"
  },
  {
    "path": "app/page.tsx",
    "line": 102,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    {inCart ? \"Added\" : \"Add to Cart\"}"
  },
  {
    "path": "app/page.tsx",
    "line": 103,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  </button>"
  },
  {
    "path": "app/page.tsx",
    "line": 104,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 105,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              );"
  },
  {
    "path": "app/page.tsx",
    "line": 106,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            })}"
  },
  {
    "path": "app/page.tsx",
    "line": 107,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 108,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        </section>"
  },
  {
    "path": "app/page.tsx",
    "line": 109,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 110,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        <aside className=\"lg:col-span-1\">"
  },
  {
    "path": "app/page.tsx",
    "line": 111,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          <div className=\"bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-6 sticky top-8\">"
  },
  {
    "path": "app/page.tsx",
    "line": 112,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            <h2 className=\"text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4\">"
  },
  {
    "path": "app/page.tsx",
    "line": 113,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              Your Cart"
  },
  {
    "path": "app/page.tsx",
    "line": 114,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            </h2>"
  },
  {
    "path": "app/page.tsx",
    "line": 115,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 116,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            {cart.length === 0 ? ("
  },
  {
    "path": "app/page.tsx",
    "line": 117,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              <p className=\"text-sm text-zinc-400\">No items yet. Add something!</p>"
  },
  {
    "path": "app/page.tsx",
    "line": 118,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            ) : ("
  },
  {
    "path": "app/page.tsx",
    "line": 119,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              <ul className=\"flex flex-col gap-3 mb-6\">"
  },
  {
    "path": "app/page.tsx",
    "line": 120,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                {cart.map((item) => ("
  },
  {
    "path": "app/page.tsx",
    "line": 121,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <li"
  },
  {
    "path": "app/page.tsx",
    "line": 122,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    key={item.id}"
  },
  {
    "path": "app/page.tsx",
    "line": 123,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    className=\"flex items-center justify-between text-sm\""
  },
  {
    "path": "app/page.tsx",
    "line": 124,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  >"
  },
  {
    "path": "app/page.tsx",
    "line": 125,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    <span className=\"text-zinc-700 dark:text-zinc-300\">{item.name}</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 126,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    <div className=\"flex items-center gap-3\">"
  },
  {
    "path": "app/page.tsx",
    "line": 127,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      <span className=\"font-medium text-zinc-900 dark:text-zinc-50\">"
  },
  {
    "path": "app/page.tsx",
    "line": 128,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        ${item.price.toFixed(2)}"
  },
  {
    "path": "app/page.tsx",
    "line": 129,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      </span>"
  },
  {
    "path": "app/page.tsx",
    "line": 130,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      <button"
  },
  {
    "path": "app/page.tsx",
    "line": 131,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        onClick={() => removeFromCart(item.id)}"
  },
  {
    "path": "app/page.tsx",
    "line": 132,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        className=\"text-zinc-400 hover:text-red-500 transition-colors text-xs\""
  },
  {
    "path": "app/page.tsx",
    "line": 133,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      >"
  },
  {
    "path": "app/page.tsx",
    "line": 134,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                        Remove"
  },
  {
    "path": "app/page.tsx",
    "line": 135,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                      </button>"
  },
  {
    "path": "app/page.tsx",
    "line": 136,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                    </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 137,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  </li>"
  },
  {
    "path": "app/page.tsx",
    "line": 138,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                ))}"
  },
  {
    "path": "app/page.tsx",
    "line": 139,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              </ul>"
  },
  {
    "path": "app/page.tsx",
    "line": 140,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            )}"
  },
  {
    "path": "app/page.tsx",
    "line": 141,
    "side": "RIGHT",
    "kind": "addition",
    "text": ""
  },
  {
    "path": "app/page.tsx",
    "line": 142,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            {cart.length > 0 && ("
  },
  {
    "path": "app/page.tsx",
    "line": 143,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              <div className=\"border-t border-zinc-100 dark:border-zinc-800 pt-4 flex flex-col gap-2\">"
  },
  {
    "path": "app/page.tsx",
    "line": 144,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                <div className=\"flex justify-between text-sm text-zinc-500\">"
  },
  {
    "path": "app/page.tsx",
    "line": 145,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>Subtotal</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 146,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>${subtotal.toFixed(2)}</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 147,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 148,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                <div className=\"flex justify-between text-sm text-green-600\">"
  },
  {
    "path": "app/page.tsx",
    "line": 149,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>Discount ({DISCOUNT_PERCENT}%)</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 150,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>-${(subtotal * DISCOUNT_PERCENT / 100).toFixed(2)}</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 151,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 152,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                <div className=\"flex justify-between font-bold text-zinc-900 dark:text-zinc-50 text-base mt-1\">"
  },
  {
    "path": "app/page.tsx",
    "line": 153,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>Total</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 154,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  <span>${total.toFixed(2)}</span>"
  },
  {
    "path": "app/page.tsx",
    "line": 155,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 156,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                <button className=\"mt-4 w-full py-2.5 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-"
  },
  {
    "path": "app/page.tsx",
    "line": 157,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                  Checkout"
  },
  {
    "path": "app/page.tsx",
    "line": 158,
    "side": "RIGHT",
    "kind": "addition",
    "text": "                </button>"
  },
  {
    "path": "app/page.tsx",
    "line": 159,
    "side": "RIGHT",
    "kind": "addition",
    "text": "              </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 160,
    "side": "RIGHT",
    "kind": "addition",
    "text": "            )}"
  },
  {
    "path": "app/page.tsx",
    "line": 161,
    "side": "RIGHT",
    "kind": "addition",
    "text": "          </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 162,
    "side": "RIGHT",
    "kind": "addition",
    "text": "        </aside>"
  },
  {
    "path": "app/page.tsx",
    "line": 163,
    "side": "RIGHT",
    "kind": "context",
    "text": "      </main>"
  },
  {
    "path": "app/page.tsx",
    "line": 164,
    "side": "RIGHT",
    "kind": "context",
    "text": "    </div>"
  },
  {
    "path": "app/page.tsx",
    "line": 165,
    "side": "RIGHT",
    "kind": "context",
    "text": "  );"
  }
]
```

---
# Sanitized Pull Request Diff

```diff
From 4cb3c52121c305f177caccefa9965c201ce6b4dc Mon Sep 17 00:00:00 2001
From: JoaoVictorBalvedi <joaovictorbalvedi@gmail.com>
Date: Thu, 14 May 2026 08:37:13 -0300
Subject: [PATCH] feat: creating shop page

---
 app/page.tsx | 217 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 159 insertions(+), 58 deletions(-)

diff --git a/app/page.tsx b/app/page.tsx
index 3f36f7c..5010eef 100644
--- a/app/page.tsx
+++ b/app/page.tsx
@@ -1,64 +1,165 @@
-import Image from "next/image";
+"use client";
+
+import { useState } from "react";
+
+const DISCOUNT_PERCENT = 10;
+
+const products = [
+  { id: 1, name: "Mechanical Keyboard", price: 149.99, category: "Electronics" },
+  { id: 2, name: "Wireless Mouse", price: 79.99, category: "Electronics" },
+  { id: 3, name: "4K Monitor", price: 499.99, category: "Electronics" },
+  { id: 4, name: "Standing Desk", price: 599.99, category: "Furniture" },
+  { id: 5, name: "Ergonomic Chair", price: 349.99, category: "Furniture" },
+  { id: 6, name: "Monitor Stand", price: 49.99, category: "Furniture" },
+  { id: 7, name: "Notebook Pack", price: 12.99, category: "Stationery" },
+  { id: 8, name: "Pen Set", price: 8.99, category: "Stationery" },
+];
+
+type Product = (typeof products)[0];
 
 export default function Home() {
+  const [cart, setCart] = useState<Product[]>([]);
+  const [filter, setFilter] = useState("All");
+
+  const categories = ["All", ...Array.from(new Set(products.map((p) => p.category)))];
+
+  const filtered =
+    filter === "All" ? products : products.filter((p) => p.category === filter);
+
+  const addToCart = (product: Product) => {
+    if (!cart.find((item) => item.id === product.id)) {
+      setCart([...cart, product]);
+    }
+  };
+
+  const removeFromCart = (id: number) => {
+    setCart(cart.filter((item) => item.id !== id));
+  };
+
+  const subtotal = cart.reduce((acc, item) => acc + item.price, 0);
+
+  // BUG: calculates the discount amount instead of the discounted total
+  // Should be: subtotal * (1 - DISCOUNT_PERCENT / 100)
+  const total = subtotal * (DISCOUNT_PERCENT / 100);
+
   return (
-    <div className="flex flex-col flex-1 items-center justify-center bg-zinc-50 font-sans dark:bg-black">
-      <main className="flex flex-1 w-full max-w-3xl flex-col items-center justify-between py-32 px-16 bg-white dark:bg-black sm:items-start">
-        <Image
-          className="dark:invert"
-          src="/next.svg"
-          alt="Next.js logo"
-          width={100}
-          height={20}
-          priority
-        />
-        <div className="flex flex-col items-center gap-6 text-center sm:items-start sm:text-left">
-          <h1 className="max-w-xs text-3xl font-semibold leading-10 tracking-tight text-black dark:text-zinc-50">
-            To get started, edit the page.tsx file.
-          </h1>
-          <p className="max-w-md text-lg leading-8 text-zinc-600 dark:text-zinc-400">
-            Looking for a starting point or more instructions? Head over to{" "}
-            <a
-              href="https://vercel.com/templates?framework=next.js&utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
-              className="font-medium text-zinc-950 dark:text-zinc-50"
-            >
-              Templates
-            </a>{" "}
-            or the{" "}
-            <a
-              href="https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
-              className="font-medium text-zinc-950 dark:text-zinc-50"
-            >
-              Learning
-            </a>{" "}
-            center.
-          </p>
-        </div>
-        <div className="flex flex-col gap-4 text-base font-medium sm:flex-row">
-          <a
-            className="flex h-12 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] md:w-[158px]"
-            href="https://vercel.com/new?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
-            target="_blank"
-            rel="noopener noreferrer"
-          >
-            <Image
-              className="dark:invert"
-              src="/vercel.svg"
-              alt="Vercel logomark"
-              width={16}
-              height={16}
-            />
-            Deploy Now
-          </a>
-          <a
-            className="flex h-12 w-full items-center justify-center rounded-full border border-solid border-black/[.08] px-5 transition-colors hover:border-transparent hover:bg-black/[.04] dark:border-white/[.145] dark:hover:bg-[#1a1a1a] md:w-[158px]"
-            href="https://nextjs.org/docs?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
-            target="_blank"
-            rel="noopener noreferrer"
-          >
-            Documentation
-          </a>
-        </div>
+    <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 font-sans">
+      <header className="bg-white dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 px-8 py-4 flex items-center justify-between">
+        <h1 className="text-xl font-bold text-zinc-900 dark:text-zinc-50">Dev Shop</h1>
+        <span className="text-sm text-zinc-500 dark:text-zinc-400">
+          {cart.length} item{cart.length !== 1 ? "s" : ""} in cart
+        </span>
+      </header>
+
+      <main className="max-w-6xl mx-auto px-8 py-10 grid grid-cols-1 lg:grid-cols-3 gap-10">
+        <section className="lg:col-span-2">
+          <div className="flex gap-2 mb-6 flex-wrap">
+            {categories.map((cat) => (
+              <button
+                key={cat}
+                onClick={() => setFilter(cat)}
+                className={`px-4 py-1.5 rounded-full text-sm font-medium border transition-colors ${
+                  filter === cat
+                    ? "bg-zinc-900 text-white border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50"
+                    : "bg-white text-zinc-600 border-zinc-200 hover:border-zinc-400 dark:bg-zinc-900 dark:text-zinc-400 dark:border-zinc-700"
+                }`}
+              >
+                {cat}
+              </button>
+            ))}
+          </div>
+
+          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
+            {filtered.map((product) => {
+              const inCart = cart.some((item) => item.id === product.id);
+              return (
+                <div
+                  key={product.id}
+                  className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5 flex flex-col gap-3"
+                >
+                  <div className="flex items-start justify-between">
+                    <div>
+                      <p className="text-xs font-medium text-zinc-400 uppercase tracking-wide">
+                        {product.category}
+                      </p>
+                      <h2 className="text-base font-semibold text-zinc-900 dark:text-zinc-50 mt-0.5">
+                        {product.name}
+                      </h2>
+                    </div>
+                    <span className="text-lg font-bold text-zinc-900 dark:text-zinc-50">
+                      ${product.price.toFixed(2)}
+                    </span>
+                  </div>
+                  <button
+                    onClick={() => addToCart(product)}
+                    disabled={inCart}
+                    className={`mt-auto w-full py-2 rounded-lg text-sm font-medium transition-colors ${
+                      inCart
+                        ? "bg-zinc-100 text-zinc-400 cursor-not-allowed dark:bg-zinc-800 dark:text-zinc-600"
+                        : "bg-zinc-900 text-white hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
+                    }`}
+                  >
+                    {inCart ? "Added" : "Add to Cart"}
+                  </button>
+                </div>
+              );
+            })}
+          </div>
+        </section>
+
+        <aside className="lg:col-span-1">
+          <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-6 sticky top-8">
+            <h2 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">
+              Your Cart
+            </h2>
+
+            {cart.length === 0 ? (
+              <p className="text-sm text-zinc-400">No items yet. Add something!</p>
+            ) : (
+              <ul className="flex flex-col gap-3 mb-6">
+                {cart.map((item) => (
+                  <li
+                    key={item.id}
+                    className="flex items-center justify-between text-sm"
+                  >
+                    <span className="text-zinc-700 dark:text-zinc-300">{item.name}</span>
+                    <div className="flex items-center gap-3">
+                      <span className="font-medium text-zinc-900 dark:text-zinc-50">
+                        ${item.price.toFixed(2)}
+                      </span>
+                      <button
+                        onClick={() => removeFromCart(item.id)}
+                        className="text-zinc-400 hover:text-red-500 transition-colors text-xs"
+                      >
+                        Remove
+                      </button>
+                    </div>
+                  </li>
+                ))}
+              </ul>
+            )}
+
+            {cart.length > 0 && (
+              <div className="border-t border-zinc-100 dark:border-zinc-800 pt-4 flex flex-col gap-2">
+                <div className="flex justify-between text-sm text-zinc-500">
+                  <span>Subtotal</span>
+                  <span>${subtotal.toFixed(2)}</span>
+                </div>
+                <div className="flex justify-between text-sm text-green-600">
+                  <span>Discount ({DISCOUNT_PERCENT}%)</span>
+                  <span>-${(subtotal * DISCOUNT_PERCENT / 100).toFixed(2)}</span>
+                </div>
+                <div className="flex justify-between font-bold text-zinc-900 dark:text-zinc-50 text-base mt-1">
+                  <span>Total</span>
+                  <span>${total.toFixed(2)}</span>
+                </div>
+                <button className="mt-4 w-full py-2.5 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 transition-colors">
+                  Checkout
+                </button>
+              </div>
+            )}
+          </div>
+        </aside>
       </main>
     </div>
   );

```
