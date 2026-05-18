#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


usage() {
  cat >&2 <<'EOF'
Uso:
  review <owner/repo|github-url|ssh-url> <pr_number>
  comment review <owner/repo|github-url|ssh-url> <pr_number>

Também funciona sem instalar aliases/wrappers:
  ./review-pr.sh review <repo> <pr_number>
  ./review-pr.sh comment review <repo> <pr_number>
  ./review-pr.sh <repo> <pr_number>   # compatibilidade legada: gera preview, não posta
EOF
  exit 1
}

RUN_MODE="review"
POST_INLINE_COMMENTS="${POST_GITHUB_INLINE_COMMENTS:-0}"

case "$SCRIPT_NAME" in
  review)
    [[ "$#" -eq 2 ]] || usage
    TARGET_REPO="$1"
    PR_NUMBER="$2"
    RUN_MODE="review"
    POST_INLINE_COMMENTS="0"
    ;;
  comment)
    [[ "$#" -eq 3 && "${1:-}" == "review" ]] || usage
    TARGET_REPO="$2"
    PR_NUMBER="$3"
    RUN_MODE="comment_review"
    POST_INLINE_COMMENTS="1"
    ;;
  *)
    if [[ "${1:-}" == "review" ]]; then
      [[ "$#" -eq 3 ]] || usage
      TARGET_REPO="$2"
      PR_NUMBER="$3"
      RUN_MODE="review"
      POST_INLINE_COMMENTS="0"
    elif [[ "${1:-}" == "comment" && "${2:-}" == "review" ]]; then
      [[ "$#" -eq 4 ]] || usage
      TARGET_REPO="$3"
      PR_NUMBER="$4"
      RUN_MODE="comment_review"
      POST_INLINE_COMMENTS="1"
    else
      [[ "$#" -eq 2 ]] || usage
      TARGET_REPO="$1"
      PR_NUMBER="$2"
      RUN_MODE="legacy_review"
      POST_INLINE_COMMENTS="${POST_GITHUB_INLINE_COMMENTS:-0}"
    fi
    ;;
esac

MAX_DIFF_CHARS="${MAX_DIFF_CHARS:-30000}"
MAX_PR_BODY_CHARS="${MAX_PR_BODY_CHARS:-8000}"
MAX_APP_CONTEXT_CHARS_PER_FILE="${MAX_APP_CONTEXT_CHARS_PER_FILE:-12000}"
MAX_CHANGED_FILE_CHARS_PER_FILE="${MAX_CHANGED_FILE_CHARS_PER_FILE:-20000}"
MAX_CHANGED_FILES_TOTAL_CHARS="${MAX_CHANGED_FILES_TOTAL_CHARS:-120000}"
CLAUDE_MODEL="${CLAUDE_MODEL:-claude-sonnet-4-5}"
CLAUDE_MAX_TOKENS="${CLAUDE_MAX_TOKENS:-4096}"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

REVIEW_FILE="$TMP_DIR/pr-${PR_NUMBER}-review.md"
REVIEW_INPUT_FILE="$TMP_DIR/pr-${PR_NUMBER}-review-input.md"
USAGE_FILE="$TMP_DIR/pr-${PR_NUMBER}-usage.txt"
CHANGED_FILES_CONTEXT_FILE="$TMP_DIR/pr-${PR_NUMBER}.changed-files-context.md"
DIFF_TARGETS_FILE="$TMP_DIR/pr-${PR_NUMBER}-inline-review-targets.json"
INLINE_COMMENTS_JSON_FILE="$TMP_DIR/pr-${PR_NUMBER}-inline-comments.json"
INLINE_REVIEW_PAYLOAD_FILE="$TMP_DIR/pr-${PR_NUMBER}-inline-review-payload.json"
INLINE_REVIEW_RESPONSE_FILE="$TMP_DIR/pr-${PR_NUMBER}-inline-review-response.json"
REVIEW_STATUS_FILE="$TMP_DIR/pr-${PR_NUMBER}-review-status.txt"

PR_JSON_FILE="$TMP_DIR/pr.metadata.json"
RAW_DIFF_FILE="$TMP_DIR/pr.raw.diff"
SAFE_DIFF_FILE="$TMP_DIR/pr.safe.diff"
JIRA_RAW_FILE="$TMP_DIR/jira.raw.json"
CLAUDE_JSON_FILE="$TMP_DIR/claude-result.json"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Erro: comando obrigatório não encontrado: $1" >&2
    exit 1
  fi
}

