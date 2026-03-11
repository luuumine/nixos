{ pkgs, ... }:

{
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
}
