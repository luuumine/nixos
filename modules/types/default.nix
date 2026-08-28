{ lib }:

{
  display = import ./display.nix { inherit lib; };
  gpu = import ./gpu.nix { inherit lib; };
  minecraft = import ./minecraft.nix { inherit lib; };
}
