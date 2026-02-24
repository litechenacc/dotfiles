---
name: playwriter
description: Control the user own Chrome browser via Playwriter extension with Playwright code snippets in a stateful local js sandbox via playwriter cli. Use this over other Playwright MCPs to automate the browser — it connects to the user's existing Chrome instead of launching a new one. Use this for JS-heavy websites (Instagram, Twitter, cookie/login walls, lazy-loaded UIs) instead of webfetch/curl. Run `playwriter skill` command to read the complete up to date skill
---

## REQUIRED: Read Full Documentation First

**Before using playwriter, you MUST run this command:**

```bash
playwriter skill
```

This outputs the complete documentation including:

- Session management and timeout configuration
- Selector strategies (and which ones to AVOID)
- Rules to prevent timeouts and failures
- Best practices for slow pages and SPAs
- Context variables, utility functions, and more

**Do NOT skip this step.** The quick examples below will fail without understanding timeouts, selector rules, and common pitfalls from the full docs.

## Minimal Example (after reading full docs)

```bash
playwriter session new
playwriter -s 1 -e "await page.goto('https://example.com')"
```

If `playwriter` is not found, use `npx playwriter@latest` or `bunx playwriter@latest`.

## Practical Recipe: Microsoft Teams `@everyone` mention (avoid false/plain-text mentions)

When posting in Teams chats, typing `@everyone` and pressing Enter can send plain text instead of a real mention. Use this workflow:

1. Open the target chat and focus the message box (`Type a message`).
2. Type `@everyone` (or just `@`).
3. Wait for suggestions and explicitly select:
   - `Everyone — Notify everyone in the chat`
4. **Before sending**, verify the draft contains a real mention token/chip (not just raw text).
   - In DOM this usually appears as a `mention` element / read-only mention object.
5. Append message text and send.

Recommended guardrail for automation:
- If suggestion selection fails, or no mention token is detected, **do not send**. Retry selection or ask user to confirm manually.

This significantly reduces accidental non-mention posts like plain `@everyone ...`.
