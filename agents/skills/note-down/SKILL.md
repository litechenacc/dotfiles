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
1. **Run export script first**: use `~/.agents/skills/note-down/scripts/export-clean-session.sh`.
2. **Use cleaned export only**: never export from live session directly.
3. **Follow current vault rules**: `notes/`, `projects/`, `resources/`.
4. **Obsidian style**: valid YAML frontmatter + `[[wikilinks]]`.
5. **English only**: title, summary, decisions, and slug.
6. **Timestamp in frontmatter, not filename**: use `timestamp: YYYY-MM-DD-HH-mm`.

## Vault Targets (Simple Mode)
- Notes: `~/vault/notes/`
- Session HTML: `~/vault/resources/assets/sessions/`
- Base view file: `~/vault/AI-Sessions.base`

## Execution Procedure

### Step 1: Export cleaned session (single command)

```bash
~/.agents/skills/note-down/scripts/export-clean-session.sh
```

Parse stdout lines:
- `SESSION_ID=<uuid>`
- `SESSION_FILE=<jsonl path>`
- `EXPORT_HTML=<html path>`

### Step 2: Determine note metadata

Extract from session context:
- **slug**: lowercase ASCII + hyphens (e.g., `niri-keybind-fix`)
- **tags**: include `ai-session` first + 1–3 topic tags
- **purpose**: one sentence
- **title**: descriptive English title
- **summary / changes / decisions**: concise but complete
- **date**: `YYYY-MM-DD`
- **timestamp**: `YYYY-MM-DD-HH-mm` (24h format)

### Step 3: Write note

Path pattern:

```text
~/vault/notes/{slug}.md
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
timestamp: YYYY-MM-DD-HH-mm
purpose: "<one-sentence description>"
session_id: "<UUID>"
session_file: "[[resources/assets/sessions/<UUID>.html]]"
---

# <Title>

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

- Full session transcript: [[resources/assets/sessions/<UUID>.html]]
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
