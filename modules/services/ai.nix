{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lumine.services.ai;
  caddyCfg = config.lumine.network.caddy;
  types = import ../types { inherit lib; };
in
{
  options.lumine.services.ai = {
    enable = lib.mkEnableOption "llama.cpp ai server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1337;
      description = "port for the llama-server api.";
    };

    model = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.str;
      description = "path to the gguf model, or a fetchurl derivation";
    };

    gpu = lib.mkOption {
      type = lib.types.nullOr types.gpu;
      default = null;
      description = "gpu to use for acceleration";
    };

    contextSize = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "kv cache context size in tokens (0 = loaded from model)";
    };

    parallelSessions = lib.mkOption {
      type = lib.types.int;
      default = -1;
      description = "number of parallel sessions (-1 = auto)";
    };

    gpuLayers = lib.mkOption {
      type = lib.types.either lib.types.int (
        lib.types.enum [
          "auto"
          "all"
        ]
      );
      default = "auto";
      example = "all";
      description = "number of layers to offload to gpu ('auto', 'all', or integer)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;

      package =
        if cfg.gpu != null && cfg.gpu.brand == "nvidia" then
          pkgs.llama-cpp.override { cudaSupport = true; }
        else if cfg.gpu != null && cfg.gpu.brand == "amd" then
          pkgs.llama-cpp.override { rocmSupport = true; }
        else
          pkgs.llama-cpp;

      settings = {
        host = "127.0.0.1";
        inherit (cfg) port;
        inherit (cfg) model;
        ctx-size = cfg.contextSize;
        parallel = cfg.parallelSessions;
        n-gpu-layers = cfg.gpuLayers;
      };
    };

    systemd.services.llama-cpp.environment = lib.mkIf (cfg.gpu != null && cfg.gpu.brand == "nvidia") {
      CUDA_VISIBLE_DEVICES = "0";
    };

    services.caddy = lib.mkIf caddyCfg.enable {
      virtualHosts."http://ai.vpn.luuumine.com, http://ai" = {
        extraConfig = ''
          bind tailscale/ai
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };
}
