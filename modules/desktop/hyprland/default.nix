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
  monitorsConf = (import ./monitors.nix { inherit lib; }) displays;
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

    programs.hyprland.enable = true;

    home-manager.users.${userName} = {
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        systemd.enable = true;
        extraConfig = "# Supress HM warning";
      };

      home.packages = [ pkgs.wl-clipboard ];

      xdg.configFile =
        let
          staticLuaFiles = [
            ./vars.lua
            ./env.lua
            ./input.lua
            ./appearance.lua
            ./rules.lua
            ./keybinds.lua
            ./startup.lua
          ];

          mappedFiles = builtins.listToAttrs (
            map (file: {
              name = "hypr/hyprland/${lib.baseNameOf file}";
              value = {
                source = file;
              };
            }) staticLuaFiles
          );
        in
        mappedFiles
        // {
          "hypr/hyprland.lua".source = ./hyprland.lua;

          "hypr/hyprland/monitors.lua".text = monitorsConf;
        };
    };
  };
}
