---
name: playwriter-teams
description: "Fast, reliable Microsoft Teams operations with playwriter: quickly jump to a chat/group, find a person, start DM/group chat, and send reliable @everyone mentions without false plain-text tags."
---

## Purpose

Use this skill when the task involves **Microsoft Teams Web (`https://teams.cloud.microsoft/`)** and you need speed + reliability for common actions.

## Required setup

1. Run `playwriter skill` first (required by playwriter skill itself).
2. Use a dedicated session:

```bash
playwriter session new
playwriter -s <id> -e "state.myPage = context.pages().find(p => p.url() === 'about:blank') ?? await context.newPage(); await state.myPage.goto('https://teams.cloud.microsoft/', { waitUntil: 'domcontentloaded' });"
```

## Fastest shortcuts (verified)

- Go to Chat app: `Ctrl+Shift+2`
- Focus global search: `Ctrl+Alt+E`
- Focus chat-list filter box: `Ctrl+Shift+F`
- New message/new chat composer: `Alt+Shift+N`

## Recipe 1: Fast jump to an existing chat/group (recommended)

This is the fastest stable way to jump to a known chat/group (e.g. `ALG 小圈圈`).

1. `Ctrl+Shift+2` (ensure Chat app)
2. `Ctrl+Shift+F` (focus left-rail filter)
3. Type target name
4. Click filtered chat item in left rail (or keep current opened chat if already matched)

Playwriter snippet:

```js
await page.keyboard.press('Control+Shift+2');
await page.keyboard.press('Control+Shift+f');
await page.keyboard.type('ALG 小圈圈');
await page.locator('[data-testid="list-item"]').filter({ hasText: 'ALG 小圈圈' }).first().click();
```

Notes:
- `Enter` in filter mode may trigger unintended behavior depending on current focus; clicking the filtered item is safer.
- Clear filter when done (`Clear filter text` button) to restore full list.

## Recipe 2: Fast find/open a person chat (DM)

For person lookup/start chat, `Alt+Shift+N` + people picker is reliable.

1. `Alt+Shift+N`
2. Focus `To:` field (`#people-picker-input`)
3. Type person name
4. Click suggestion option

```js
await page.keyboard.press('Alt+Shift+n');
const to = page.locator('#people-picker-input');
await to.click();
await to.fill('Gary Fan');
await page.getByRole('option', { name: /Gary Fan 范育豪/ }).first().click();
```

If chat already exists, Teams usually opens existing thread context immediately.

## Recipe 3: Global search fallback

Use when chat-list filter misses results.

1. `Ctrl+Alt+E`
2. Type keyword/person/group
3. Use result sections (`People`, `Messages`, `Group chats`) to open target

```js
await page.keyboard.press('Control+Alt+e');
await page.keyboard.type('ALG 小圈圈');
await page.keyboard.press('Enter');
```

## Recipe 4: Reliable `@everyone` mention (IMPORTANT)

Typing `@everyone` and sending directly may become plain text (no real mention).

Correct flow:
1. Focus message box (`textbox "Type a message"`)
2. Type `@everyone`
3. Explicitly select suggestion: `Everyone — Notify everyone in the chat`
4. Verify mention token/chip exists (not plain text)
5. Append text, then send

Guardrail:
- If mention token is not detected, **do not send**; retry selection.

Validation idea:
- Draft HTML should include mention structure (e.g. mention/read-only mention object), not just raw `@everyone` text.

## Safety / anti-mistake checklist

Before sending any message:
- Confirm correct chat header (group/person name)
- Confirm message box contains expected draft
- For `@everyone`, confirm it is a selected mention token
- Avoid Enter on ambiguous focus states (search/filter panes)

After sending:
- Verify left rail last message preview reflects sent text
- Verify thread has new message bubble with expected content

## Known pitfalls

- Dynamic message-box IDs (`new-message-...`) change between contexts; prefer role/name selectors where possible.
- Search/focus overlays can steal keyboard events; if behavior is odd, re-focus with shortcut and retry.
- `Enter` can submit or navigate depending on focused element; click explicit targets for deterministic behavior.
