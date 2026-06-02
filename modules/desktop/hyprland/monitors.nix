{ lib }:

displays:
let
  renderDisplay =
    d:
    let
      monitorArgs = {
        output = d.output;
        mode = d.mode;
        position = d.position;
        scale = d.scale;
      }
      // lib.optionalAttrs (d.bitdepth != 8) { bitdepth = d.bitdepth; }
      // lib.optionalAttrs (d.transform != 0) { transform = d.transform; };
    in
    "hl.monitor(${lib.generators.toLua { } monitorArgs})";
in
lib.concatStringsSep "\n" (
  (map renderDisplay displays)
  ++ [ "hl.monitor({ output = \"\", mode = \"preferred\", position = \"auto\", scale = \"auto\" })" ]
)
