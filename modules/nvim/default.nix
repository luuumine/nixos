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
    home-manager.users.${userName} = {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        withRuby = false;
        withPython3 = false;

        plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
      };

      home.packages = with pkgs; [
        ripgrep
        fd
        gcc
        gnumake
        tree-sitter

        nixd
        nixfmt
        lua-language-server
        stylua
      ];

      xdg.configFile = {
        "nvim/init.lua".source = ./init.lua;
        "nvim/lua".source = ./lua;
      };
    };
  };
}
