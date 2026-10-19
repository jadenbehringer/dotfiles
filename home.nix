{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    OPENSSL_ROOT_DIR = "/opt/homebrew/opt/openssl@3";  # lets CMake find Homebrew's OpenSSL
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    # Login shells: put Homebrew on PATH (~/.zprofile).
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept

      export PATH="$PATH:$HOME/.local/bin"

      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --shell zsh)"
      fi

      if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
      fi
    '';
    shellAliases = {
      ".." = "cd ..";
      b = "cd ..";
      bb = "cd ../..";
      bbb = "cd ../../..";
      bbbb = "cd ../../../..";
      ll = "ls -la";
      lll = "ls -lha";
      nd = "nano";
      sz = "source ~/.zshrc";
      nz = "nano ~/.dotfiles/home.nix";  # ~/.zshrc is generated from home.nix
      add = "git add .";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      walk = "sudo pmset -b disablesleep 1";    # stay awake on battery (lid closed)
      arrive = "sudo pmset -b disablesleep 0";  # undo walk
      work = "caffeinate -is tmux new -A -s work";
      omp-opus = "omp --profile opus";
      omp-kimi = "omp --profile kimi";
      omp-spark = "omp --profile spark";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;  # installs git-lfs and its filters (same as `git lfs install`)
    settings.user = {
      name = "jadenbehringer";
      email = "jaden.behringer@tamu.edu";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real files live in this repo, ~/.config just points at them.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # omp: only the config files; ~/.omp also holds dbs, sessions, and auth.
  home.file.".omp/agent/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.omp/agent/config.yml";
  home.file.".omp/profiles/opus/agent/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.omp/profiles/opus/agent/config.yml";
  home.file.".omp/profiles/kimi/agent/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.omp/profiles/kimi/agent/config.yml";
  home.file.".omp/profiles/spark/agent/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.omp/profiles/spark/agent/config.yml";

  # One agent instruction file shared by Claude and Codex.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
