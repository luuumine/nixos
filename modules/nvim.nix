{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.nvim;
  userName = config.lumine.user.name;
in
{
  options.lumine.nvim = {
    enable = lib.mkEnableOption "nvim";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        ripgrep
        fd
        gcc
        gnumake
        tree-sitter
      ];

      xdg.configFile."nvim/parser".source =
        let
          parsers = pkgs.symlinkJoin {
            name = "treesitter-parsers";
            paths = (pkgs.vimPlugins.nvim-treesitter.withAllGrammars).dependencies;
          };
        in
        "${parsers}/parser";
    };

  };
}
