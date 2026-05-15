{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.nix;
  userName = config.lumine.user.name;
in
{
  options.lumine.nix = {
    enable = lib.mkEnableOption "core nix and nixos settings";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      use-xdg-base-directories = true;
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    nixpkgs.config.allowUnfree = true;

    environment.shellAliases = {
      cleanup = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
    };

    home-manager.users.${userName} = {
      home.packages = [
        pkgs.nixd
        pkgs.nixfmt
      ];
    };
  };
}
