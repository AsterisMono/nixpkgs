{
  rustPlatform,
  lib,
  fetchFromGitHub,
  pkg-config,
  webkitgtk_4_0,
  openssl,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  gtk3,
  wrapGAppsHook3,
  cargo-tauri_1,
  librsvg,
  libappindicator-gtk3,
}:

rustPlatform.buildRustPackage rec {
  pname = "alexandria";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "btpf";
    repo = "Alexandria";
    tag = "v${version}";
    hash = "sha256-18i3/HLTfhBSa9/c55dCOfFal+V40wcHcLoYt1dU+d0=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-6r9bEY7e1Eef/0/CJ26ITpFJcCVUEKLrFx+TNEomLPE=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  cargoHash = "sha256-VX/G4dF9DhlGfifp4xf9xkXli7BHFtKY2+HaMHqqPiA=";

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  nativeBuildInputs = [
    cargo-tauri_1.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    webkitgtk_4_0
    gtk3
    librsvg
    libappindicator-gtk3
  ];

  meta = {
    homepage = "https://github.com/btpf/Alexandria";
    changelog = "https://github.com/btpf/Alexandria/releases/tag/v${version}";
    description = "Minimalistic cross-platform eBook reader";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    mainProgram = "alexandria";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    license = lib.licenses.gpl3Plus;
  };
}