need_cmd gh
need_cmd python3
need_cmd curl

trim() {
  printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

url_encode_path() {
  python3 - "$1" <<'PY'
import sys
import urllib.parse
print(urllib.parse.quote(sys.argv[1], safe="/"))
PY
}

url_encode_value() {
  python3 - "$1" <<'PY'
import sys
import urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=""))
PY
}

load_dotenv() {
  local env_file="${ENV_FILE:-.env}"

  if [[ ! -f "$env_file" ]]; then
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    line="$(trim "$line")"

    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue

    if [[ "$line" != *=* ]]; then
      echo "Aviso: ignorando linha inválida no .env: $line" >&2
      echo "Formato correto: NOME_DA_VARIAVEL=valor" >&2
      continue
    fi

    local key="${line%%=*}"
    local value="${line#*=}"

    key="$(trim "$key")"
    value="$(trim "$value")"

    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      echo "Aviso: ignorando variável inválida no .env: $key" >&2
      continue
    fi

    if [[ ${#value} -ge 2 ]]; then
      local first="${value:0:1}"
      local last="${value: -1}"

      if [[ "$first" == "$last" && ( "$first" == "\"" || "$first" == "'" ) ]]; then
        value="${value:1:${#value}-2}"
      fi
    fi

    export "$key=$value"
  done < "$env_file"
}

load_dotenv

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "Erro: ANTHROPIC_API_KEY não definida. Defina-a em .env ou no ambiente." >&2
  exit 1
fi

API_REPO_SLUG="$(python3 - "$TARGET_REPO" <<'PY'
import re
import sys
from urllib.parse import urlparse

repo = sys.argv[1].strip()

# git@github.com:owner/repo.git
if repo.startswith("git@") and ":" in repo:
    repo = repo.split(":", 1)[1]

# ssh://git@github.com/owner/repo.git or https://github.com/owner/repo.git
elif repo.startswith(("http://", "https://", "ssh://")):
    parsed = urlparse(repo)
    path = parsed.path.strip("/")
    parts = path.split("/")
    if len(parts) >= 2:
        repo = "/".join(parts[:2])

# github.com/owner/repo.git
elif repo.startswith("github.com/"):
    parts = repo.split("/")
    if len(parts) >= 3:
        repo = "/".join(parts[1:3])

repo = re.sub(r"\.git$", "", repo)
repo = repo.strip("/")

if repo.count("/") != 1:
    raise SystemExit(f"Invalid GitHub repository format after normalization: {repo}")

print(repo)
PY
)"

echo "GitHub API repo slug: ${API_REPO_SLUG}"
echo "Run mode: ${RUN_MODE}"

echo "Fetching PR metadata from ${API_REPO_SLUG} PR #${PR_NUMBER}..."

gh pr view "$PR_NUMBER" \
  --repo "$API_REPO_SLUG" \
  --json title,body,baseRefName,headRefName,headRefOid,url,author,files,changedFiles,additions,deletions \
  > "$PR_JSON_FILE"

BASE_REF="$(python3 - "$PR_JSON_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

print(data.get("baseRefName") or "main")
PY
)"

echo "Fetching PR diff from ${API_REPO_SLUG} PR #${PR_NUMBER}..."

if ! gh pr diff "$PR_NUMBER" \
  --repo "$API_REPO_SLUG" \
  --patch \
  --exclude "package-lock.json" \
  --exclude "pnpm-lock.yaml" \
  --exclude "yarn.lock" \
  --exclude "dist/*" \
  --exclude "build/*" \
  --exclude "coverage/*" \
  --exclude "storybook-static/*" \
  > "$RAW_DIFF_FILE" 2>/dev/null; then

  echo "gh pr diff with --exclude failed. Retrying without --exclude..."

  gh pr diff "$PR_NUMBER" \
    --repo "$API_REPO_SLUG" \
    --patch \
    > "$RAW_DIFF_FILE"
fi

echo "Redacting possible secrets and trimming diff..."

python3 - "$RAW_DIFF_FILE" "$SAFE_DIFF_FILE" "$MAX_DIFF_CHARS" <<'PY'
import re
import sys

raw_path = sys.argv[1]
safe_path = sys.argv[2]
max_chars = int(sys.argv[3])

with open(raw_path, "r", encoding="utf-8", errors="replace") as f:
    text = f.read()

patterns = [
    r'((?:api[_-]?key|token|secret|password)\s*[:=]\s*["\']?)(?!\$\{\{)[^"\'\s]+',
    r'((?:ANTHROPIC_API_KEY|JIRA_API_TOKEN|GITHUB_TOKEN|GH_TOKEN)\s*=\s*)(?!\$\{\{)[^\s]+',
    r'((?:authorization:\s*bearer\s+))[a-z0-9._\-]+',
]

for pattern in patterns:
    text = re.sub(pattern, r"\1[REDACTED_SECRET]", text, flags=re.IGNORECASE)

text = text[:max_chars]

with open(safe_path, "w", encoding="utf-8") as f:
    f.write(text)
PY


echo "Building inline review target map from diff..."

python3 - "$SAFE_DIFF_FILE" "$DIFF_TARGETS_FILE" <<'PY'
import json
import re
import sys

diff_path = sys.argv[1]
targets_path = sys.argv[2]

with open(diff_path, "r", encoding="utf-8", errors="replace") as f:
    diff = f.read().splitlines()

targets = []
path = None
old_line = None
new_line = None

hunk_re = re.compile(r"@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")

for raw in diff:
    if raw.startswith("diff --git "):
        path = None
        old_line = None
        new_line = None
        continue

    if raw.startswith("+++ "):
        value = raw[4:]
        if value.startswith("b/"):
            path = value[2:]
        elif value == "/dev/null":
            path = None
        continue

    if raw.startswith("@@ "):
        match = hunk_re.search(raw)
        if match:
            old_line = int(match.group(1))
            new_line = int(match.group(2))
        continue

    if not path or old_line is None or new_line is None:
        continue

    if raw.startswith("+") and not raw.startswith("+++"):
        targets.append({
            "path": path,
            "line": new_line,
            "side": "RIGHT",
            "kind": "addition",
            "text": raw[1:181],
        })
        new_line += 1
        continue

    if raw.startswith("-") and not raw.startswith("---"):
        targets.append({
            "path": path,
            "line": old_line,
            "side": "LEFT",
            "kind": "deletion",
            "text": raw[1:181],
        })
        old_line += 1
        continue

    if raw.startswith(" "):
        targets.append({
            "path": path,
            "line": new_line,
            "side": "RIGHT",
            "kind": "context",
            "text": raw[1:181],
        })
        old_line += 1
        new_line += 1
        continue

with open(targets_path, "w", encoding="utf-8") as f:
    json.dump(targets, f, ensure_ascii=False, indent=2)

print(f"Inline review targets saved to: {targets_path}")
print(f"Inline review target count: {len(targets)}")
PY

SELECTED_JIRA_KEY=""

if [[ -n "${JIRA_KEY:-}" ]]; then
  SELECTED_JIRA_KEY="$JIRA_KEY"
else
  SELECTED_JIRA_KEY="$(python3 - "$PR_JSON_FILE" <<'PY'
import json
import re
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

pattern = re.compile(r"\b[A-Z][A-Z0-9]+-\d+\b")

sources = [
    data.get("title") or "",
    data.get("headRefName") or "",
    data.get("body") or "",
]

for text in sources:
    matches = pattern.findall(text)
    if matches:
        print(matches[0])
        sys.exit(0)

print("")
PY
)"
fi

