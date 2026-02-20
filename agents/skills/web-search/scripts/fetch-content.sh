#!/usr/bin/env bash
# Fetch a URL and extract readable text content
# Usage: fetch-content.sh <url>
set -euo pipefail

URL="${1:?Usage: fetch-content.sh <url>}"

# Fetch HTML → extract readable text via python readability-like approach
curl -sS -L --max-time 15 \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/130.0.0.0 Safari/537.36" \
  -H "Accept: text/html" \
  "$URL" 2>/dev/null | python3 -c "
import sys, html, re

raw = sys.stdin.read()

# Strip scripts, styles, nav, header, footer
for tag in ['script','style','noscript','nav','header','footer','aside','svg']:
    raw = re.sub(rf'<{tag}[^>]*>.*?</{tag}>', '', raw, flags=re.DOTALL|re.IGNORECASE)

# Strip all HTML tags
text = re.sub(r'<[^>]+>', ' ', raw)
text = html.unescape(text)

# Collapse whitespace
text = re.sub(r'[ \t]+', ' ', text)
text = re.sub(r'\n\s*\n', '\n\n', text)
text = text.strip()

# Truncate to ~8000 chars
if len(text) > 8000:
    text = text[:8000] + '\n\n[... truncated]'

print(text)
"
