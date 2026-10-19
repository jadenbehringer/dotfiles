{ config, lib, user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  # Touch ID for sudo, including the prompts Homebrew casks raise mid-rebuild.
  # reattach makes it work inside tmux/herdr; falls back to password over SSH.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # nix-darwin's shell init replaces macOS's path_helper, which is how installers
  # (MacTeX, Wireshark, Go, .NET, ...) put their dirs on PATH/MANPATH. Re-add
  # /etc/paths(.d) and /etc/manpaths(.d) entries, appended so Nix and Homebrew win.
  # Runs in zsh too, so use find instead of a glob (an empty dir would error).
  environment.extraInit = ''
    for __f in /etc/paths $(/usr/bin/find /etc/paths.d -type f 2>/dev/null | /usr/bin/sort); do
      [ -f "$__f" ] || continue
      while IFS= read -r __d || [ -n "$__d" ]; do
        case ":$PATH:" in *":$__d:"*) ;; *) [ -n "$__d" ] && PATH="$PATH:$__d" ;; esac
      done < "$__f"
    done
    for __f in /etc/manpaths $(/usr/bin/find /etc/manpaths.d -type f 2>/dev/null | /usr/bin/sort); do
      [ -f "$__f" ] || continue
      while IFS= read -r __d || [ -n "$__d" ]; do
        # Leading ":" keeps man's default search path.
        case ":$MANPATH:" in *":$__d:"*) ;; *) [ -n "$__d" ] && MANPATH="$MANPATH:$__d" ;; esac
      done < "$__f"
    done
    export PATH MANPATH
    unset __f __d
  '';

  # Xcode Command Line Tools (compilers, git, make). Homebrew needs them, and
  # there's no package for them, so ask macOS to open its installer if missing.
  system.activationScripts.postActivation.text = ''
    if ! xcode-select -p >/dev/null 2>&1; then
      echo "Xcode Command Line Tools missing; opening the installer..."
      xcode-select --install || true
    fi
  '';

  # Homebrew won't load formulae from third-party taps until they're trusted,
  # so trust every tap-qualified brew below before `brew bundle` runs.
  system.activationScripts.preActivation.text =
    let
      thirdParty = builtins.filter (lib.hasInfix "/")
        (map (b: b.name) config.homebrew.brews);
    in ''
      if [ -x /opt/homebrew/bin/brew ]; then
        sudo -H -u ${user} /opt/homebrew/bin/brew trust --formula ${lib.concatStringsSep " " thirdParty} >/dev/null
      fi
    '';

  nix-homebrew = {
    enable = true;
    inherit user;
    # Take over the existing /opt/homebrew install (keeps installed packages).
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "can1357/tap"    # omp
      "supabase/tap"
      "heroku/brew"
    ];
    brews = [
      "herdr"
      "git"
      "fnm"  # Node version manager; provides node/npm
      "gh"   # GitHub CLI
      "pnpm"
      "yarn"
      "uv"   # Python versions, venvs, and tools
      "tmux"
      "tree"
      "watchman"
      "can1357/tap/omp"
      "supabase/tap/supabase"
      "firebase-cli"
      "eas-cli"  # Expo builds
      "heroku/brew/heroku"
      "rbenv"    # Ruby version manager (CocoaPods, Ruby projects)
      "postgresql@14"
      "postgresql@17"
      "cmake"
      "cppcheck" # C/C++ static analysis
      "cgdb"     # terminal debugger
      "graphviz"
      "imagemagick"
      "xcodegen"
    ];
    casks = [
      "gcloud-cli"
      "temurin@25"       # Java 25 JDK
      "wezterm@nightly"  # conflicts with "wezterm"; keep only one
      "claude-code"
      "font-hack-nerd-font"
      "google-chrome"
      "tailscale-app"    # Tailscale GUI + CLI (the old "tailscale" cask was renamed to this)
    ];
  };
}
