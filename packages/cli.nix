{ pkgs, inputs, system }:
let
  beads = import ./beads.nix { inherit inputs system; };
  dolt = import ./dolt.nix { inherit pkgs; };
  annas = import ./annas.nix { inherit pkgs; };
  substack = import ./substack.nix { inherit inputs system; };
  linkup = import ./linkup.nix { inherit pkgs; };
in
pkgs.symlinkJoin {
  name = "mentci-cli";
  paths = [
    beads
    dolt
    annas
    substack
    linkup
  ];
  meta.description = "mentci workspace CLI bundle: bd, dolt, annas, substack, linkup";
}
