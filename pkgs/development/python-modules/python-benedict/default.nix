{
  lib,
  boto3,
  buildPythonPackage,
  fetchFromGitHub,
  ftfy,
  mailchecker,
  openpyxl,
  orjson,
  phonenumbers,
  beautifulsoup4,
  pytestCheckHook,
  python-dateutil,
  python-decouple,
  python-fsutil,
  python-slugify,
  pythonOlder,
  pyyaml,
  requests,
  setuptools,
  toml,
  xlrd,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "python-benedict";
  version = "0.34.1";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "fabiocaccamo";
    repo = "python-benedict";
    tag = version;
    hash = "sha256-ffmyTVeQKzV/sssxFuIckmBW6wmjnTWkHbVQ1v7fmGg=";
  };

  pythonRelaxDeps = [ "boto3" ];

  build-system = [ setuptools ];

  dependencies = [
    python-fsutil
    python-slugify
    requests
  ];

  optional-dependencies = {
    all = [
      beautifulsoup4
      boto3
      ftfy
      mailchecker
      openpyxl
      phonenumbers
      python-dateutil
      pyyaml
      toml
      xlrd
      xmltodict
    ];
    html = [
      beautifulsoup4
      xmltodict
    ];
    io = [
      beautifulsoup4
      openpyxl
      pyyaml
      toml
      xlrd
      xmltodict
    ];
    parse = [
      ftfy
      mailchecker
      phonenumbers
      python-dateutil
    ];
    s3 = [ boto3 ];
    toml = [ toml ];
    xls = [
      openpyxl
      xlrd
    ];
    xml = [ xmltodict ];
    yaml = [ pyyaml ];
  };

  nativeCheckInputs = [
    orjson
    pytestCheckHook
    python-decouple
  ]
  ++ lib.flatten (builtins.attrValues optional-dependencies);

  disabledTests = [
    # Tests require network access
    "test_from_base64_with_valid_url_valid_content"
    "test_from_html_with_valid_file_valid_content"
    "test_from_html_with_valid_url_valid_content"
    "test_from_json_with_valid_url_valid_content"
    "test_from_pickle_with_valid_url_valid_content"
    "test_from_plist_with_valid_url_valid_content"
    "test_from_query_string_with_valid_url_valid_content"
    "test_from_toml_with_valid_url_valid_content"
    "test_from_xls_with_valid_url_valid_content"
    "test_from_xml_with_valid_url_valid_content"
    "test_from_yaml_with_valid_url_valid_content"
  ];

  pythonImportsCheck = [ "benedict" ];

  meta = with lib; {
    description = "Module with keylist/keypath support";
    homepage = "https://github.com/fabiocaccamo/python-benedict";
    changelog = "https://github.com/fabiocaccamo/python-benedict/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
