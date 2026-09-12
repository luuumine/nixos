{
  lib,
  rustPlatform,
  cargo,
  rustc,
  rust-analyzer,
  rustfmt,
}:
let
  pname = "photon";
  version = "1.0.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
    ];
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-UVsYemSToPZ0OdQe5/0CdH/OYxXRfnkpNCBdbEE1AUs=";

  nativeBuildInputs = [
    cargo
    rustc
    rust-analyzer
    rustfmt
  ];

  meta = {
    mainProgram = pname;
  };
}
