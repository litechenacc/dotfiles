---
name: opencode-setup
description: OpenCode setup playbook for this dotfiles repo with local config, docs endpoint map, and source fallback
compatibility: opencode
metadata:
  audience: personal-dotfiles
  scope: setup
---

# OpenCode setup skill for this dotfiles repo

Use this when the user asks how to set up OpenCode config, commands, skills, AGENTS rules, linking, permissions, or troubleshooting.

## 1) Local config only (`~/.config/opencode`)

- Treat `~/.config/opencode` as the primary target for runtime configuration.
- In this repo, files live under `apps/opencode/config/opencode/` and are linked using `mapping.toml`.
- Always check `mapping.toml` before suggesting file paths.
- Current mappings of interest:
  - `apps/opencode/config/opencode/AGENTS.md` -> `~/.config/opencode/AGENTS.md`
  - `apps/opencode/config/opencode/skills` -> `~/.config/opencode/skills`

Path conventions to recommend:
- Global rules: `~/.config/opencode/AGENTS.md`
- Global skills: `~/.config/opencode/skills/<skill-name>/SKILL.md`
- Global commands: `~/.config/opencode/commands/<name>.md`
- Optional global config: `~/.config/opencode/opencode.json`

## 2) Do not use Claude-related defaults

- Prefer OpenCode-native files (`AGENTS.md`, `.opencode/skills`, `~/.config/opencode/skills`).
- Do not rely on `.claude/CLAUDE.md` or `.claude/skills` as defaults.
- If the user wants strict behavior, recommend disabling Claude compatibility via env vars:

```sh
export OPENCODE_DISABLE_CLAUDE_CODE=1
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
```

## 3) Web-fetch docs site map (fast routing)

When answering setup questions, fetch the most relevant endpoint directly. Use this routing map first, instead of browsing.

Core pages:
- Intro/start here -> https://opencode.ai/docs/
- Config schema and precedence -> https://opencode.ai/docs/config/
- Providers/auth/model access -> https://opencode.ai/docs/providers/
- Network/proxy/TLS -> https://opencode.ai/docs/network/
- Troubleshooting -> https://opencode.ai/docs/troubleshooting/
- Windows + WSL -> https://opencode.ai/docs/windows-wsl/

Usage pages:
- TUI basics + built-in commands -> https://opencode.ai/docs/tui/
- CLI usage (`opencode run`, etc.) -> https://opencode.ai/docs/cli/
- Web UI -> https://opencode.ai/docs/web/
- IDE integration -> https://opencode.ai/docs/ide/
- Zen -> https://opencode.ai/docs/zen/
- Share -> https://opencode.ai/docs/share/
- GitHub integration -> https://opencode.ai/docs/github/
- GitLab integration -> https://opencode.ai/docs/gitlab/

Configure pages:
- Tools and tool toggles -> https://opencode.ai/docs/tools/
- Rules / `AGENTS.md` -> https://opencode.ai/docs/rules/
- Agents -> https://opencode.ai/docs/agents/
- Models -> https://opencode.ai/docs/models/
- Themes -> https://opencode.ai/docs/themes/
- Keybinds -> https://opencode.ai/docs/keybinds/
- Commands (custom slash commands) -> https://opencode.ai/docs/commands/
- Formatters -> https://opencode.ai/docs/formatters/
- Permissions -> https://opencode.ai/docs/permissions/
- LSP servers -> https://opencode.ai/docs/lsp/
- MCP servers -> https://opencode.ai/docs/mcp-servers/
- ACP support -> https://opencode.ai/docs/acp/
- Skills -> https://opencode.ai/docs/skills/
- Custom tools -> https://opencode.ai/docs/custom-tools/

Develop pages:
- SDK -> https://opencode.ai/docs/sdk/
- Server -> https://opencode.ai/docs/server/
- Plugins -> https://opencode.ai/docs/plugins/
- Ecosystem -> https://opencode.ai/docs/ecosystem/

Discovery helper:
- Full sitemap index -> https://opencode.ai/sitemap.xml

Routing guidance examples:
- "How do I create a skill?" -> fetch `/docs/skills/`.
- "How do I create /test command?" -> fetch `/docs/commands/`.
- "Why AGENTS not loaded?" -> fetch `/docs/rules/` then `/docs/config/`.
- "How do I disable or ask for tool approvals?" -> fetch `/docs/permissions/`.
- "How do I set model/provider?" -> fetch `/docs/providers/` and `/docs/models/`.

## 4) Final fallback: check OpenCode source

If docs are missing, unclear, or outdated, use the official repository as fallback:
- https://github.com/anomalyco/opencode

Fallback method:
1. Search issues/discussions for known behavior and recent changes.
2. Inspect docs source and implementation in the repo to confirm actual behavior.
3. Prefer behavior verified in code over stale docs, and clearly state this in the answer.

## Validation checklist for skills/commands in this repo

- Skill file path is `apps/opencode/config/opencode/skills/<name>/SKILL.md`.
- Skill frontmatter includes `name` and `description`.
- `name` matches directory and regex `^[a-z0-9]+(-[a-z0-9]+)*$`.
- Commands live in `apps/opencode/config/opencode/commands/*.md`.
- Mapping includes links into `~/.config/opencode`.
