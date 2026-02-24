# Global Agent Rules

## Package & Tool Management

- **JavaScript/TypeScript**: Use `pnpm` for all package installation and management. Never use `npm` or `yarn`.
- **Python**: Use `uv` for all Python-related package installation, virtual environments, and project management. Never use `pip`, `pip3`, `poetry`, or `conda` directly.
- **Allowed basic CLI tools (no extra approval needed)**: `git`, `rg`, `fzf`, `bat`, `cat`, `ls`, `find`, `grep`, `awk`, `sed`, `jq`, and similar standard shell utilities for development workflows.
- **Other tools/package managers**: If a task requires a non-standard tool or package manager outside of `pnpm`, `uv`, and the basic CLI tools above, **ask the user for approval before running it**.

