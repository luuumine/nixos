{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.gaming.minecraft;
  userName = config.lumine.user.name;
in
{
  options.lumine.gaming.minecraft.enable = lib.mkEnableOption "minecraft";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      home.packages = [
        (pkgs.prismlauncher.override {
          jdks = [
            pkgs.temurin-bin-25
          ];
        })
      ];
    };
  };
}
