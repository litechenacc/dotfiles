#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path
from typing import Any


SECRET_PATTERNS = [
    re.compile(r"(^|/)\.env(\..+)?$", re.IGNORECASE),
    re.compile(r"\.(pem|key|p12|pfx|crt|cer|der)$", re.IGNORECASE),
    re.compile(r"(^|/)(id_rsa|id_dsa|id_ed25519)(\.pub)?$", re.IGNORECASE),
    re.compile(r"(^|/)(secrets?|credentials?)(\.|/|$)", re.IGNORECASE),
    re.compile(r"(^|/)\.aws/credentials$", re.IGNORECASE),
    re.compile(r"\.tfvars(\.json)?$", re.IGNORECASE),
]

GENERATED_PATTERNS = [
    re.compile(r"(^|/)(dist|build|coverage|out|target|node_modules|\.next|\.nuxt|generated)(/|$)", re.IGNORECASE),
    re.compile(r"\.min\.(js|css)$", re.IGNORECASE),
    re.compile(r"\.map$", re.IGNORECASE),
    re.compile(r"\.generated\.", re.IGNORECASE),
    re.compile(r"\.gen\.", re.IGNORECASE),
]


def run(cmd: list[str], check: bool = True) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\n{result.stderr.strip()}")
    return result.stdout.strip()