JIRA_CONTEXT_TEXT=""

if [[ -z "$SELECTED_JIRA_KEY" ]]; then
  JIRA_CONTEXT_TEXT="$(cat <<EOF
# Jira Context

- Status: NOT_FOUND

No Jira key was found in PR title, branch name, or PR body.

You can force one with:

\`\`\`bash
JIRA_KEY=RER-123 ./review-pr.sh ${TARGET_REPO} ${PR_NUMBER}
\`\`\`
EOF
)"
else
  echo "Fetching Jira context for ${SELECTED_JIRA_KEY}..."

  if [[ -z "${JIRA_BASE_URL:-}" || -z "${JIRA_EMAIL:-}" || -z "${JIRA_API_TOKEN:-}" ]]; then
    JIRA_CONTEXT_TEXT="$(cat <<EOF
# Jira Context

- Jira key: ${SELECTED_JIRA_KEY}
- Status: NOT_FETCHED

Missing one or more required environment variables:

- JIRA_BASE_URL
- JIRA_EMAIL
- JIRA_API_TOKEN

Expected .env format:

\`\`\`env
JIRA_BASE_URL=https://suaempresa.atlassian.net
JIRA_EMAIL=seu.email@empresa.com
JIRA_API_TOKEN=seu_token_aqui
\`\`\`
EOF
)"
  else
    JIRA_URL="${JIRA_BASE_URL%/}/rest/api/3/issue/${SELECTED_JIRA_KEY}?fields=summary,description,status,issuetype,priority,assignee,reporter,labels,components,fixVersions"

    HTTP_STATUS="$(
      curl --silent --show-error --location \
        --request GET \
        --user "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        --header "Accept: application/json" \
        --output "$JIRA_RAW_FILE" \
        --write-out "%{http_code}" \
        "$JIRA_URL" || true
    )"

    if [[ ! "$HTTP_STATUS" =~ ^2 ]]; then
      RESPONSE_PREVIEW="$(head -c 2000 "$JIRA_RAW_FILE" 2>/dev/null || true)"

      JIRA_CONTEXT_TEXT="$(cat <<EOF
# Jira Context

- Jira key: ${SELECTED_JIRA_KEY}
- Status: FETCH_FAILED
- HTTP status: ${HTTP_STATUS}

Possible causes:

- invalid JIRA_BASE_URL
- invalid JIRA_EMAIL
- invalid JIRA_API_TOKEN
- your Jira user cannot browse this project or issue
- selected Jira key is wrong

Raw response preview:

\`\`\`text
${RESPONSE_PREVIEW}
\`\`\`
EOF
)"
    else
      JIRA_CONTEXT_TEXT="$(python3 - "$JIRA_RAW_FILE" "$SELECTED_JIRA_KEY" <<'PY'
import json
import re
import sys

raw_path = sys.argv[1]
jira_key = sys.argv[2]

def adf_to_text(node):
    parts = []

    def walk(value):
        if value is None:
            return

        if isinstance(value, str):
            parts.append(value)
            return

        if isinstance(value, list):
            for item in value:
                walk(item)
            return

        if isinstance(value, dict):
            node_type = value.get("type")

            if node_type == "text":
                parts.append(value.get("text", ""))
                return

            content = value.get("content")
            if content:
                walk(content)

            if node_type in {"paragraph", "heading", "listItem"}:
                parts.append("\n")

    walk(node)
    text = "".join(parts)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()

try:
    with open(raw_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    fields = data.get("fields") or {}

    summary = fields.get("summary") or ""
    description = adf_to_text(fields.get("description"))
    status = (fields.get("status") or {}).get("name") or ""
    issue_type = (fields.get("issuetype") or {}).get("name") or ""
    priority = (fields.get("priority") or {}).get("name") or ""
    assignee = (fields.get("assignee") or {}).get("displayName") or "Unassigned"
    reporter = (fields.get("reporter") or {}).get("displayName") or ""
    labels = fields.get("labels") or []
    components = fields.get("components") or []
    fix_versions = fields.get("fixVersions") or []

    print("# Jira Context\n")
    print(f"- Jira key: {jira_key}")
    print("- Status: FETCHED")
    print(f"- Summary: {summary}")
    print(f"- Issue type: {issue_type}")
    print(f"- Workflow status: {status}")
    print(f"- Priority: {priority}")
    print(f"- Assignee: {assignee}")
    print(f"- Reporter: {reporter}")
    print(f"- Labels: {', '.join(labels) if labels else 'None'}")
    print(f"- Components: {', '.join(c.get('name', '') for c in components) if components else 'None'}")
    print(f"- Fix versions: {', '.join(v.get('name', '') for v in fix_versions) if fix_versions else 'None'}")
    print("\n## Description\n")
    print(description if description else "No Jira description provided.")

except Exception as exc:
    print("# Jira Context\n")
    print(f"- Jira key: {jira_key}")
    print("- Status: PARSE_FAILED\n")
    print(f"Could not parse Jira JSON response: {exc}")
PY
)"
    fi
  fi
fi

APP_CONTEXT_TEXT="# Application Context"$'\n'

# Build a temporary TSV with the files changed by the PR.
# This avoids Bash process substitution and keeps the while loop simple/portable.
CHANGED_FILES_LIST="$TMP_DIR/changed-files.tsv"

python3 - "$PR_JSON_FILE" > "$CHANGED_FILES_LIST" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

for file in data.get("files") or []:
    path = file.get("path") or ""
    change_type = file.get("changeType") or file.get("status") or ""
    additions = file.get("additions", "")
    deletions = file.get("deletions", "")

    if path:
        print(f"{path}\t{change_type}\t{additions}\t{deletions}")
PY

echo "Fetching full content of changed files from PR head..."

HEAD_REF="$(python3 - "$PR_JSON_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

print(data.get("headRefOid") or data.get("headRefName") or "")
PY
)"

cat > "$TMP_DIR/_decode_content.py" <<'PY'
import base64
import json
import re
import sys

json_path = sys.argv[1]
max_chars = int(sys.argv[2])
truncation_msg = sys.argv[3] if len(sys.argv) > 3 else "[Content truncated by script]"

with open(json_path, "r", encoding="utf-8", errors="replace") as f:
    data = json.load(f)

if isinstance(data, list):
    print("[Skipped: path is a directory, not a file]")
    sys.exit(0)

encoding = data.get("encoding")
content = data.get("content") or ""

if encoding != "base64":
    print(f"[Skipped: unsupported encoding: {encoding}]")
    sys.exit(0)

decoded = base64.b64decode(content).decode("utf-8", errors="replace")

patterns = [
    r'((?:api[_-]?key|token|secret|password)\s*[:=]\s*["\']?)(?!\$\{\{)[^"\'\s]+',
    r'((?:ANTHROPIC_API_KEY|JIRA_API_TOKEN|GITHUB_TOKEN|GH_TOKEN)\s*=\s*)(?!\$\{\{)[^\s]+',
    r'((?:authorization:\s*bearer\s+))[a-z0-9._\-]+',
]

for pattern in patterns:
    decoded = re.sub(pattern, r"\1[REDACTED_SECRET]", decoded, flags=re.IGNORECASE)

if len(decoded) > max_chars:
    decoded = decoded[:max_chars] + f"\n\n{truncation_msg}"

print(decoded)
PY

cat > "$TMP_DIR/_fetch_changed_files.py" <<'PY'
import base64
import concurrent.futures
import json
import re
import subprocess
import sys
import urllib.parse

tsv_path, repo_slug, ref, pr_number, max_per_file, max_total, output_path = sys.argv[1:]
max_per_file = int(max_per_file)
max_total = int(max_total)

REDACT_PATTERNS = [
    re.compile(r'((?:api[_-]?key|token|secret|password)\s*[:=]\s*["\']?)(?!\$\{\{)[^"\'\s]+', re.IGNORECASE),
    re.compile(r'((?:ANTHROPIC_API_KEY|JIRA_API_TOKEN|GITHUB_TOKEN|GH_TOKEN)\s*=\s*)(?!\$\{\{)[^\s]+', re.IGNORECASE),
    re.compile(r'((?:authorization:\s*bearer\s+))[a-z0-9._\-]+', re.IGNORECASE),
]

def decode_github_content(data, max_chars):
    if isinstance(data, list):
        return None, "directory"
    enc = data.get("encoding")
    raw = data.get("content") or ""
    if enc != "base64":
        return None, f"unsupported encoding: {enc}"
    decoded = base64.b64decode(raw).decode("utf-8", errors="replace")
    for pat in REDACT_PATTERNS:
        decoded = pat.sub(r"\1[REDACTED_SECRET]", decoded)
    if len(decoded) > max_chars:
        return decoded[:max_chars], "truncated"
    return decoded, "ok"

files = []
with open(tsv_path, encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\t")
        if parts[0]:
            files.append({
                "path": parts[0],
                "change_type": parts[1] if len(parts) > 1 else "",
                "additions": parts[2] if len(parts) > 2 else "",
                "deletions": parts[3] if len(parts) > 3 else "",
            })

def fetch_one(args):
    idx, info = args
    path = info["path"]
    enc_path = urllib.parse.quote(path, safe="/")
    enc_ref = urllib.parse.quote(ref, safe="")
    url = f"repos/{repo_slug}/contents/{enc_path}?ref={enc_ref}"
    proc = subprocess.run(
        ["gh", "api", "--method", "GET", url],
        capture_output=True, text=True
    )
    return idx, proc.returncode == 0, proc.stdout

print(f"Fetching {len(files)} changed file(s) in parallel...", flush=True)

with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    results = sorted(executor.map(fetch_one, enumerate(files)), key=lambda x: x[0])

header = [
    "# Changed Files Full Content",
    "",
    f"- Repository: {repo_slug}",
    f"- PR number: {pr_number}",
    "- Status: FETCHED_FROM_PR_HEAD",
    f"- Ref used: {ref}",
    f"- Max chars per file: {max_per_file}",
    f"- Max total chars: {max_total}",
]

sections = []
total_chars = sum(len(line) + 1 for line in header)

for idx, success, stdout in results:
    info = files[idx]
    path = info["path"]

    block = [
        "",
        f"## {path}",
        "",
        f"- Change type: {info['change_type'] or 'unknown'}",
        f"- Additions: {info['additions'] or 'unknown'}",
        f"- Deletions: {info['deletions'] or 'unknown'}",
        "",
    ]

    if success:
        try:
            data = json.loads(stdout)
            content, status = decode_github_content(data, max_per_file)
            if content is not None:
                block += ["```text", content, "```"]
                if status == "truncated":
                    block.append("[Changed file content truncated by script]")
            else:
                block.append(f"- Status: SKIPPED ({status})")
        except Exception as exc:
            block.append(f"- Status: DECODE_FAILED ({exc})")
    else:
        block += [
            "- Status: FETCH_FAILED",
            "- Reason: file may be deleted, renamed, binary, too large, or unavailable at PR head ref",
        ]

    chunk = "\n".join(block)
    total_chars += len(chunk) + 1

    if total_chars > max_total:
        sections.append("\n[Changed files full content truncated by script]")
        break

    sections.append(chunk)

with open(output_path, "w", encoding="utf-8") as f:
    f.write("\n".join(header + sections) + "\n")
PY

python3 "$TMP_DIR/_fetch_changed_files.py" \
  "$CHANGED_FILES_LIST" \
  "$API_REPO_SLUG" \
  "$HEAD_REF" \
  "$PR_NUMBER" \
  "$MAX_CHANGED_FILE_CHARS_PER_FILE" \
  "$MAX_CHANGED_FILES_TOTAL_CHARS" \
  "$CHANGED_FILES_CONTEXT_FILE"

if [[ -z "${APP_CONTEXT_FILES:-}" ]]; then
  APP_CONTEXT_TEXT+=$'\n'"- Status: NOT_CONFIGURED"$'\n'
  APP_CONTEXT_TEXT+=$'\n'"No APP_CONTEXT_FILES configured."$'\n'
else
  APP_CONTEXT_TEXT+=$'\n'"- Status: CONFIGURED"$'\n'
  APP_CONTEXT_TEXT+="- Base ref used: ${BASE_REF}"$'\n'
  APP_CONTEXT_TEXT+="- Files requested: ${APP_CONTEXT_FILES}"$'\n'

  IFS=',' read -ra APP_FILES <<< "$APP_CONTEXT_FILES"

  for raw_file in "${APP_FILES[@]}"; do
    app_file="$(trim "$raw_file")"
    [[ -z "$app_file" ]] && continue

    echo "Fetching application context file: ${app_file}"

    ENCODED_FILE="$(url_encode_path "$app_file")"
    ENCODED_REF="$(url_encode_value "$BASE_REF")"
    APP_FILE_JSON="$TMP_DIR/app-context-$(printf '%s' "$app_file" | tr '/ ' '__').json"

    if gh api --method GET "repos/${API_REPO_SLUG}/contents/${ENCODED_FILE}?ref=${ENCODED_REF}" > "$APP_FILE_JSON" 2>/dev/null; then
      FILE_TEXT="$(python3 "$TMP_DIR/_decode_content.py" "$APP_FILE_JSON" "$MAX_APP_CONTEXT_CHARS_PER_FILE" "[Application context file truncated by script]")"
      APP_CONTEXT_TEXT+=$'\n'"## ${app_file}"$'\n\n'
      APP_CONTEXT_TEXT+='\```text'$'\n'
      APP_CONTEXT_TEXT+="${FILE_TEXT}"$'\n'
      APP_CONTEXT_TEXT+='\```'$'\n'
    else
      APP_CONTEXT_TEXT+=$'\n'"## ${app_file}"$'\n\n'
      APP_CONTEXT_TEXT+="- Status: FETCH_FAILED"$'\n'
      APP_CONTEXT_TEXT+="- Reason: file not found, not readable, or invalid path/ref"$'\n'
    fi
  done
fi

python3 - "$PR_JSON_FILE" "$MAX_PR_BODY_CHARS" > "$TMP_DIR/pr-context.md" <<'PY'
import json
import sys

metadata_path = sys.argv[1]
max_body_chars = int(sys.argv[2])

with open(metadata_path, "r", encoding="utf-8") as f:
    data = json.load(f)

title = data.get("title") or ""
body = data.get("body") or ""
head_branch = data.get("headRefName") or ""
base_branch = data.get("baseRefName") or ""
url = data.get("url") or ""
author = data.get("author") or {}
author_login = author.get("login") or ""
changed_files = data.get("changedFiles")
additions = data.get("additions")
deletions = data.get("deletions")

if len(body) > max_body_chars:
    body = body[:max_body_chars] + "\n\n[PR body truncated by script]"

print("# Pull Request Context\n")
print(f"- PR title: {title}")
print(f"- PR URL: {url}")
print(f"- Head branch: {head_branch}")
print(f"- Base branch: {base_branch}")
print(f"- Author: {author_login}")
print(f"- Changed files: {changed_files}")
print(f"- Additions: {additions}")
print(f"- Deletions: {deletions}")
print("\n## PR Body\n")
print(body.strip() if body.strip() else "No PR body provided.")
PY

{
  echo "# Review Input"
  echo
  echo "This file is exactly the context passed to Claude through stdin."
  echo
  echo "Repository: ${API_REPO_SLUG}"
  echo "PR number: ${PR_NUMBER}"
  echo "Run mode: ${RUN_MODE}"
  echo
  echo "Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  echo "---"
  cat "$TMP_DIR/pr-context.md"
  echo
  echo "---"
  printf '%s\n' "$JIRA_CONTEXT_TEXT"
  echo
  echo "---"
  printf '%s\n' "$APP_CONTEXT_TEXT"
  echo
  echo "---"
  cat "$CHANGED_FILES_CONTEXT_FILE"
  echo
  echo "---"
  echo "# Allowed Inline Review Targets"
  echo
  echo "Claude may only create inline comments using path, line, and side values present in this JSON list."
  echo
  echo '```json'
  cat "$DIFF_TARGETS_FILE"
  echo
  echo '```'
  echo
  echo "---"
  echo "# Sanitized Pull Request Diff"
  echo
  echo '```diff'
  cat "$SAFE_DIFF_FILE"
  echo
  echo '```'
} > "$REVIEW_INPUT_FILE"

