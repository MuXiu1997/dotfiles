# AGENTS.md

## Repo Shape
- This is a chezmoi source directory for personal dotfiles, not an app repo. Edit source paths such as `dot_config/zsh/dot_zshrc`; chezmoi maps prefixes like `dot_`, `private_`, and `executable_` to destination files and modes.
- Target chezmoi version is pinned in `.chezmoiversion` (`2.64.0`). README install path is `bash -c "$(curl -fsSL https://github.com/MuXiu1997/dotfiles/raw/main/install.sh)"`.
- Machine selection comes from `.chezmoi.yaml.tmpl`: `personal` and `work` are prompted tags; `darwin` or `linux` is added automatically. Package lists in `.homebrew-packages.yaml` are merged as `base + selected tags` by `.chezmoitemplates/homebrewPackages`.

## Secrets And Templates
- Encrypted values live under `.agefiles/*.age`; templates decrypt them with `{{ template "ageDecrypted" "name" }}`. Do not commit plaintext secret material.
- Age identity is configured to `~/.local/share/age_secret_key`; `.chezmoiscripts/run_once_before_01-setup-age-secret-key.sh.tmpl` installs it from `.age_secret_key.age`.
- `.chezmoiexternal.toml` fetches large/external config trees such as Oh My Zsh, Hammerspoon, WezTerm, Neovim, fonts, and zsh completions. Prefer updating those source repos or archive refs instead of editing generated external files.

## Commands
- Setup local tools with `mise install`; `mise.local.toml` installs `shellcheck`, `shfmt`, `ruff`, and `prek`, then runs `prek install`.
- Main verification: `prek run --all-files`. Hooks run whitespace/YAML checks, Ruff only on configured Python files, and `shellcheck --shell=bash --external-sources` plus `shfmt -w -i 2 -ci` only on `install.sh`, selected `.chezmoiscripts/*.sh.tmpl`, `private_dot_claude/executable_play-notification.sh`, and `.chezmoitemplates/shellLib`.
- Preview dotfile effects with `chezmoi diff` before applying. Use `chezmoi apply --dry-run --verbose` for a focused dry run when changing templates or scripts.
- Regenerate Karabiner JSON after editing `dot_config/private_karabiner/karabiner.ts` with `bash dot_config/private_karabiner/gen_private_karabiner_dot_json.sh`; it runs `deno fmt --single-quote=true --no-semicolons=true` and rewrites `private_karabiner.json`.

## Script Conventions
- Chezmoi scripts are ordered by filename: `run_once_before_*` installs Homebrew/core tools and age keys before files apply; `run_once_after_*` installs Homebrew/MAS packages and macOS defaults after apply; `run_onchange_after_99-install-fonts.sh.tmpl` installs fonts on macOS when external font cache hashes change.
- Shared shell logging helpers are embedded via `# {{ template "shellLib" . }}`. Keep script templates Bash-compatible because pre-commit checks them with ShellCheck as Bash.
- `dot_local/bin/executable_install-packages` is a Deno + zx script. It expects args like `formula:git`, `cask:wezterm`, or `mas:1630034110:Bob`; the package install script in `.chezmoiscripts` passes exactly that format.

## Local/Platform Gotchas
- macOS-only assets are guarded by chezmoi template conditionals or `.chezmoiignore`; avoid making Linux runs process `.ssh`, `.gnupg`, Karabiner, Hammerspoon, or IDEAVim paths unless the ignore rules are updated deliberately.
- Zsh config intentionally uses XDG paths and loads unmanaged local overrides from `~/.config/zsh/zshenv.local.d` and `~/.config/zsh/zshrc.local.d`; do not add machine-local secrets directly to managed zsh files.
- `dot_config/zsh/dot_zshrc` skips Powerlevel10k, zsh-vi-mode, zoxide, atuin, and prompt setup when `CURSOR_AGENT` is set. Preserve that guard for agent/non-interactive shell performance.
