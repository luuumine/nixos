{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop.hyprland;
  userName = config.lumine.user.name;
  displays = config.lumine.system.displays;

  renderDisplay =
    d:
    "monitor = ${d.output}, ${d.mode}, ${d.position}, ${toString d.scale}"
    + lib.optionalString (d.bitdepth != 8) ", bitdepth, ${toString d.bitdepth}"
    + lib.optionalString (d.transform != 0) ", transform, ${toString d.transform}";

  monitorsConf = lib.concatStringsSep "\n" (
    (map renderDisplay displays) ++ [ "monitor = , preferred, auto, auto" ]
  );
in
{
  options.lumine.desktop.hyprland.enable = lib.mkEnableOption "hyprland compositor";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            outputs = map (d: d.output) displays;
          in
          builtins.length outputs == builtins.length (lib.unique outputs);
        message = "lumine.system.displays contains duplicate outputs names";
      }
    ];

    home-manager.users.${userName} = {
      wayland.windowManager.hyprland.enable = true;
      home.packages = [ pkgs.wl-clipboard ];

      xdg.configFile = {
        # loader
        "hypr/hyprland.conf".source = ./hyprland.conf;

        # sources files
        "hypr/hyprland/vars.conf".source = ./vars.conf;
        "hypr/hyprland/env.conf".source = ./env.conf;
        "hypr/hyprland/input.conf".source = ./input.conf;
        "hypr/hyprland/appearance.conf".source = ./appearance.conf;
        "hypr/hyprland/rules.conf".source = ./rules.conf;
        "hypr/hyprland/keybinds.conf".source = ./keybinds.conf;
        "hypr/hyprland/startup.conf".source = ./startup.conf;

        # generated
        "hypr/hyprland/monitors.conf".text = monitorsConf;
      };
    };
  };
}
