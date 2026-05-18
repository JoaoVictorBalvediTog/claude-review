# Inline PR review comments preview

### Comment 1
**File:** app/page.tsx
**Line:** 43
**Side:** RIGHT

Critical bug: This calculates only 10% of the subtotal instead of applying a 10% discount. The total will be much lower than intended (e.g., $100 subtotal becomes $10 instead of $90). Fix: `const total = subtotal * (1 - DISCOUNT_PERCENT / 100);`
