{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.gaming;
in
{
  imports = [
    ./minecraft.nix
    ./steam.nix
  ];

  options.lumine.gaming.enable = lib.mkEnableOption "gaming utilities";

  config = lib.mkIf cfg.enable {
    programs.gamemode.enable = true;

    environment.systemPackages = [ pkgs.mangohud ];
  };
}
