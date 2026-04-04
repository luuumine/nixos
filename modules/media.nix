{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.media;
  userName = config.lumine.user.name;
in
{
  options.lumine.media = {
    enable = lib.mkEnableOption "media tools";

    images.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "image tools";
    };
    video.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "videos tools";
    };
  };

  config = {
    home-manager.users.${userName} = lib.mkMerge [
      # Image tools
      (lib.mkIf cfg.images.enable {
        home.packages = [
          pkgs.chafa
          pkgs.imv
          pkgs.krita
        ];
      })
      # Video tools
      (lib.mkIf cfg.video.enable {
        home.packages = [
          pkgs.ffmpeg-full
          pkgs.mkvtoolnix
          pkgs.mpv
        ];
      })
    ];
  };
}
