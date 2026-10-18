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

  # Mac App Store apps (needs App Store sign-in; `mas` is the CLI that installs them).
  # Removing an entry does NOT uninstall the app - Homebrew cleanup never removes
  # App Store apps.
  homebrew.brews = [ "mas" ];
  homebrew.masApps = {
    "Notability" = 360593530;
    "Muse from Meta" = 6760173601;
  };

  # MATLAB has no Homebrew cask; install it manually with the MathWorks installer.
  # Homebrew cleanup never touches manually installed apps.
}
