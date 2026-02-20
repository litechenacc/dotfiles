#!/usr/bin/env bash
set -euo pipefail

# Exports a cleaned session HTML for note-down skill.
# Removes the last user message (note-down trigger) and everything after it.
#
# Output (stdout):
#   SESSION_ID=<uuid>
#   SESSION_FILE=<jsonl path>
#   EXPORT_HTML=<html path>

CWD_SLUG="--$(pwd | tr '/' '-')--"
SESSION_DIR="$HOME/.pi/agent/sessions/$CWD_SLUG"
VAULT_SESSIONS_DIR="$HOME/vault/resources/assets/sessions"
TRACKER_FILE="/tmp/pi-sessions/${PPID:-}"

mkdir -p "$VAULT_SESSIONS_DIR"

# 1) Identify current session file (preferred: session-tracker extension)
SESSION_FILE=""
if [[ -n "${PPID:-}" && -f "$TRACKER_FILE" ]]; then
  SESSION_FILE="$(cat "$TRACKER_FILE" 2>/dev/null || true)"
fi

# fallback: most recent file in cwd session folder
if [[ -z "$SESSION_FILE" ]]; then
  SESSION_FILE="$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1 || true)"
fi

if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
  echo "ERROR: Could not locate session file." >&2
  exit 1
fi

SESSION_ID="$(basename "$SESSION_FILE" .jsonl | sed 's/.*_//')"
SNAPSHOT="/tmp/pi-session-snapshot-$SESSION_ID.jsonl"
CLEAN="/tmp/pi-session-clean-$SESSION_ID.jsonl"
EXPORT_HTML="$VAULT_SESSIONS_DIR/$SESSION_ID.html"

cleanup() {
  rm -f "$SNAPSHOT" "$CLEAN"
}
trap cleanup EXIT

# 2) Snapshot immediately
cp "$SESSION_FILE" "$SNAPSHOT"

# 3) Trim last user message and everything after it
LAST_USER_LINE="$(grep -n '"role":"user"' "$SNAPSHOT" | tail -1 | cut -d: -f1 || true)"
if [[ -z "$LAST_USER_LINE" || "$LAST_USER_LINE" -le 1 ]]; then
  echo "ERROR: Could not find a valid last user message line in session snapshot." >&2
  exit 1
fi

head -n "$((LAST_USER_LINE - 1))" "$SNAPSHOT" > "$CLEAN"

# 4) Export cleaned snapshot
pi --export "$CLEAN" "$EXPORT_HTML" >/dev/null

# 5) Print machine-parseable output
cat <<EOF
SESSION_ID=$SESSION_ID
SESSION_FILE=$SESSION_FILE
EXPORT_HTML=$EXPORT_HTML
EOF