def run_lines(cmd: list[str]) -> list[str]:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def env_int(name: str, default: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def git_ref_exists(ref: str) -> bool:
    return subprocess.run(["git", "show-ref", "--verify", "--quiet", ref]).returncode == 0


def match_any(patterns: list[re.Pattern[str]], path: str) -> bool:
    return any(p.search(path) for p in patterns)


def detect_base_ref() -> tuple[str, str]:
    origin_head = run(["git", "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD"], check=False)
    if origin_head:
        return origin_head, origin_head.rsplit("/", 1)[-1]

    for candidate in ["main", "master", "trunk", "develop"]:
        if git_ref_exists(f"refs/heads/{candidate}"):
            return f"refs/heads/{candidate}", candidate
        if git_ref_exists(f"refs/remotes/origin/{candidate}"):
            return f"refs/remotes/origin/{candidate}", candidate

    return "", ""


def get_changed_files() -> tuple[list[str], set[str], set[str]]:
    changed = set()
    changed.update(run_lines(["git", "diff", "--name-only"]))
    changed.update(run_lines(["git", "diff", "--cached", "--name-only"]))
    changed.update(run_lines(["git", "ls-files", "--others", "--exclude-standard"]))

    deleted = set()
    deleted.update(run_lines(["git", "diff", "--name-only", "--diff-filter=D"]))
    deleted.update(run_lines(["git", "diff", "--cached", "--name-only", "--diff-filter=D"]))

    untracked = set(run_lines(["git", "ls-files", "--others", "--exclude-standard"]))
    return sorted(changed), deleted, untracked


def check_in_progress_ops(git_dir: Path) -> list[str]:
    markers = {
        "MERGE_HEAD": "merge",
        "CHERRY_PICK_HEAD": "cherry-pick",
        "REVERT_HEAD": "revert",
        "rebase-apply": "rebase",
        "rebase-merge": "rebase",
    }
    active = []
    for marker, name in markers.items():
        if (git_dir / marker).exists():
            active.append(name)
    return sorted(set(active))


def main() -> None:
    repo_root = Path(run(["git", "rev-parse", "--show-toplevel"]))
    os.chdir(repo_root)

    max_file_bytes = env_int("SMART_COMMIT_MAX_FILE_BYTES", 1_048_576)
    small_max_files = env_int("SMART_COMMIT_SMALL_MAX_FILES", 12)
    small_max_ahead = env_int("SMART_COMMIT_SMALL_MAX_AHEAD", 5)

    protected_exact = {"main", "master", "trunk", "develop", "dev"}
    protected_prefixes = ["release/"]
    small_prefixes = ["fix/", "feat/", "chore/", "docs/", "refactor/", "test/", "hotfix/"]

    changed, deleted, untracked = get_changed_files()

    safe_files: list[str] = []
    excluded_secret: list[str] = []
    excluded_generated: list[str] = []
    excluded_large: list[dict[str, Any]] = []

    for rel in changed:
        rel_posix = rel.replace("\\", "/")
        rel_lower = rel_posix.lower()

        # Deletions are safe to commit (important for cleanup).
        if rel in deleted:
            safe_files.append(rel)
            continue

        if match_any(SECRET_PATTERNS, rel_lower):
            excluded_secret.append(rel)
            continue

        if match_any(GENERATED_PATTERNS, rel_lower):
            excluded_generated.append(rel)
            continue

        path = repo_root / rel
        if path.exists() and path.is_file():
            size_bytes = path.stat().st_size
            if size_bytes > max_file_bytes:
                excluded_large.append({"path": rel, "size_bytes": size_bytes})
                continue

        safe_files.append(rel)

    branch = run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    detached = branch == "HEAD"

    remotes = run_lines(["git", "remote"])
    has_remote = len(remotes) > 0
    default_remote = "origin" if "origin" in remotes else (remotes[0] if remotes else "")

    upstream = run(["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], check=False)

    base_ref, base_branch = detect_base_ref()
    commits_ahead_base = None
    if base_ref:
        ahead_raw = run(["git", "rev-list", "--count", f"{base_ref}..HEAD"], check=False)
        if ahead_raw.isdigit():
            commits_ahead_base = int(ahead_raw)

    branch_lower = branch.lower()
    is_protected = branch_lower in protected_exact or any(branch_lower.startswith(p) for p in protected_prefixes)
    is_small_prefix = any(branch_lower.startswith(p) for p in small_prefixes)

    small_checks = {
        "not_detached": not detached,
        "not_protected": not is_protected,
        "small_prefix": is_small_prefix,
        "safe_files_within_limit": len(safe_files) <= small_max_files,
        "ahead_within_limit": commits_ahead_base is not None and commits_ahead_base <= small_max_ahead,
    }
    small_branch = all(small_checks.values())

    should_push = has_remote and small_branch and len(safe_files) > 0
    push_command = ""
    if should_push:
        if upstream:
            push_command = "git push"
        elif default_remote and not detached:
            push_command = f"git push -u {default_remote} {branch}"

    if should_push:
        auto_push_reason = "Small, non-protected branch with remote."
    elif not has_remote:
        auto_push_reason = "No git remote found."
    elif is_protected:
        auto_push_reason = "Protected branch. Auto-push disabled."
    elif not small_branch:
        auto_push_reason = "Branch considered large or not in small-branch prefixes."
    elif len(safe_files) == 0:
        auto_push_reason = "No safe files to commit."
    else:
        auto_push_reason = "Auto-push disabled by policy."

    git_dir_raw = run(["git", "rev-parse", "--git-dir"])
    git_dir = Path(git_dir_raw)
    if not git_dir.is_absolute():
        git_dir = (repo_root / git_dir).resolve()

    result = {
        "repo_root": str(repo_root),
        "branch": branch,
        "detached_head": detached,
        "base_ref": base_ref,
        "base_branch": base_branch,
        "remotes": remotes,
        "default_remote": default_remote,
        "upstream": upstream,
        "in_progress_ops": check_in_progress_ops(git_dir),
        "changed_files_total": len(changed),
        "safe_files": safe_files,
        "deleted_files": sorted(deleted),
        "untracked_files": sorted(untracked),
        "excluded": {
            "secret": excluded_secret,
            "generated": excluded_generated,
            "large": excluded_large,
        },
        "thresholds": {
            "max_file_bytes": max_file_bytes,
            "small_max_files": small_max_files,
            "small_max_ahead": small_max_ahead,
            "small_prefixes": small_prefixes,
            "protected_exact": sorted(protected_exact),
            "protected_prefixes": protected_prefixes,
        },
        "branch_size": {
            "safe_file_count": len(safe_files),
            "commits_ahead_base": commits_ahead_base,
            "small_checks": small_checks,
            "small_branch": small_branch,
        },
        "auto_push": {
            "should_push": should_push,
            "reason": auto_push_reason,
            "push_command": push_command,
        },
    }

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
