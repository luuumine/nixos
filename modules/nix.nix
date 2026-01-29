{ ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    use-xdg-base-directories = true;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.shellAliases = {
    cleanup = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
  };
}
