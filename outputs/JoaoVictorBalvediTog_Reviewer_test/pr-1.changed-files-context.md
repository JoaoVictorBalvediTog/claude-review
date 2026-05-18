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
