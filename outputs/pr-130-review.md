### Summary

Two commits fix the false-success toast on signup: the first re-throws the caught error so `toaster.promise` receives a rejected promise and shows the error state; the second adds client-side Zod validation (letter-only names, min-length, `.trim()`) to catch the known `fullName` format rejection before the request is sent. Together they fully address the reported bug with no collateral changes.

### Context used

- **PR title:** fix: RER-486 correcting signup displaying success on status 400
- **Branch:** fix/RER-486-signup-false-success-error → staging
- **Jira key:** RER-486 — fetched successfully
- **Application context:** README.md included (confirms Next.js + React Hook Form + Zod + Axios stack)
- **Changed file full content:** `src/pages/auth/signup.tsx` — included

### Task fit

The diff directly implements the Jira intent:
- Root cause fixed: `throw error` ensures the promise passed to `toaster.promise` rejects on API failure, so the error toast fires instead of the success one.
- Secondary fix: Zod schema now rejects numeric-only last names (the specific triggering case in the Jira) and enforces `min(2)` + `nameRegex` client-side, eliminating the 400 before it reaches the server.

No gaps in coverage relative to the described bug.

### Blocking issues

None.

### Manual verification needed

1. **`toaster.promise` rejection semantics** — Confirm that the toaster library used here (`@/components/ui/toaster`) treats a rejected promise as the error state. If it swallows rejections or requires a different API, the first commit would not produce the error toast. Worth a quick smoke-test in staging.
2. **Other API error paths** — If `httpClient.profiles.create` can fail for reasons other than name format (e.g., duplicate email, network error), verify those also surface correctly now that `throw error` is in place. These paths weren't in the Jira but are now covered by the same fix.

### Non-blocking issues

- `nameRegex = /^[A-Za-zÀ-ÿ\s]+$/` — The `À-ÿ` Unicode block technically includes `×` (U+00D7) and `÷` (U+00F7). These would pass validation. Practically, users won't type them, but using `\p{L}` with the `u` flag would be more precise if that ever matters.
- The `.trim()` calls on `data.firstName.trim()` / `data.lastName.trim()` in the API payload are redundant since Zod's `.trim()` transform already mutates the parsed value. Harmless, but worth cleaning up.
- `console.log(error)` remains in the catch block — pre-existing, not introduced here.

### Suggested tests

```bash
# Manual smoke test
# 1. Enter first name "test", last name "123" → submit → expect error toast, no redirect
# 2. Enter first name "a", last name "Smith" → expect client-side "at least 2 characters" error, no request sent
# 3. Enter valid names + email → expect success toast and redirect to /auth
# 4. Enter valid names + already-registered email → expect error toast (covers duplicate-email path)
```

### Verdict

SAFE TO MERGE
