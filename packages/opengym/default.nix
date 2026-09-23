{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  nodejs-slim,
  pkg-config,
  vips,
  python3,
}:
let
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "DuarteSantos8";
    repo = "openGym";
    rev = "main";
    hash = "sha256-/8+lGPEXRcn2/BIUC7uyJkn3iYrr4xJRWOp+e7V3VaE=";
  };

  media = stdenv.mkDerivation {
    pname = "opengym-media";
    inherit version;
    src = fetchFromGitHub {
      owner = "hasaneyldrm";
      repo = "exercises-dataset";
      rev = "master";
      hash = "sha256-bAit6zzd1Q1SPgb3ydjuZN78yXjRcgcIs+hH4gKNaxE=";
    };
    installPhase = ''
      mkdir -p $out/img $out/gif
      cp images/*.jpg $out/img/
      cp videos/*.gif $out/gif/
    '';
  };

  frontend = buildNpmPackage {
    pname = "opengym-web";
    inherit version src;

    sourceRoot = "${src.name}/frontend";
    npmDepsHash = "sha256-LZKOsep2myfbMnqfH19D7wHH1yJINlSooz5gGoo8hNk=";

    makeCacheWritable = true;

    nativeBuildInputs = [
      pkg-config
      python3
    ];
    buildInputs = [ vips ];

    buildPhase = ''
      npm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -R dist/* $out/
    '';
  };
in
buildNpmPackage {
  pname = "opengym";
  inherit version src;

  sourceRoot = "${src.name}/api";
  npmDepsHash = "sha256-17sKhtFSCOYBXuqFyhMsAehDLYDsmkG9FcFct+tsqEw=";

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  installPhase = ''
    mkdir -p $out/lib/opengym $out/bin
    cp -r . $out/lib/opengym/

    makeWrapper ${nodejs-slim}/bin/node $out/bin/opengym \
      --add-flags "$out/lib/opengym/server.js" \
      --set NODE_ENV production
  '';

  passthru = {
    inherit frontend media;
  };

  meta = {
    description = "Self-hosted workout tracker";
    homepage = "https://github.com/DuarteSantos8/openGym";
    mainProgram = "opengym";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ luuumine ];
    platforms = lib.platforms.linux;
  };
}
