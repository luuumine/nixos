{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.desktop;
  gpu = config.lumine.system.gpuBrand;
in
{
  imports = [
    ./hyprpaper.nix
    ./hyprshot.nix
    ./quickshell.nix
    ./terminal.nix
  ];

  options.lumine.desktop.enable = lib.mkEnableOption "desktop environment and graphics";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = gpu != "nvidia";
            message = "nvidia graphics are not yet supported in lumine.desktop. please use \"amd\" or \"intel\".";
          }
          {
            assertion = gpu != "none";
            message = "lumine.desktop is enabled but lumine.system.gpuBrand is set to \"none\". please specify a gpu.";
          }
        ];
      }
      {
        lumine.desktop.hyprpaper.enable = lib.mkDefault true;
        lumine.desktop.hyprshot.enable = lib.mkDefault true;
        lumine.desktop.quickshell.enable = lib.mkDefault true;
        lumine.desktop.terminal.enable = lib.mkDefault true;
      }
      {
        programs.hyprland.enable = true;

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        systemd.user.targets.hyprland-session = {
          description = "Hyprland compositor session";
          documentation = [ "man:systemd.special(7)" ];
          bindsTo = [ "graphical-session.target" ];
          wants = [ "graphical-session-pre.target" ];
          after = [ "graphical-session-pre.target" ];
        };
      }

      (lib.mkIf (gpu == "amd") {
        services.xserver.videoDrivers = [ "amdgpu" ];
        environment.systemPackages = [
          pkgs.rocmPackages.amdsmi
          pkgs.libdrm
        ];
      })

      (lib.mkIf (gpu == "intel") {
        services.xserver.videoDrivers = [ "modesetting" ];
        environment.systemPackages = [
          pkgs.intel-cpu-tools
        ];
      })
    ]
  );
}
