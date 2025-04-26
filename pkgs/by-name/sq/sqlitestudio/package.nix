{
  stdenv,
  lib,
  fetchFromGitHub,
  libsForQt5,
  readline,
  tcl,
  python3,
  copyDesktopItems,
  makeDesktopItem,
}:
stdenv.mkDerivation rec {
  pname = "sqlitestudio";
  version = "3.4.17";

  src = fetchFromGitHub {
    owner = "pawelsalawa";
    repo = "sqlitestudio";
    rev = version;
    hash = "sha256-nGu1MYI3uaQ/3rc5LlixF6YEUU+pUsB6rn/yjFDGYf0=";
  };

  nativeBuildInputs =
    [ copyDesktopItems ]
    ++ (with libsForQt5.qt5; [
      qmake
      qttools
      wrapQtAppsHook
    ]);

  buildInputs =
    [
      readline
      tcl
      python3
    ]
    ++ (with libsForQt5.qt5; [
      qtbase
      qtsvg
      qtdeclarative
      qtscript
    ]);

  hardeningDisable = [
    "fortify"
  ];

  configurePhase = ''
    runHook preConfigure
    export SRC=$NIX_BUILD_TOP/${src.name}
    mkdir $SRC/build-base && cd $SRC/build-base
    qmake $SRC/SQLiteStudio3 \
      "DEFINES += NO_AUTO_UPDATES" \
      "DEFINES += PLUGINS_DIR=${placeholder "out"}/lib/sqlitestudio"
    mkdir $SRC/build-plugins && cd $SRC/build-plugins
    qmake $SRC/Plugins \
      "PYTHON_VERSION = ${python3.pythonVersion}" \
      "INCLUDEPATH += ${python3}/include/python${python3.pythonVersion}"
    runHook postConfigure
  '';

  buildPhase = ''
    cd $SRC/build-base
    make -j $NIX_BUILD_CORES
    cd $SRC/build-plugins
    make -j $NIX_BUILD_CORES
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sqlitestudio";
      desktopName = "SQLiteStudio";
      exec = "sqlitestudio";
      icon = "sqlitestudio";
      comment = "Database manager for SQLite";
      terminal = false;
      startupNotify = false;
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall
    cd $SRC/build-base
    make install INSTALL_ROOT=$out
    cd $SRC/build-plugins
    make install INSTALL_ROOT=$out
    runHook postInstall
  '';

  postInstall = ''
    install -Dm755 \
      $SRC/SQLiteStudio3/guiSQLiteStudio/img/sqlitestudio.svg \
      $out/share/pixmaps/sqlitestudio.svg
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Free, open source, multi-platform SQLite database manager";
    homepage = "https://sqlitestudio.pl/";
    license = lib.licenses.gpl3;
    mainProgram = "sqlitestudio";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ asterismono ];
  };
}
