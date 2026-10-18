#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# ./rebuild.sh        -> light profile (#mac)
# ./rebuild.sh full   -> full profile  (#mac-full)
case "${1:-light}" in
  light) HOST="mac" ;;
  full)  HOST="mac-full" ;;
  *) echo "usage: $0 [light|full]" >&2; exit 1 ;;
esac

# Homebrew .pkg casks (e.g. Microsoft Office) and `mas install` call sudo
# themselves mid-run, without a TTY to prompt on. Authenticate once up front
# and refresh the timestamp until the rebuild exits, so long downloads don't
# outlive sudo's 5-minute credential cache.
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
KEEPALIVE=$!
trap 'kill "$KEEPALIVE" 2>/dev/null' EXIT

sudo darwin-rebuild switch --flake ~/.dotfiles#"$HOST"
