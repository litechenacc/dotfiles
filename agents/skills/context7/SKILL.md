---
name: context7
description: Retrieve up-to-date documentation for software libraries, frameworks, and components via the Context7 API. Use this skill when looking up documentation for any programming library or framework, finding code examples for specific APIs or features, verifying correct usage of library functions, obtaining current API information that may have changed since training. NEVER install anything — only search and display results.
---

# Skill: Context7 Documentation Lookup

## Overview

This skill retrieves current documentation for software libraries and components by querying the Context7 API via curl. Use it instead of relying on potentially outdated training data.

## ⚠️ Critical Rules

1. **NEVER install any package, library, skill, or extension.** Only search and display information.
2. **NEVER run `npm install`, `pip install`, `apt install`, `bun add`, or any installation command** based on Context7 results.

## When to Use

- User asks about a mainstream library/framework's API (React, Next.js, FastAPI, Express, Vue, Angular, Django, etc.)
- User needs code examples for a specific library feature
- User wants to verify correct usage of a function/method
- Documentation might have changed since training data cutoff

## Workflow

### Step 1: Search for the Library

Find the Context7 library ID:

```bash
curl -s "https://context7.com/api/v2/libs/search?libraryName=LIBRARY_NAME&query=TOPIC" | jq '.results[:5]'
```

**Parameters:**
- `libraryName` (required): The library name (e.g., "react", "nextjs", "fastapi", "axios")
- `query` (required): Topic description for relevance ranking

**Response fields:**
- `id`: Library identifier for the context endpoint (e.g., `/websites/react_dev_reference`)
- `title`: Human-readable library name
- `description`: Brief description
- `totalSnippets`: Number of documentation snippets available

### Step 2: Fetch Documentation

Use the library ID from step 1:

```bash
curl -s "https://context7.com/api/v2/context?libraryId=LIBRARY_ID&query=TOPIC&type=txt"
```

**Parameters:**
- `libraryId` (required): The library ID from search results
- `query` (required): The specific topic to retrieve documentation for
- `type` (optional): `json` (default) or `txt` (plain text, more readable)

## Examples

### React hooks documentation

```bash
# Find React library ID
curl -s "https://context7.com/api/v2/libs/search?libraryName=react&query=hooks" | jq '.results[0].id'
# Returns: "/websites/react_dev_reference"

# Fetch useState documentation
curl -s "https://context7.com/api/v2/context?libraryId=/websites/react_dev_reference&query=useState&type=txt"
```

### Next.js routing documentation

```bash
# Find Next.js library ID
curl -s "https://context7.com/api/v2/libs/search?libraryName=nextjs&query=routing" | jq '.results[0].id'

# Fetch app router documentation
curl -s "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=app+router&type=txt"
```

### FastAPI dependency injection

```bash
# Find FastAPI library ID
curl -s "https://context7.com/api/v2/libs/search?libraryName=fastapi&query=dependencies" | jq '.results[0].id'

# Fetch dependency injection documentation
curl -s "https://context7.com/api/v2/context?libraryId=/fastapi/fastapi&query=dependency+injection&type=txt"
```

## Tips

- Use `type=txt` for more readable output
- Use `jq` to filter and format JSON responses
- Be specific with the `query` parameter to improve relevance
- If the first result isn't correct, check additional results in the array
- URL-encode query parameters containing spaces (use `+` or `%20`)
- No API key required for basic usage (rate-limited)
- When results are too long, use `jq` to extract relevant sections
