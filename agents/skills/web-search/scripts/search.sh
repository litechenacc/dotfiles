#!/usr/bin/env bash
# web-search: Brave API → ddgr fallback
# Usage: search.sh <query> [max_results]
set -euo pipefail

QUERY="${1:?Usage: search.sh <query> [max_results]}"
MAX="${2:-5}"

# Read API key from file
BRAVE_API_KEY=""
if [[ -f "${HOME}/.brave_apikey" ]]; then
  BRAVE_API_KEY="$(tr -d '\n' < "${HOME}/.brave_apikey")"
fi

HEADER_FILE=$(mktemp)
trap 'rm -f "$HEADER_FILE"' EXIT

# --- Brave Search API ---
_brave_search() {
  local query="$1" max="$2"
  local encoded_query
  encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${query//\'/\\\'}'))")
  local url="https://api.search.brave.com/res/v1/web/search?q=${encoded_query}&count=${max}"

  local resp
  resp=$(curl -sS --fail-with-body \
    -D "$HEADER_FILE" \
    -H "Accept: application/json" \
    -H "Accept-Encoding: gzip" \
    -H "X-Subscription-Token: ${BRAVE_API_KEY}" \
    --compressed \
    "$url" 2>&1) || {
      echo "[brave-error] $resp" >&2
      return 1
    }

  # Check for API error response
  if echo "$resp" | jq -e '.type == "ErrorResponse"' &>/dev/null; then
    echo "[brave-error] $(echo "$resp" | jq -r '.message // "unknown error"')" >&2
    return 1
  fi

  # Show quota from response headers
  local remaining
  remaining=$(grep -i '^x-ratelimit-remaining:' "$HEADER_FILE" | sed 's/.*,\s*//' | tr -d '\r' || echo "?")
  echo "[engine: brave] (monthly remaining: ${remaining})"

  echo "$resp" | jq -r '
    .web.results[:'"$max"'] | to_entries[] |
    "--- Result \(.key + 1) ---\nTitle: \(.value.title)\nURL: \(.value.url)\nSnippet: \(.value.description)\n"
  '
}

# --- DDG Search via ddgr ---
_ddg_search() {
  if ! command -v ddgr &>/dev/null; then
    echo "[ddg-error] ddgr not installed. Install: sudo pacman -S ddgr" >&2
    return 1
  fi
  echo "[engine: ddgr/duckduckgo]"
  ddgr -n "$2" --json "$1" 2>/dev/null | jq -r '
    to_entries[] |
    "--- Result \(.key + 1) ---\nTitle: \(.value.title)\nURL: \(.value.url)\nSnippet: \(.value.abstract)\n"
  '
}

# --- Check remaining quota from last known header or try Brave first ---
_brave_has_quota() {
  [[ -n "$BRAVE_API_KEY" ]] || return 1
  return 0
}

# --- Main ---
if _brave_has_quota; then
  if _brave_search "$QUERY" "$MAX"; then
    exit 0
  fi
  echo "[fallback] Brave failed, trying ddgr..." >&2
fi

_ddg_search "$QUERY" "$MAX"
