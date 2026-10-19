{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
    let
      # Light base shared by every profile; extraModules layer more on top.
      mkMac = user: extraModules: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Existing ~/.zshrc etc. get renamed to *.before-home-manager instead of blocking.
            home-manager.backupFileExtension = "before-home-manager";
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = import ./home.nix;
          }
        ] ++ extraModules;
      };

      # Each Mac's configs are named after its macOS username, so rebuild.sh
      # can pick the right one with `whoami`.
      forUser = user: {
        ${user} = mkMac user [ ];
        "${user}-full" = mkMac user [ ./full.nix ];
      };
    in
    {
      darwinConfigurations =
        forUser "jaden"             # desktop
        // forUser "jadenbehringer"; # laptop
    };
}
