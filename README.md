# Dotfiles

This repository stores system setup as symlinks from `$HOME` to files in this directory.

## Layout

- `apps/` -> syncable application configs
- `apps/bash/home/` -> shell config (`.bashrc`, `.bash_aliases`)
- `apps/niri/config/niri/` -> window manager config (`/home/$USER/.config/niri`)
- `apps/nvim/config/nvim/` -> neovim config (`/home/$USER/.config/nvim`)
- `apps/noctalia/config/noctalia/` -> Noctalia config (`/home/$USER/.config/noctalia`)
- `apps/opencode/config/opencode/` -> OpenCode managed files (`AGENTS.md`, `skills/`)
- `apps/aqua/config/aquaproj-aqua/aqua.yaml` -> global aqua config
- `mapping.toml` -> link source/target mapping used by `scripts/link.sh`
- `scripts/link.sh` -> recreate symlinks
- `scripts/health-check.sh` -> validate current system state against mapping

## Skills layout

- Personal skills (dotfiles-managed): `agents/skills/`
- Community skills (separate upstream git): `agents/community-skills/<skill-repo>/`
- Exposure to pi/opencode: create a symlink in `agents/skills/` pointing to `../community-skills/<skill-repo>`

This keeps your own skills versioned in dotfiles while community skills stay in their own git history (via submodules).

After cloning this dotfiles repo on a new machine, fetch community skills with:

```bash
git submodule update --init --recursive
```

## Re-link everything

```bash
~/.local/dotfiles/scripts/link.sh
```

If a destination already exists and is not a symlink, it is moved to `*.bak.<timestamp>` first.

`link.sh` prints each link operation and a final stats summary.

`link.sh` also bootstraps `aqua` (if missing) and installs packages from `apps/aqua/config/aquaproj-aqua/aqua.yaml`.

All home/config path mapping is defined in `mapping.toml`.
`scripts/link.sh` expands `$USER`/`$HOME` placeholders in mapping paths.

## Health Check

```bash
~/.local/dotfiles/scripts/health-check.sh
```

This compares `mapping.toml` with actual files/symlinks under `/home/$USER` and exits non-zero when mismatches are found.
