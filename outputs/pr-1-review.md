# Inline PR review comments preview

### Comment 1
**File:** app/page.tsx
**Line:** 43
**Side:** RIGHT

The `total` calculation is wrong — it computes the discount amount rather than the post-discount price. For a $100 subtotal this renders `$10.00` as the total instead of `$90.00`.

Fix:
```ts
const total = subtotal * (1 - DISCOUNT_PERCENT / 100);
```

Note that the discount row in the JSX (line 150) already computes `subtotal * DISCOUNT_PERCENT / 100` correctly for display, so only this variable needs to change.