REVIEW_PROMPT_FILE="${REVIEW_PROMPT_FILE:-${SCRIPT_DIR}/prompts/review_system_prompt.md}"

if [[ ! -f "$REVIEW_PROMPT_FILE" ]]; then
  echo "Erro: prompt de review não encontrado: $REVIEW_PROMPT_FILE" >&2
  exit 1
fi

REVIEW_PROMPT="$(cat "$REVIEW_PROMPT_FILE")"

echo "Running Claude review via Anthropic API (model: ${CLAUDE_MODEL})..."

printf '%s' "$REVIEW_PROMPT" > "$TMP_DIR/system-prompt.txt"

python3 - "$TMP_DIR/system-prompt.txt" "$REVIEW_INPUT_FILE" \
  "$TMP_DIR/api-request.json" "${CLAUDE_MODEL}" "${CLAUDE_MAX_TOKENS}" <<'PY'
import json
import sys

system_path, input_path, output_path, model, max_tokens = \
    sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5])

with open(system_path, encoding="utf-8") as f:
    system_prompt = f.read()

with open(input_path, encoding="utf-8") as f:
    user_content = f.read()

request = {
    "model": model,
    "max_tokens": max_tokens,
    "system": [
        {
            "type": "text",
            "text": system_prompt,
            "cache_control": {"type": "ephemeral"},
        }
    ],
    "messages": [
        {"role": "user", "content": user_content}
    ],
}

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(request, f, ensure_ascii=False)
PY

