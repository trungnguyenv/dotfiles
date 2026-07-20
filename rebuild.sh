#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -e "$HOME/.dotfiles" ]; then
  ln -s "$REPO_DIR" "$HOME/.dotfiles"
fi

exec sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.dotfiles#mac


