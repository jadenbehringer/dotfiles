# Full profile: everything in configuration.nix plus these apps.
# Applied with `./rebuild.sh full`. Switching back to light zaps these
# (uninstalls them AND deletes their ~/Library data).
{
  homebrew.casks = [
    "obsidian"
    "claude"              # Claude desktop app (claude-code is the CLI, in the base)
    "google-chrome"
    "notion"
    "antigravity"
    "visual-studio-code"
    "cursor"
  ];
  # MATLAB has no Homebrew cask; install it manually with the MathWorks installer.
  # Homebrew cleanup never touches manually installed apps.
}
