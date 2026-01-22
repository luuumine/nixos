{ pkgs, lib, ... }:

let
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
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      command_timeout = 500;
      scan_timeout = 30;

      format = ''
        $username@$hostname: $directory$git_branch$git_commit$git_status${allLangs}
        $character
      '';

      add_newline = true;

      username = {
        show_always = true;
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
      };

      directory = {
        truncate_to_repo = true;
        truncation_length = 3;
        format = "[$path]($style) ";
      };

      git_branch = {
        symbol = "";
        format = "on [$branch]($style) ";
      };

      git_commit = {
        commit_hash_length = 7;
        only_detached = false;
        format = "at [$hash]($style) ";
        style = "italic grey";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold red";

        # Numbers
        staged = "[+$count](green)";
        modified = "[~$count](yellow)";
        deleted = "[-$count](red)";
        untracked = "[?$count](magenta)";
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
}