set +e
HTTP_STATUS=$(curl -sS \
  -X POST "https://api.anthropic.com/v1/messages" \
  -H "x-api-key: ${ANTHROPIC_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: prompt-caching-2024-07-31" \
  -H "content-type: application/json" \
  --data-binary @"$TMP_DIR/api-request.json" \
  -o "$CLAUDE_JSON_FILE" \
  -w '%{http_code}')

if [[ "$HTTP_STATUS" =~ ^2 ]]; then
  CLAUDE_EXIT=0
else
  CLAUDE_EXIT=1
  echo "Anthropic API error (HTTP ${HTTP_STATUS}):" >&2
  cat "$CLAUDE_JSON_FILE" >&2
fi
set -e

python3 "${SCRIPT_DIR}/py/parse_review_result.py" \
  "$CLAUDE_JSON_FILE" \
  "$REVIEW_FILE" \
  "$USAGE_FILE" \
  "$REVIEW_INPUT_FILE" \
  "$CLAUDE_EXIT" \
  "$DIFF_TARGETS_FILE" \
  "$INLINE_COMMENTS_JSON_FILE" \
  "$INLINE_REVIEW_PAYLOAD_FILE" \
  "$PR_JSON_FILE" \
  "$TMP_DIR/inline-comment-count.txt" \
  "$REVIEW_STATUS_FILE"

