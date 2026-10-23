# Full profile: everything in configuration.nix plus these apps.
# Applied with `./rebuild.sh full`. Switching back to light zaps the casks
# (uninstalls them AND deletes their ~/Library data).
{ user, ... }:

let
  # Installed on rebuild if missing; extensions you add in VS Code are left alone.
  vscodeExtensions = [
    "dart-code.dart-code"
    "dart-code.flutter"
    "docker.docker"
    "formulahendry.code-runner"
    "github.vscode-github-actions"
    "haskell.haskell"
    "haskell.language-haskell"
    "james-yu.latex-workshop"
    "ms-azuretools.vscode-containers"
    "ms-azuretools.vscode-docker"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-wsl"
    "ms-vscode-remote.vscode-remote-extensionpack"
    "ms-vscode.cmake-tools"
    "ms-vscode.cpp-devtools"
    "ms-vscode.cpptools"
    "ms-vscode.cpptools-extension-pack"
    "ms-vscode.cpptools-themes"
    "ms-vscode.remote-explorer"
    "ms-vscode.remote-server"
    "ms-vsliveshare.vsliveshare"
    "redhat.java"
    "vscjava.vscode-gradle"
    "vscjava.vscode-java-debug"
    "vscjava.vscode-java-dependency"
    "vscjava.vscode-java-pack"
    "vscjava.vscode-java-test"
    "vscjava.vscode-maven"
  ];
in

{
  homebrew.casks = [
    "obsidian"
    "claude"              # Claude desktop app (claude-code is the CLI, in the base)
    "notion"
    "antigravity"         # Antigravity 2 (agent app)
    "antigravity-ide"     # Antigravity IDE (editor); a separate product
    "visual-studio-code"
    "cursor"
    "microsoft-excel"
    "microsoft-word"
    "microsoft-powerpoint"
    "canva"
    "orcaslicer@nightly"  # nightly for Bambu A2L support (not in 2.4.x stable)
    "arduino-ide"
    "figma"
    "telegram"            # native macOS client (not "telegram-desktop")
    "discord"
    "zoom"
    "microsoft-teams"
    "onedrive"
    "google-drive"        # also installs the Docs/Sheets/Slides app shortcuts
    "granola"
    "wispr-flow"
    "iina"                # video player (mpv-based)
    "mactex"              # full TeX Live + TeXShop etc.; puts binaries in /Library/TeX/texbin
  ];

  # Manual installs (no cask; Homebrew cleanup never touches these):
  # - Xcode: Mac App Store (same masApps issue as Notability)
  # - MATLAB: MathWorks installer (TAMU license)
  # - Muse from Meta: https://ai.meta.com/muse/download/ (Mac App Store listing is iPhone/iPad only)
  # - Notability: Mac App Store (masApps fails during darwin-rebuild, nix-darwin#1694)

  # VS Code: edit-in-place user files (like ~/.config in home.nix), plus extensions.
  home-manager.users.${user} = { config, lib, ... }:
    let
      vscodeUser = "Library/Application Support/Code/User";
      link = f: config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/home/${vscodeUser}/${f}";
    in
    {
      home.file."${vscodeUser}/settings.json".source = link "settings.json";
      home.file."${vscodeUser}/tasks.json".source = link "tasks.json";
      home.file."${vscodeUser}/mcp.json".source = link "mcp.json";

      # Runs after the visual-studio-code cask: nix-darwin does `brew bundle` before
      # home-manager activation (postActivation), even on a fresh Mac.
      home.activation.vscodeExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        code=/opt/homebrew/bin/code
        installed="$("$code" --list-extensions | tr '[:upper:]' '[:lower:]')"
        for ext in ${lib.escapeShellArgs vscodeExtensions}; do
          if ! printf '%s\n' "$installed" | grep -qxF "$ext"; then
            run "$code" --install-extension "$ext"
          fi
        done
      '';
    };
}
