---
name: niri
description: Configure Niri WM
---

# Skill: Niri WM Configuration & Management

## Description
This skill enables the agent to configure, troubleshoot, and optimize the Niri scrollable-tiling Wayland compositor. The agent MUST use the provided URLs to fetch the official documentation as the primary source of truth for all KDL syntax and feature support.

## Core Directives
1. **Always Fetch First:** Before generating or modifying `~/.config/niri/config.kdl`, identify the relevant topic and perform a web-fetch on the corresponding URL.
2. **KDL Syntax Only:** All Niri configuration must be written in valid KDL format.
3. **Scrollable Context:** Niri uses a scrollable column paradigm. Keep advice aligned with this (e.g., configuring column widths, not static grids).

## Niri Documentation Map (Web-Fetch Targets)

### Core Usage & Concepts
Use these URLs to understand how Niri operates, how to manage workspaces, and what external software is required.

* Getting Started: https://niri-wm.github.io/niri/Getting-Started.html
* Important Software (Bars, Portals, Launchers): https://niri-wm.github.io/niri/Important-Software.html
* Workspaces & Navigation: https://niri-wm.github.io/niri/Workspaces.html
* Floating Windows Management: https://niri-wm.github.io/niri/Floating-Windows.html
* Screencasting & PipeWire: https://niri-wm.github.io/niri/Screencasting.html
* XWayland Support: https://niri-wm.github.io/niri/Xwayland.html
* IPC Commands (niri msg): https://niri-wm.github.io/niri/IPC-niri-msg.html

### Configuration Reference
Use these URLs to fetch the exact KDL syntax for specific settings inside the `config.kdl` file. Note the `%3A` URL encoding for the colon in these specific paths.

* Configuration Introduction & Syntax: https://niri-wm.github.io/niri/Configuration%3A-Introduction.html
* Monitors, Resolution, & VRR (Outputs): https://niri-wm.github.io/niri/Configuration%3A-Outputs.html
* Keyboard, Mouse, & Touchpad (Input): https://niri-wm.github.io/niri/Configuration%3A-Input.html
* Gaps, Borders, & Column Widths (Layout): https://niri-wm.github.io/niri/Configuration%3A-Layout.html
* Window Rules (App IDs, Titles, Opacity): https://niri-wm.github.io/niri/Configuration%3A-Window-Rules.html
* Shortcuts & Key Bindings: https://niri-wm.github.io/niri/Configuration%3A-Key-Bindings.html
* Animations & Shaders: https://niri-wm.github.io/niri/Configuration%3A-Animations.html
* Touchpad Gestures: https://niri-wm.github.io/niri/Configuration%3A-Gestures.html

## Execution Procedure
1. Receive user request (e.g., "Set my gaps to 10px").
2. Match the request to a URL from the map (e.g., Configuration Layout).
3. Web-fetch the URL to read the current syntax.
4. Generate the KDL configuration block.
5. Remind the user to validate the new config by running `niri msg action check-config` in their terminal before reloading.
