{ inputs, system }:
let
  pkgs = import inputs.beads.inputs.nixpkgs { inherit system; };
in
pkgs.buildGoModule {
  pname = "beads";
  version = "1.0.2";
  src = inputs.beads;

  subPackages = [ "cmd/bd" ];
  doCheck = false;

  vendorHash = "sha256-stY1JxMAeINT73KCvwZyh/TUktkLirEcGa0sW1u7W1s=";

  postPatch = ''
    goVer="$(go env GOVERSION | sed 's/^go//')"
    go mod edit -go="$goVer"
  '';

  env.GOTOOLCHAIN = "auto";
  env.CGO_CPPFLAGS = "-I${pkgs.icu77.dev}/include";
  env.CGO_LDFLAGS = "-L${pkgs.icu77}/lib";

  nativeBuildInputs = [ pkgs.git ];

  meta = {
    description = "beads (bd) — issue tracker for AI-supervised coding workflows";
    homepage = "https://github.com/gastownhall/beads";
    license = pkgs.lib.licenses.mit;
    mainProgram = "bd";
  };
}
