#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# Configs are named after the macOS user (see forUser in flake.nix).
# ./rebuild.sh        -> light profile (#<user>)
# ./rebuild.sh full   -> full profile  (#<user>-full)
USER_NAME="$(whoami)"
case "${1:-light}" in
  light) HOST="$USER_NAME" ;;
  full)  HOST="$USER_NAME-full" ;;
  *) echo "usage: $0 [light|full]" >&2; exit 1 ;;
esac

# Homebrew .pkg casks (e.g. Office, MacTeX) call sudo mid-run, and every brew
# command clears the cached sudo login, so expect Touch ID prompts during the
# rebuild (see security.pam in configuration.nix). The first run on a new Mac,
# before Touch ID for sudo is set up, asks for the password instead.

# First run on a new Mac: darwin-rebuild isn't installed yet, so run it from nix-darwin.
# Check the installed path, not PATH: a shell opened before nix-darwin's first
# activation lacks /run/current-system/sw/bin and would needlessly take this branch.
DARWIN_REBUILD=/run/current-system/sw/bin/darwin-rebuild
if [ -x "$DARWIN_REBUILD" ]; then
  sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#"$HOST"
else
  sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/.dotfiles#"$HOST"
fi
