# note-down scripts

This folder contains helper scripts for the `note-down` skill.

## Scripts

### `export-clean-session.sh`
Export a **cleaned** HTML transcript for the current session.

What it does:
1. Detects the current session file (prefers `/tmp/pi-sessions/$PPID` from `session-tracker` extension).
2. Falls back to the most recently modified JSONL in the current cwd session folder.
3. Snapshots the session JSONL immediately.
4. Removes the last user message (the note-down trigger) and everything after it.
5. Exports cleaned HTML to `~/vault/30_resources/sessions/<SESSION_ID>.html`.
6. Removes temp files.

Output (stdout):
- `SESSION_ID=<uuid>`
- `SESSION_FILE=<jsonl path>`
- `EXPORT_HTML=<html path>`

## Usage

From any directory:

```bash
~/.agents/skills/note-down/scripts/export-clean-session.sh
```

If currently inside the skill directory (`~/.agents/skills/note-down`):

```bash
scripts/export-clean-session.sh
```

## Notes

- Recommended companion extension: `~/.pi/agent/extensions/session-tracker.ts`
- Without the extension, fallback session detection may be ambiguous if multiple pi instances run in the same working directory.
