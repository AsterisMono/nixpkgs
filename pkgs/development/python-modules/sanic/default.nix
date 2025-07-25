{
  lib,
  stdenv,
  aiofiles,
  aioquic,
  beautifulsoup4,
  buildPythonPackage,
  fetchFromGitHub,
  gunicorn,
  html5tagger,
  httptools,
  multidict,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  sanic-ext,
  sanic-routing,
  sanic-testing,
  setuptools,
  tracerite,
  typing-extensions,
  ujson,
  uvicorn,
  uvloop,
  websockets,
}:

buildPythonPackage rec {
  pname = "sanic";
  version = "25.3.0";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "sanic-org";
    repo = "sanic";
    tag = "v${version}";
    hash = "sha256-tucLXWYPpALQrPYf+aiovKHYf2iouu6jezvNdukEu9w=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    httptools
    html5tagger
    multidict
    sanic-routing
    tracerite
    typing-extensions
    ujson
    uvloop
    websockets
  ];

  optional-dependencies = {
    ext = [ sanic-ext ];
    http3 = [ aioquic ];
  };

  nativeCheckInputs = [
    beautifulsoup4
    gunicorn
    pytest-asyncio
    pytestCheckHook
    sanic-testing
    uvicorn
  ]
  ++ optional-dependencies.http3;

  doCheck = !stdenv.hostPlatform.isDarwin;

  preCheck = ''
    # Some tests depends on sanic on PATH
    PATH="$out/bin:$PATH"
    PYTHONPATH=$PWD:$PYTHONPATH

    # needed for relative paths for some packages
    cd tests
  '';

  disabledTests = [
    # EOFError: Ran out of input
    "test_server_run_with_repl"
    # InvalidStatusCode: server rejected WebSocket connection: HTTP 400
    "test_websocket_route_with_subprotocols"
    # nic.exceptions.SanicException: Cannot setup Sanic Simple Server without a path to a directory
    "test_load_app_simple"
    # ModuleNotFoundError: No module named '/build/source/tests/tests/static'
    "test_input_is_dir"
    # Racy, e.g. Address already in use
    "test_logger_vhosts"
  ];

  disabledTestPaths = [
    # We are not interested in benchmarks
    "benchmark/"
    # We are also not interested in typing
    "typing/test_typing.py"
    # occasionally hangs
    "test_multiprocessing.py"
  ];

  # Avoid usage of nixpkgs-review in darwin since tests will compete usage
  # for the same local port
  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "sanic" ];

  meta = with lib; {
    description = "Web server and web framework";
    homepage = "https://github.com/sanic-org/sanic/";
    changelog = "https://github.com/sanic-org/sanic/releases/tag/${src.tag}";
    license = licenses.mit;
    maintainers = with maintainers; [ p0lyw0lf ];
    mainProgram = "sanic";
  };
}
