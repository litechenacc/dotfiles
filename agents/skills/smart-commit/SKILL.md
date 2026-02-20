---
name: smart-commit
description: Analyze the current git worktree, exclude secret/generated/large files, propose semantic commit groups with rationale for human approval, create English commits in a fixed format, and auto-push only for small non-protected branches.
compatibility: Requires git and python3.
metadata:
  author: litechen
  version: "0.1.0"
---

# Skill: Smart Commit

Use this skill when the user asks for **"smart commit"**.

## Core Rules

1. Run `scripts/inspect-worktree.py` first.
2. Never stage excluded files (`secret`, `generated`, `large`).
3. Propose commit grouping first; user must choose before commit.
4. Commit messages must be English.
5. Auto-push only when policy says branch is small and safe.

## Workflow

### 1) Inspect worktree

```bash
python3 ~/.agents/skills/smart-commit/scripts/inspect-worktree.py
```

- If `in_progress_ops` is not empty (merge/rebase/cherry-pick), stop and ask user.
- Show excluded files and reasons.
- Only use `safe_files` in commit planning.

### 2) Propose semantic commit plan (human-in-the-loop)

Analyze diffs on `safe_files` and propose:
- **Recommended plan** (1..N commits)
- **Reasoning** for each group (why files belong together)
- **Alternative**: merge groups or single-commit option

Then ask user to choose (A/B/C/custom) before executing.

Grouping heuristics:
- Same purpose + same subsystem => same commit.
- Tests/docs tied to one change stay in that commit.
- Unrelated intents (feat vs refactor vs docs-only) split.
- If all changes are highly cohesive, single commit is allowed.

### 3) Commit execution

For each approved group:
1. Stage only that group’s files.
2. Commit with this exact format:

```text
[category]: short title

why:
- why this change is needed

how:
- how it is implemented

what:
- key file/behavior changes
```

Allowed categories:
`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `build`, `perf`, `revert`.

### 4) Auto-push policy

Use `auto_push` from inspection result:
- If `should_push=true`, run `push_command`.
- Else do not auto-push; explain reason and provide manual command.

Protected branches never auto-push: `main`, `master`, `trunk`, `develop`, `dev`, `release/*`.

Default small-branch thresholds (from script):
- Branch prefix in: `fix/`, `feat/`, `chore/`, `docs/`, `refactor/`, `test/`, `hotfix/`
- Safe files ≤ 12
- Commits ahead of base branch ≤ 5

### 5) Final report

Report:
- commit plan chosen
- commit hashes/messages
- excluded files (if any)
- push result (or why skipped)