cat "$REVIEW_FILE"


INLINE_COMMENT_COUNT="$(cat "$TMP_DIR/inline-comment-count.txt" 2>/dev/null || echo "0")"

REVIEW_STATUS="$(cat "$REVIEW_STATUS_FILE" 2>/dev/null || echo "accepted")"

if [[ "$CLAUDE_EXIT" -eq 0 ]]; then
  if [[ "$POST_INLINE_COMMENTS" == "1" ]]; then
    echo ""
    if [[ "$INLINE_COMMENT_COUNT" != "0" ]]; then
      echo "Posting ${INLINE_COMMENT_COUNT} inline review comment(s) to GitHub diff..."
    else
      echo "Posting accepted review comment to GitHub..."
    fi

    gh api \
      --method POST \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "repos/${API_REPO_SLUG}/pulls/${PR_NUMBER}/reviews" \
      --input "$INLINE_REVIEW_PAYLOAD_FILE" \
      > "$INLINE_REVIEW_RESPONSE_FILE"

    echo "GitHub review posted."
  elif [[ "$INLINE_COMMENT_COUNT" != "0" ]]; then
    echo ""
    echo "Inline comments were generated but not posted."
    echo "Review them in the output above."
    echo ""
    echo "To post them to the PR diff, run:"
    echo "comment review $API_REPO_SLUG $PR_NUMBER"
  else
    echo ""
    echo "Accepted review generated but not posted."
    echo "To post the accepted review to GitHub, run:"
    echo "comment review $API_REPO_SLUG $PR_NUMBER"
  fi
