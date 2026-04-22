{ pkgs }:
let
  python = pkgs.python3;

  linkup-sdk = python.pkgs.buildPythonPackage rec {
    pname = "linkup-sdk";
    version = "0.13.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "linkup_sdk";
      inherit version;
      hash = "sha256-2rP1FruVW9ud1YFURb/ceiyYA9xXw7S+QDjZ5A89CWo=";
    };
    build-system = [ python.pkgs.hatchling ];
    dependencies = with python.pkgs; [ httpx pydantic ];
    doCheck = false;
  };

  linkup-cli-unwrapped = python.pkgs.buildPythonApplication rec {
    pname = "linkup-cli";
    version = "0.5.2";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "linkup_cli";
      inherit version;
      hash = "sha256-ODBg6gItlCb08XkDysaCQZWl0QRas2jHARzMKKTthzU=";
    };
    build-system = [ python.pkgs.hatchling ];
    dependencies = with python.pkgs; [ linkup-sdk rich ];
    doCheck = false;
  };
in
pkgs.writeShellScriptBin "linkup" ''
  export LINKUP_API_KEY="''${LINKUP_API_KEY:-$(${pkgs.gopass}/bin/gopass show -o linkup.so/api-key)}"
  exec ${linkup-cli-unwrapped}/bin/linkup "$@"
''
