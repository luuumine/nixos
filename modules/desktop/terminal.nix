{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop.terminal;
  userName = config.lumine.user.name;
in
{
  options.lumine.desktop.terminal = {
    enable = lib.mkEnableOption "terminal";
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        btop-rocm
        fastfetch
        htop
        killall
        stow
        tree
      ];

      programs.kitty = {
        enable = true;

        themeFile = "Catppuccin-Mocha";

        settings = {
          font_size = 12;
          window_padding_width = 10;
          background_opacity = 0.9;
          confirm_os_window_close = 0;
        };
      };
    };
  };
}
