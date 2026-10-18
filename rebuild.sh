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
exec sudo darwin-rebuild switch --flake ~/.dotfiles#"$HOST"
