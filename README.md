# Dotfiles

This repository stores system setup as symlinks from `$HOME` to files in this directory.

## Layout

- `bash/` -> shell config (`.bashrc`, `.bash_aliases`)
- `niri/` -> window manager config (`.config/niri`)
- `nvim/` -> neovim config (`.config/nvim`)
- `noctalia/` -> Noctalia config (`.config/noctalia`)
- `opencode/` -> OpenCode managed files (`global-AGENTS.md` -> `.config/opencode/AGENTS.md`, `skills/` -> `.config/opencode/skills`)
- `aqua/` -> global aqua config (`.config/aquaproj-aqua/aqua.yaml`)
- `scripts/link.sh` -> recreate symlinks

## Re-link everything

```bash
~/.local/dotfiles/scripts/link.sh
```

If a destination already exists and is not a symlink, it is moved to `*.bak.<timestamp>` first.

`link.sh` also bootstraps `aqua` (if missing) and installs packages from `aqua/.config/aquaproj-aqua/aqua.yaml`.
