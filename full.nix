# Full profile: everything in configuration.nix plus these apps.
# Applied with `./rebuild.sh full`. Switching back to light zaps the casks
# (uninstalls them AND deletes their ~/Library data).
{
  homebrew.casks = [
    "obsidian"
    "claude"              # Claude desktop app (claude-code is the CLI, in the base)
    "notion"
    "antigravity"
    "visual-studio-code"
    "cursor"
    "microsoft-excel"
    "microsoft-word"
    "microsoft-powerpoint"
    "canva"
    "orcaslicer"
    "arduino-ide"
    "figma"
    "telegram"            # native macOS client (not "telegram-desktop")
  ];

  # Manual installs (no cask; Homebrew cleanup never touches these):
  # - MATLAB: MathWorks installer (TAMU license)
  # - Muse from Meta: https://ai.meta.com/muse/download/ (Mac App Store listing is iPhone/iPad only)
  # - Notability: Mac App Store (masApps fails during darwin-rebuild, nix-darwin#1694)
}
