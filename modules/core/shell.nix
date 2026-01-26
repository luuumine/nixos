{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.zsh = {
    enable = true;

    # History settings
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      share = true;
      findNoDups = true;
      ignoreAllDups = true;
    };

    # Plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases
    shellAliases = {
      # Default eza overrides
      ls = "eza";
      la = "eza -a";
      ll = "eza -l";
      lla = "eza -la";

      # Tree views
      lt = "eza --tree";
      lta = "eza --tree -a --ignore-glob='**/.git'";

      # Nix develop
      nd = "nix develop";
    };

    initContent = ''
      # Basic Zsh behaviors
      setopt autocd
      setopt correct

      # Binds
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H'      backward-kill-word
      bindkey '^ '      autosuggest-accept

      # Redirect nix develop to zsh
      nix() {
        if [[ $1 = "develop" ]]; then
          shift
          command nix develop -c zsh "$@"
        else
          command nix "$@"
        fi
      }
    '';
  };

  home.packages = with pkgs; [
    wl-clipboard
  ];
}
