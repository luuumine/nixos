{ lib }:

displays:
let
  renderDisplay =
    d:
    let
      monitorArgs = {
        inherit (d) output;
        inherit (d) mode;
        inherit (d) position;
        inherit (d) scale;
      }
      // lib.optionalAttrs (d.bitdepth != 8) { inherit (d) bitdepth; }
      // lib.optionalAttrs (d.transform != 0) { inherit (d) transform; };
    in
    "hl.monitor(${lib.generators.toLua { } monitorArgs})";
in
lib.concatStringsSep "\n" (
  (map renderDisplay displays)
  ++ [ "hl.monitor({ output = \"\", mode = \"preferred\", position = \"auto\", scale = \"auto\" })" ]
)
