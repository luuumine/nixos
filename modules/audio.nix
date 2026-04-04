{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.audio;
  userName = config.lumine.user.name;
in
{
  options.lumine.audio.enable = lib.mkEnableOption "audio";

  config = lib.mkIf cfg.enable {

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        easyeffects
        pavucontrol
        playerctl
        tenacity
      ];
    };
  };
}
