{
  lib,
  stdenv,
  fetchurl,
  python3,
  pkg-config,
  readline,
  tdb,
  talloc,
  tevent,
  popt,
  libxslt,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  cmocka,
  wafHook,
  buildPackages,
  libxcrypt,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ldb";
  version = "2.9.2";

  src = fetchurl {
    url = "mirror://samba/ldb/ldb-${finalAttrs.version}.tar.gz";
    hash = "sha256-0VWIQALHnbscPYZC+LEBPy5SCzru/W6WQSrexbjWy8A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    python3
    wafHook
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    tdb
    tevent
  ];

  buildInputs = [
    python3
    readline # required to build python
    tdb
    talloc
    tevent
    popt
    cmocka
    libxcrypt
  ];

  # otherwise the configure script fails with
  # PYTHONHASHSEED=1 missing! Don't use waf directly, use ./configure and make!
  preConfigure = ''
    export PKGCONFIG="$PKG_CONFIG"
    export PYTHONHASHSEED=1
  '';

  wafPath = "buildtools/bin/waf";

  wafConfigureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
    "--without-ldb-lmdb"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--cross-compile"
    "--cross-execute=${stdenv.hostPlatform.emulator buildPackages}"
  ];

  # python-config from build Python gives incorrect values when cross-compiling.
  # If python-config is not found, the build falls back to using the sysconfig
  # module, which works correctly in all cases.
  PYTHON_CONFIG = "/invalid";

  # https://reviews.llvm.org/D135402
  NIX_LDFLAGS = lib.optional (
    stdenv.cc.bintools.isLLVM && lib.versionAtLeast stdenv.cc.bintools.version "17"
  ) "--undefined-version";

  stripDebugList = [
    "bin"
    "lib"
    "modules"
  ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  meta = with lib; {
    broken = stdenv.hostPlatform.isDarwin;
    description = "LDAP-like embedded database";
    homepage = "https://ldb.samba.org/";
    license = licenses.lgpl3Plus;
    pkgConfigModules = [ "ldb" ];
    platforms = platforms.all;
  };
})
