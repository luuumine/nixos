{ lib }:

lib.types.submodule {
  options = {
    difficulty = lib.mkOption {
      type = lib.types.enum [
        "peaceful"
        "easy"
        "normal"
        "hard"
      ];
      default = "easy";
      description = "difficulty of the server";
    };

    "enforce-whitelist" = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to enforce changes to the whitelist";
    };

    gamemode = lib.mkOption {
      type = lib.types.enum [
        "survival"
        "creative"
        "adventure"
        "spectator"
      ];
      default = "survival";
      description = "default game mode";
    };

    "generate-structures" = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether structures are generated";
    };

    hardcore = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to enable hardcore mode on created worlds";
    };

    "level-name" = lib.mkOption {
      type = lib.types.str;
      default = "world";
      description = "world name and directory path";
    };

    "level-seed" = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "seed for the generated world";
    };

    "level-type" = lib.mkOption {
      type = lib.types.str;
      default = "minecraft:normal";
      description = "preset for the generated world";
    };

    "max-players" = lib.mkOption {
      type = lib.types.int;
      default = 20;
      description = "maximum number of players";
    };

    "max-world-size" = lib.mkOption {
      type = lib.types.int;
      default = 29999984;
      description = "amount of blocks from the center of the world where the border appears";
    };

    motd = lib.mkOption {
      type = lib.types.str;
      default = "A Minecraft Server";
      description = "message of the day displayed in the server list";
    };

    "pause-when-empty-seconds" = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "seconds after no player has been online before the server is paused";
    };

    "player-idle-timeout" = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "minutes before an idle player is kicked";
    };

    "server-port" = lib.mkOption {
      type = lib.types.port;
      default = 25565;
      description = "tcp port number the server listens on";
    };

    "simulation-distance" = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "maximum distance from players that living entities are updated";
    };

    "spawn-protection" = lib.mkOption {
      type = lib.types.int;
      default = 16;
      description = "side length of the square spawn protection area";
    };

    "view-distance" = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "amount of world data the server sends the client in chunks";
    };

    "white-list" = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether the whitelist is enabled";
    };
  };
}
