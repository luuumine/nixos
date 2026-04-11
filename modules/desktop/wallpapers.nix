{ pkgs }:

let
  lib = pkgs.lib;
  baseUrl = "https://luuumine.com/wallpapers";

  wallpaperData = [
    {
      name = "isla-1";
      sha256 = "YTlPpnAZQwbJ4qu3qXRTMqB+CIvii/4zQJimC5ldl0g=";
    }
    {
      name = "isla-1-logoless";
      sha256 = "FqwxE/gdf5ZmaoFhXPDqTimcaq71LlRGNw8qEbb5TnM=";
    }
    {
      name = "isla-2-figure";
      sha256 = "BJJHGV0GUGgvWKlptN11PJiUFvML/FA+76VKUbxATGU=";
    }
    {
      name = "nix-catppuccin-mocha";
      sha256 = "zlYqSid5Q1L5sUrAcvR+7aN2jImiuoR9gygBRk8x9Wo=";
    }
  ];
in
builtins.listToAttrs (
  map (
    data:
    lib.nameValuePair data.name (
      pkgs.fetchurl {
        name = "${data.name}.png";
        url = "${baseUrl}/${data.name}.png";
        sha256 = data.sha256;
      }
    )
  ) wallpaperData
)
