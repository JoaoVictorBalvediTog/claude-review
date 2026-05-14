### Comment 1
**File:** app/page.tsx
**Line:** 43

`total` is computed as `subtotal * (DISCOUNT_PERCENT / 100)`, which gives only the discount amount (10% of the subtotal), not the discounted total. The displayed "Total" will always be less than the displayed "Discount" line, since both show the same value but the total should be the amount the customer actually pays.

Fix:
```ts
const total = subtotal * (1 - DISCOUNT_PERCENT / 100);
```
