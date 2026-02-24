# Dotfiles

This repository stores system setup as symlinks from `$HOME` to files in this directory.

## Layout

- `apps/` -> syncable application configs
- Pattern: `apps/<app>/<type>/...` (kept flat, no duplicated app-name layer)
- Examples:
  - `apps/bash/bashrc` -> `/home/$USER/.bashrc`
  - `apps/bash/bash_aliases` -> `/home/$USER/.bash_aliases`
  - `apps/nvim/config/` -> `/home/$USER/.config/nvim`
  - `apps/mise/config/config.toml` -> `/home/$USER/.config/mise/config.toml`
- `mapping.toml` -> link source/target mapping used by `scripts/link.sh`
- `scripts/link.sh` -> recreate symlinks
- `scripts/health-check.sh` -> validate current system state against mapping

## Skills layout

- Personal skills (dotfiles-managed): `agents/skills/`
- Community skills (separate upstream git): `agents/community-skills/<skill-repo>/`
- Exposure to pi/opencode: create a symlink in `agents/skills/` pointing to `../community-skills/<skill-repo>`

After cloning this dotfiles repo on a new machine, fetch community skills with:

```bash
git submodule update --init --recursive
```

## Bootstrap (full setup)

Run this from the repo root:

```bash
./scripts/bootstrap.sh
```

What it does:
- initializes git submodules
- applies all symlinks from `mapping.toml`
- installs `mise` (if missing) and installs tools from `~/.config/mise/config.toml`
- runs health check

For a fresh machine:

```bash
git clone <your-dotfiles-repo> ~/.local/dotfiles
cd ~/.local/dotfiles
./scripts/bootstrap.sh
```

## Bootstrap only mise

If you only want `mise` + tool installation:

```bash
./scripts/bootstrap-mise.sh
```

## Re-link everything

```bash
~/.local/dotfiles/scripts/link.sh
```

If a destination already exists and is not a symlink, it is moved to `*.bak.<timestamp>` first.

All home/config path mapping is defined in `mapping.toml`.
`link.sh` expands `$USER`/`$HOME` placeholders in mapping paths.

## Health Check

```bash
~/.local/dotfiles/scripts/health-check.sh
```

This compares `mapping.toml` with actual files/symlinks under `/home/$USER` and exits non-zero when mismatches are found.
