# Dotfiles

This repository stores system setup as symlinks from `$HOME` to files in this directory.

## Layout

- `apps/` -> syncable application configs
- `apps/bash/home/` -> shell config (`.bashrc`, `.bash_aliases`)
- `apps/niri/config/niri/` -> window manager config (`~/.config/niri`)
- `apps/nvim/config/nvim/` -> neovim config (`~/.config/nvim`)
- `apps/noctalia/config/noctalia/` -> Noctalia config (`~/.config/noctalia`)
- `apps/opencode/config/opencode/` -> OpenCode managed files (`AGENTS.md`, `skills/`)
- `apps/aqua/config/aquaproj-aqua/aqua.yaml` -> global aqua config
- `mapping.toml` -> link source/target mapping used by `scripts/link.sh`
- `scripts/link.sh` -> recreate symlinks

## Re-link everything

```bash
~/.local/dotfiles/scripts/link.sh
```

If a destination already exists and is not a symlink, it is moved to `*.bak.<timestamp>` first.

`link.sh` also bootstraps `aqua` (if missing) and installs packages from `apps/aqua/config/aquaproj-aqua/aqua.yaml`.

All home/config path mapping is defined in `mapping.toml`.
