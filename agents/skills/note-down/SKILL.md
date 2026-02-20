---
name: note-down
description: Record the current AI work session as an Obsidian-compatible note in the vault. Exports a cleaned HTML transcript (excluding note-down execution) and writes a structured session note.
---

# Skill: Note Down — AI Session Logger for Obsidian Vault

## Description
Record the current pi session into `~/vault`:
1) export cleaned transcript HTML (without note-down self-noise),
2) write a Markdown session note in Obsidian style.

## Core Directives
1. **Run export script first**: use `~/.agents/skills/note-down/scripts/export-clean-session.sh` (or `scripts/export-clean-session.sh` if already in the skill directory).
2. **Use cleaned export only**: never export from live session directly.
3. **Obsidian style**: valid YAML frontmatter + `[[wikilinks]]`.
4. **English only**: title, summary, decisions, and slug.

## Vault Targets
- Notes: `~/vault/10_areas/system/`
- Session HTML: `~/vault/30_resources/sessions/`

## Execution Procedure

### Step 1: Export cleaned session (single command)

```bash
~/.agents/skills/note-down/scripts/export-clean-session.sh
```

Parse stdout lines:
- `SESSION_ID=<uuid>`
- `SESSION_FILE=<jsonl path>`
- `EXPORT_HTML=<html path>`

> The script automatically:
> - resolves current session (prefers `/tmp/pi-sessions/$PPID` from `session-tracker` extension),
> - snapshots JSONL,
> - trims last user message (note-down trigger) and tail,
> - exports cleaned HTML,
> - removes temp files.

### Step 2: Determine note metadata

Extract from session context:
- **slug**: lowercase ASCII + hyphens (e.g., `niri-keybind-fix`)
- **tags**: include `ai-session` first + 1–3 topic tags
- **purpose**: one sentence
- **title**: descriptive English title
- **summary / changes / decisions**: concise but complete

### Step 3: Write note

Path pattern:

```text
~/vault/10_areas/system/{slug}-{YYYY-MM-DD}.md
```

If same filename exists, append `-2`, `-3`, ...

Template:

```markdown
---
type: session-log
tags:
  - ai-session
  - <tag1>
  - <tag2>
date: YYYY-MM-DD
purpose: "<one-sentence description>"
session_id: "<UUID>"
session_file: "[[30_resources/sessions/<UUID>.html]]"
---

# <Title> (<YYYY-MM-DD>)

## Purpose

<Why this work was initiated>

## Summary

- <Chronological bullets>

## Changes

| File / Path | Action | Description |
|-------------|--------|-------------|
| `path/to/file` | Created / Modified / Deleted | Brief description |

## Key Decisions

- **<Decision>**: <What> — <Why>

## Appendix

- Full session transcript: [[30_resources/sessions/<UUID>.html]]
```

### Step 4: Confirm to user
Report:
1. note path,
2. HTML export path,
3. brief summary.

## Companion Extension (recommended)
`~/.pi/agent/extensions/session-tracker.ts`
- Writes active session file to `/tmp/pi-sessions/<PID>`.
- Makes multi-instance session selection reliable.
- Without it, script falls back to most-recent JSONL in cwd session dir.
