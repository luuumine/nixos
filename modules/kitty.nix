{ pkgs, ... }:

{
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

}