fi

if [[ "$CLAUDE_EXIT" -ne 0 ]]; then
  echo "" >&2
  echo "Claude review failed with HTTP status: $HTTP_STATUS" >&2

  case "$HTTP_STATUS" in
    400)
      echo "Possible cause: invalid request payload or context too large." >&2
      echo "Try reducing MAX_DIFF_CHARS or MAX_CHANGED_FILES_TOTAL_CHARS." >&2
      ;;
    401|403)
      echo "Possible cause: invalid or missing ANTHROPIC_API_KEY." >&2
      echo "Check the GitHub secret or local .env file." >&2
      ;;
    429)
      echo "Possible cause: Anthropic rate limit." >&2
      ;;
    500|529)
      echo "Possible cause: temporary Anthropic API/server overload." >&2
      ;;
    *)
      echo "Check the Anthropic error payload above." >&2
      ;;
  esac

  exit "$CLAUDE_EXIT"
fi

echo ""
echo "This script does not write to Jira."
echo "It only reads Jira with GET when Jira variables are configured."
echo ""
if [[ "$POST_INLINE_COMMENTS" == "1" ]]; then
  echo "GitHub review posting was enabled for this run."
else
  echo "GitHub review posting is disabled by default."
  echo 'Use: comment review <repo> <pr_number>'
fi
echo ""
echo "Fallback: to post the review as a regular PR timeline comment, pipe the output above with:"
echo "  <script> | gh pr comment $PR_NUMBER --repo $API_REPO_SLUG --body-file /dev/stdin"

if [[ -n "${OUTPUT_DIR:-}" ]]; then
  SAFE_REPO_SLUG="$(printf '%s' "${API_REPO_SLUG}" | tr '/:' '__' | tr -cd 'A-Za-z0-9._-')"
  PERSIST_DIR="${OUTPUT_DIR%/}/${SAFE_REPO_SLUG}"
  mkdir -p "$PERSIST_DIR"
  cp "$REVIEW_FILE"              "$PERSIST_DIR/" 2>/dev/null || true
  cp "$REVIEW_INPUT_FILE"        "$PERSIST_DIR/" 2>/dev/null || true
  cp "$USAGE_FILE"               "$PERSIST_DIR/" 2>/dev/null || true
  cp "$INLINE_COMMENTS_JSON_FILE"  "$PERSIST_DIR/" 2>/dev/null || true
  cp "$INLINE_REVIEW_PAYLOAD_FILE" "$PERSIST_DIR/" 2>/dev/null || true
  echo ""
  echo "Outputs saved to: $PERSIST_DIR"
fi