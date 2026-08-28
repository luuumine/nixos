{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.minecraft;
  types = import ../types { inherit lib; };

  userName = config.lumine.user.name;

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (
    "# server.properties managed by lumine nix configuration\n"
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: v: "${n}=${cfgToString v}") cfg.serverProperties
    )
  );

  whitelistFile = pkgs.writeText "whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (n: v: {
        name = n;
        uuid = v;
      }) cfg.whitelist
    )
  );

  eulaFile = builtins.toFile "eula.txt" "eula=true";

  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > /run/minecraft-server.stdin
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';
in
{
  options.lumine.services.minecraft = {
    enable = lib.mkEnableOption "lumine minecraft server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.minecraft-server;
      description = "minecraft server package to use";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/minecraft";
      description = "directory to store minecraft world and data files";
    };

    maxRam = lib.mkOption {
      type = lib.types.str;
      default = "5G";
      description = "max ram for the jvm (e.g. 5g)";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether to open the port in the firewall automatically";
    };

    serverProperties = lib.mkOption {
      type = types.minecraft;
      default = { };
      description = "server properties for the minecraft server";
    };

    whitelist = lib.mkOption {
      type =
        let
          uuid = lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
        in
        lib.types.attrsOf uuid;
      default = { };
      description = "mapping of usernames to uuids for the whitelist";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.minecraft = {
      description = "minecraft server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "minecraft";
    };
    users.groups.minecraft.members = [ userName ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mc" ''
        if [ -z "$1" ]; then
          echo "usage: mc <command>"
          exit 1
        fi
        echo "$*" > /run/minecraft-server.stdin
      '')
    ];

    systemd.sockets.minecraft-server = {
      bindsTo = [ "minecraft-server.service" ];
      socketConfig = {
        ListenFIFO = "/run/minecraft-server.stdin";
        SocketMode = "0660";
        SocketUser = "minecraft";
        SocketGroup = "minecraft";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };

    systemd.services.minecraft-server = {
      description = "Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "minecraft-server.socket" ];
      after = [
        "network.target"
        "minecraft-server.socket"
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/minecraft-server -Xms${cfg.maxRam} -Xmx${cfg.maxRam}";
        ExecStop = "${stopScript} $MAINPID";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = cfg.dataDir;

        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      preStart = ''
        ln -sf ${eulaFile} eula.txt
        ln -sf ${whitelistFile} whitelist.json

        cp -f ${serverPropertiesFile} server.properties
        chmod +w server.properties
      '';
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.serverProperties."server-port" ];
      allowedUDPPorts = [ cfg.serverProperties."server-port" ];
    };
  };
}
