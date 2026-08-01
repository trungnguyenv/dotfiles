# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal nix-darwin flake for a single Mac (`darwinConfigurations."mac"`, aarch64-darwin). Combines nix-darwin (system/macOS defaults), home-manager (user packages/dotfiles), and nix-homebrew (Homebrew casks managed declaratively).

## Commands

- `./rebuild.sh` — symlinks this repo to `~/.dotfiles` (if not already linked) and runs `sudo nix run nix-darwin -- switch --flake ~/.dotfiles#mac`. This is the only way to apply changes; there is no separate build/test step.
- `.envrc` loads the flake via direnv (`use flake`) — direnv must be allowed (`direnv allow`) after cloning or editing `flake.nix` inputs.
- `nix flake update` — bump `flake.lock` (nixpkgs/nix-darwin/home-manager/nix-homebrew are pinned to `-26.05` release branches, kept in lockstep via `.inputs.nixpkgs.follows`).
- `nix flake check --no-build` — evaluates `darwinConfigurations.mac` without building it; run this after any change to `.nix` files (fast sanity check that catches eval errors before you commit to a full `./rebuild.sh`).

## Architecture

- `flake.nix` is the entry point: defines the single `user` var and wires `configuration.nix` (system module) + `nix-homebrew` + `home-manager` (with `home.nix` as the per-user module) into one `darwinSystem`.
- `configuration.nix` — system-level: macOS `system.defaults` (dark mode, key repeat, dock/finder/trackpad tweaks), and the `homebrew` block (`onActivation.cleanup = "zap"` means anything not listed in `casks`/`brews` gets removed on rebuild — be deliberate about additions/removals here).
- `home.nix` — user-level: CLI packages, zsh (aliases, autosuggestion/syntax-highlighting), starship prompt, and dotfile wiring via `mkOutOfStoreSymlink` pointing at `~/.dotfiles/home/...`. That pattern means the *real* config files live under `home/` in this repo and are edited in place — `home.nix` only declares the symlink, so config content changes don't need a rebuild, only new symlink entries do.
  - `home/AGENTS.md` is fanned out to Claude/Codex/opencode as a shared agent-instructions file (currently a placeholder — fill in with personal preferences).
  - `~/.config/herdr` is wired up the same way, symlinked to `home/.config/herdr` (config cloned from kunchenguid/dotfiles); its runtime artifacts (`*.log`, `session.json`, `*.sock`) are gitignored.

## Package source: nix pkgs vs Homebrew

- **nix pkgs** (`home.packages` in `home.nix`) for CLI tools, language toolchains, libraries — reproducible and pinned.
- **Homebrew** (`homebrew.casks`/`homebrew.brews` in `configuration.nix`) for GUI apps and anything needing deep macOS integration — nixpkgs' Darwin GUI packaging is often unsigned/unnotarized and fights Gatekeeper. Mac App Store apps go through `mas`.
- Don't install the same tool from both — causes PATH conflicts. Remember `onActivation.cleanup = "zap"` will remove any Homebrew package not declared in `configuration.nix`.

## Agent skills

### Issue tracker

Issues live as GitHub Issues on `trungnguyenv/dotfiles`, managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (`CONTEXT.md` + `docs/adr/` at the repo root, created lazily). See `docs/agents/domain.md`.
