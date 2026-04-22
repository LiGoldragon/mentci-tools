{ pkgs }:
let
  annas-mcp = pkgs.buildGoModule rec {
    pname = "annas-mcp";
    version = "0.0.5";
    src = pkgs.fetchFromGitHub {
      owner = "iosifache";
      repo = "annas-mcp";
      rev = "v${version}";
      hash = "sha256-XicM7tU5jD8B8n7JJDQ/84koBiLb8XF4+WBQ4LCUoRU=";
    };
    vendorHash = "sha256-2NdG5p2XfrhVgi388dRDBUSGwg6ybnzfn9495TWNGsA=";
    subPackages = [ "cmd/annas-mcp" ];
    ldflags = [ "-s" "-w" ];
    doCheck = false;
  };
in
pkgs.writeShellScriptBin "annas" ''
  export ANNAS_SECRET_KEY="''${ANNAS_SECRET_KEY:-$(${pkgs.gopass}/bin/gopass show -o annas-archive.gl/secret-key)}"
  export ANNAS_DOWNLOAD_PATH="''${ANNAS_DOWNLOAD_PATH:-$PWD}"
  export ANNAS_BASE_URL="''${ANNAS_BASE_URL:-annas-archive.gd}"
  exec ${annas-mcp}/bin/annas-mcp "$@"
''
