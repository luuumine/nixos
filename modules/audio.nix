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
  options.lumine.audio = {
    enable = lib.mkEnableOption "audio";
    loopback.enable = lib.mkEnableOption "microphone loopback";
  };

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
        pulseaudio
        tenacity
      ];

      systemd.user.services.mic-loopback = {
        Unit = {
          Description = "microphone loopback";
          After = [ "pipewire-pulse.service" ];
          Wants = [ "pipewire-pulse.service" ];
          PartOf = [ "pipewire-pulse.service" ];
        };
        Install = {
          WantedBy = lib.mkIf cfg.loopback.enable [ "default.target" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.pulseaudio}/bin/pactl load-module module-loopback latency_msec=1";
          ExecStop = "${pkgs.pulseaudio}/bin/pactl unload-module module-loopback";
        };
      };
    };
  };
}
