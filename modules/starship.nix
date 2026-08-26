{
  config,
  lib,
  ...
}:

let
  cfg = config.lumine.starship;
  userName = config.lumine.user.name;
  langList = [
    "nix_shell"
    "c"
    "golang"
    "java"
    "lua"
    "nodejs"
    "python"
    "rust"
    "docker_context"
  ];
  allLangs = lib.concatMapStrings (lang: "$" + lang) langList;
in
{
  options.lumine.starship = {
    enable = lib.mkEnableOption "starship";

    theme = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "bold blue";
        description = "style string for the username";
      };
      symbol = lib.mkOption {
        type = lib.types.str;
        default = "bold white";
        description = "style string for the symbol";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "bold blue";
        description = "style string for the hostname";
      };
      directory = lib.mkOption {
        type = lib.types.str;
        default = "bold cyan";
        description = "style string for the directory path";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;

        settings = {
          command_timeout = 500;
          scan_timeout = 30;

          format = ''
            $username[@](${cfg.theme.symbol})$hostname: $directory$git_branch$git_commit$git_status${allLangs}
            $character
          '';

          add_newline = true;

          nix_shell = {
            symbol = "❄️ ";
            format = "via [$symbol$name]($style) ";
            impure_msg = "";
            pure_msg = "";
            style = "bold blue";
          };

          username = {
            show_always = true;
            format = "[$user]($style)";
            style_user = cfg.theme.username;
          };

          hostname = {
            ssh_only = false;
            format = "[$hostname]($style)";
            style = cfg.theme.hostname;
          };

          directory = {
            truncate_to_repo = true;
            truncation_length = 3;
            format = "[$path]($style) ";
            style = cfg.theme.directory;
          };

          git_branch = {
            symbol = "";
            format = "on [$branch]($style) ";
            style = "bold purple";
          };

          git_commit = {
            commit_hash_length = 7;
            only_detached = true;
            format = "at [$hash]($style) ";
            style = "bright-black";
          };

          git_status = {
            format = "([\\[$all_status$ahead_behind\\]]($style) )";
            style = "bold red";

            # Numbers
            staged = "[+$count](green)";
            modified = "[~$count](yellow)";
            deleted = "[-$count](red)";
            untracked = "[?$count](purple)";
            renamed = "[r$count](cyan)";

            # Sync status
            ahead = "⇡$count";
            behind = "⇣$count";
            diverged = "⇕⇡$ahead_count⇣$behind_count";
          };

          character = {
            success_symbol = "[>](bold green) ";
            error_symbol = "[>](bold red) ";
          };
        };
      };
    };
  };
}
