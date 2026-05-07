{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.fonts;
in
{
  options.lumine.fonts = {
    enable = lib.mkEnableOption "system fonts";
  };
  config = lib.mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;
    };
    fonts.packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK"
        ];
        sansSerif = [
          "Inter"
          "Noto Sans CJK"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK"
        ];
      };
    };
  };
}
