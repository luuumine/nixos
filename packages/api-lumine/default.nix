{
  rustPlatform,
  cargo,
  rustc,
  rust-analyzer,
  rustfmt,
  cacert,
}:
let
  pname = "api-lumine";
  version = "1.1.1";
  src = ./.;
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-J9BvVP7WzBS5AedrpEW2Y5NSEwjSS5sOy0/TeSE6k08=";

  nativeBuildInputs = [
    cargo
    rustc
    rust-analyzer
    rustfmt
    cacert
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    mainProgram = pname;
  };
}
