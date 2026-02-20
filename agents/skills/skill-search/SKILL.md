---
name: skill-search
description: Search for AI coding skills and packages across Context7 and Playbooks directories. Use when the user asks if there are skills, plugins, or packages available for a specific topic, library, or workflow. Searches both sources and presents consolidated results. NEVER install anything — only search and display results.
---

# Skill: Skill Search

## Overview

Search for available AI coding skills across two directories:
- **Context7** — Large skill index with trust scores and install counts
- **Playbooks** — Curated directory with official and community skills

## ⚠️ Critical Rules

1. **NEVER install any skill, package, or extension.** Only search and display results.
2. **NEVER run `bunx ctx7 skills install`, `bunx playbooks add`, `npm install`, or any installation command.**
3. Always **report findings to the user** and let them decide what to install themselves.
4. When presenting results, include the install command for reference so the user can copy it if they choose.

## When to Use

- User asks "is there a skill/plugin for X?"
- User asks "find me skills related to X"
- User wants to know what's available before deciding to install
- User is exploring what AI coding skills exist for a topic

## Workflow

### Always search BOTH sources in parallel, then consolidate results.

### Source 1: Context7

```bash
echo "" | timeout 10 bunx ctx7 skills search "QUERY" 2>&1 | grep -E '^\s*(❯◯| ◯)\s+\d+\.' | sed 's/\x1b\[[0-9;]*m//g; s/❯◯/  /; s/ ◯/  /' | head -15
```

This extracts the skill list (name, installs, trust score) without entering the interactive installer.

### Source 2: Playbooks

```bash
bunx playbooks find skill "QUERY" 2>&1
```

This returns a clean list with descriptions and install commands.

## How to Present Results

Combine results from both sources into a single table or list. Include:

| Field | Description |
|---|---|
| **Name** | Skill name |
| **Source** | Context7 or Playbooks |
| **Description** | What the skill does (from Playbooks; Context7 may not include this) |
| **Installs** | Number of installs (if available) |
| **Trust** | Trust score (Context7 only, 0-10) |
| **Install command** | The command the user would run IF they choose to install |

### Install command formats (for user reference only):
- **Context7:** `bunx ctx7 skills install /REPO_OWNER/REPO_NAME SKILL_NAME`
- **Playbooks:** `bunx playbooks add skill OWNER/REPO --skill SKILL_NAME`

## Example

User asks: "Are there any skills for web search?"

```bash
# Search both in parallel
echo "" | timeout 10 bunx ctx7 skills search "web search" 2>&1 | grep -E '^\s*(❯◯| ◯)\s+\d+\.' | sed 's/\x1b\[[0-9;]*m//g; s/❯◯/  /; s/ ◯/  /' | head -15
```

```bash
bunx playbooks find skill "web search" 2>&1
```

Then present a consolidated summary like:

> Here are the skills I found for "web search":
>
> **From Playbooks:**
> - **duckduckgo-search** — Performs real-time web searches using DuckDuckGo
>   `bunx playbooks add skill openclaw/skills --skill duckduckgo-search`
> - **brave-search** (35 installs) — Search the web using Brave Search API
>   `bunx playbooks add skill steipete/agent-scripts --skill brave-search`
>
> **From Context7:**
> - **perplexity** (16 installs, trust 6.0)
> - **perplexity-search** (10 installs, trust 10.0)
> - **searxng-search** (1 install)
>
> Would you like to install any of these?

## Tips

- Search with different keywords if initial results aren't relevant
- Playbooks results include descriptions; Context7 results have trust scores
- Context7 `timeout 10` prevents hanging on slow connections
- The `echo "" | ... | grep` pattern prevents ctx7 from blocking in interactive mode
- For more detail on a Context7 skill, use: `bunx ctx7 skills info /REPO_OWNER/REPO_NAME`
