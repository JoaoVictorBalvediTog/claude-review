# Claude PR Reviewer

Automated pull request reviewer powered by Claude. Reads the PR context, diff, changed files, and optional Jira integration, then posts inline review comments on GitHub.

## How it works

When a pull request is opened or updated, a GitHub Actions workflow runs the reviewer. It collects context (PR description, diff, Jira issue if configured) and calls Claude to produce a structured code review, which is posted directly on the PR.

## Install

Run this in the repository you want to enable reviews on:

```bash
npm exec --yes --package git+ssh://git@github.com:JoaoVictorBalvediTog/claude-review.git#main -- claude-pr-reviewer init
```

This creates `.github/workflows/claude-pr-review.yml` in the current directory.

### Required secret

Add `ANTHROPIC_API_KEY` to your GitHub repository or organization secrets.

### Next steps

1. Commit the generated workflow file.
2. Add `ANTHROPIC_API_KEY` in GitHub secrets.
3. Open or update a pull request — the reviewer will run automatically.

## Options

```bash
claude-pr-reviewer init --force                        # overwrite existing workflow
claude-pr-reviewer init --action-ref v2                # pin to a specific release
claude-pr-reviewer init --workflow-name my-review.yml  # custom workflow file name
```

## Jira integration

Optional. When `JIRA_BASE_URL`, `JIRA_EMAIL`, and `JIRA_API_TOKEN` are set (as repo secrets or env vars), the reviewer fetches the Jira issue linked in the PR and includes it as context.

## Local usage

You can also run reviews locally:

```bash
# Preview review without posting to GitHub
./review-pr.sh review owner/repo 123

# Generate and post review as a GitHub comment
./review-pr.sh comment review owner/repo 123
```

## Outputs

Each run writes files under `outputs/<owner__repo>/`:

| File | Description |
|---|---|
| `pr-<n>-review.md` | Human-readable review preview |
| `pr-<n>-review-input.md` | Full context sent to Claude |
| `pr-<n>-inline-comments.json` | Normalized inline comments |
| `pr-<n>-inline-review-payload.json` | Payload sent to GitHub |
| `pr-<n>-inline-review-response.json` | GitHub API response |
| `pr-<n>-usage.txt` | Token usage and diagnostics |
| `pr-<n>-review-status.txt` | `accepted` or `comments` |
