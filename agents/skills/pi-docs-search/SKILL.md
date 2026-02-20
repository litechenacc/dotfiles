---
name: pi-docs-search
description: Search and fetch pi coding agent documentation from GitHub. Use when encountering problems with pi configuration, extensions, skills, themes, providers, SDK, TUI, sessions, keybindings, settings, or any pi-related issue that requires looking up official documentation.
---

# Skill: Pi Coding Agent Documentation Search

## Description
This skill enables the agent to quickly look up official pi coding agent documentation when troubleshooting issues, configuring features, or building extensions/skills/themes. The agent MUST use the provided URLs to web-fetch the relevant documentation as the primary source of truth.

## Core Directives
1. **Always Fetch First:** Before answering pi-related questions, identify the relevant topic and fetch the corresponding URL using `bash` with `curl`.
2. **Use Raw URLs:** All URLs point to raw GitHub content for clean text output.
3. **Progressive Lookup:** Start with the most specific topic, then broaden if needed.
4. **Date Stamped:** This sitemap was created on **2025-02-20**. Documentation may evolve — always fetch for the latest content.

## How to Fetch
```bash
curl -sL "<URL_FROM_MAP>"
```

For multiple topics:
```bash
curl -sL "<URL1>" && echo "---" && curl -sL "<URL2>"
```

---

## Pi Documentation Site Map (Last Updated: 2025-02-20)

### 📘 Main README — Start Here
Overview of pi, quick start, all features, CLI reference, philosophy.

* **Pi README (Full Reference):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/README.md`

---

### ⚙️ Configuration & Settings
How to configure pi behavior, options, and preferences.

* **Settings (settings.json, all options):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/settings.md`

* **Providers (auth, API keys, subscriptions):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/providers.md`

* **Models (adding custom models via models.json):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/models.md`

* **Custom Provider (custom API/OAuth providers):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/custom-provider.md`

* **Keybindings (keyboard shortcuts, keybindings.json):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/keybindings.md`

* **Shell Aliases (useful shell shortcuts):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/shell-aliases.md`

---

### 🧩 Customization & Extensibility
Build and configure extensions, skills, prompts, themes, and packages.

* **Extensions (TypeScript modules, custom tools, UI, events):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/extensions.md`

* **Skills (on-demand capability packages, SKILL.md format):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/skills.md`

* **Prompt Templates (reusable prompts, Markdown files):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/prompt-templates.md`

* **Themes (dark/light, custom themes, hot-reload):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/themes.md`

* **Pi Packages (bundle & share via npm/git):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/packages.md`

---

### 💻 Programmatic Usage & Integration
Use pi as a library, via RPC, or JSON mode.

* **SDK (createAgentSession, embedding pi):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/sdk.md`

* **RPC Mode (stdin/stdout process integration):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/rpc.md`

* **JSON Mode (structured output events):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/json.md`

---

### 📁 Sessions & Context
Session management, branching, compaction, and tree navigation.

* **Sessions (JSONL format, branching, tree structure):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/session.md`

* **Compaction (context summarization, auto-compact):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/compaction.md`

* **Tree View (session navigation, branching):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/tree.md`

---

### 🖥️ Terminal UI
TUI components, rendering, and custom UI for extensions.

* **TUI Components (API for extension UI):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/tui.md`

---

### 🏗️ Platform-Specific
Platform setup guides and notes.

* **Windows:**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/windows.md`

* **Termux (Android):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/termux.md`

* **Terminal Setup (fonts, colors, etc.):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/terminal-setup.md`

---

### 🛠️ Development & Contributing
For developing pi itself or forking.

* **Development (setup, debugging, forking):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/docs/development.md`

* **Contributing Guidelines:**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/CONTRIBUTING.md`

---

### 📦 Extension Examples (Source Code)
Example extensions to learn from. Fetch these for implementation patterns.

* **Extensions Examples Directory Listing:**
  `https://api.github.com/repos/badlogic/pi-mono/contents/packages/coding-agent/examples/extensions`

* **SDK Examples Directory Listing:**
  `https://api.github.com/repos/badlogic/pi-mono/contents/packages/coding-agent/examples/sdk`

> To fetch a specific example file, use:
> `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/examples/extensions/<filename>`

---

### 🌐 Related Packages (Monorepo)
Other packages in the pi-mono repository.

* **pi-ai (Core LLM toolkit):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/ai/README.md`

* **pi-agent (Agent framework):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/agent/README.md`

* **pi-tui (Terminal UI components):**
  `https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/tui/README.md`

---

### 🔗 External Resources

* **Agent Skills Standard:** https://agentskills.io/specification
* **Pi Skills Collection:** https://github.com/badlogic/pi-skills
* **Anthropic Skills:** https://github.com/anthropics/skills
* **Pi Blog Post (Philosophy):** https://mariozechner.at/posts/2025-11-30-pi-coding-agent/
* **Discord Community:** https://discord.com/invite/3cU7Bz4UPx
* **npm Package:** https://www.npmjs.com/package/@mariozechner/pi-coding-agent
* **npm Package Search (pi-package):** https://www.npmjs.com/search?q=keywords%3Api-package

---

## Execution Procedure

1. **Identify the problem area** — Match the user's question to a topic category above.
2. **Fetch the relevant doc** — Use `curl -sL <URL>` to retrieve the raw Markdown content.
3. **Parse and extract** — Read the fetched content and find the specific section that answers the question.
4. **If insufficient** — Fetch additional related docs from the map, or check the examples.
5. **Apply the solution** — Provide the answer, code snippet, or configuration based on official documentation.

### Quick Topic Lookup

| Problem Area | Fetch First |
|---|---|
| Can't authenticate / API keys | Providers |
| Model not found / custom model | Models, Custom Provider |
| Extension not loading / writing extensions | Extensions |
| Skill not found / creating skills | Skills |
| Theme issues / custom themes | Themes |
| Session lost / branching | Sessions, Tree |
| Context too long / overflow | Compaction |
| Keyboard shortcuts not working | Keybindings |
| Settings not applying | Settings |
| TUI / custom UI components | TUI |
| Package install / share | Pi Packages |
| SDK / embedding pi | SDK |
| RPC / process integration | RPC |
| Windows / Android / terminal issues | Platform-Specific docs |
