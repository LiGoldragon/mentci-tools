{ pkgs }:
let
  # Pinned to LiGoldragon/annas-mcp fix/stall-timeout branch. This
  # carries a patch that replaces the upstream 30s whole-request
  # http.Client.Timeout in Book.Download / Paper.Download with
  # TTFB + stall-based deadlines, so large books download on slow
  # links as long as bytes keep flowing. Upstream PR pending at
  # https://github.com/iosifache/annas-mcp. When the PR merges and
  # a release is cut, flip owner back to `iosifache` and rev to a
  # release tag.
  annas-mcp = pkgs.buildGoModule {
    pname = "annas-mcp";
    version = "0.0.5-stall-timeout";
    src = pkgs.fetchFromGitHub {
      owner = "LiGoldragon";
      repo = "annas-mcp";
      rev = "285fd4c6668fb048db512698c9dd3bc154657b47";
      hash = "sha256-H9nwpZuuP7Ii2LLYvEkJE6ww+PKqWuYBE793/q6NX6M=";
    };
    vendorHash = "sha256-2NdG5p2XfrhVgi388dRDBUSGwg6ybnzfn9495TWNGsA=";
    subPackages = [ "cmd/annas-mcp" ];
    ldflags = [ "-s" "-w" ];

    # Run Go unit tests during build. These cover the stall-timeout
    # primitive in internal/anna/download.go end-to-end: slow-steady
    # streams, stall firing, TTFB firing, non-200 handling, context
    # cancellation, header exposure, and progress-resets-watchdog.
    #
    # The default checkPhase only tests subPackages, which would skip
    # internal/anna entirely. Override it to exercise the whole module.
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      go test -race -count=1 -timeout 60s ./...
      runHook postCheck
    '';

    meta = {
      description = "Anna's Archive CLI and MCP server (fork with stall-based download timeout)";
      homepage = "https://github.com/LiGoldragon/annas-mcp";
      license = pkgs.lib.licenses.mit;
    };
  };

  # Smoke test: the built binary must run and print its version.
  smokeTest = pkgs.runCommand "annas-mcp-smoke" { } ''
    ${annas-mcp}/bin/annas-mcp --version > $out
    test -s $out
  '';

in
(pkgs.writeShellScriptBin "annas" ''
  export ANNAS_SECRET_KEY="''${ANNAS_SECRET_KEY:-$(${pkgs.gopass}/bin/gopass show -o annas-archive.gl/secret-key)}"
  export ANNAS_DOWNLOAD_PATH="''${ANNAS_DOWNLOAD_PATH:-$PWD}"
  export ANNAS_BASE_URL="''${ANNAS_BASE_URL:-annas-archive.gd}"
  exec ${annas-mcp}/bin/annas-mcp "$@"
'').overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    inherit annas-mcp;
    tests = {
      # Re-runs the Go unit tests as a standalone derivation. Since
      # annas-mcp already has doCheck = true, this is a no-op if the
      # package itself was built successfully — but it makes the test
      # surface explicit for `nix flake check` and friends.
      unit = annas-mcp;

      # Confirms the wrapped binary invokes end-to-end.
      smoke = smokeTest;
    };
  };
})
