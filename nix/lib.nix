{ config ? {} }:
let
  # iohk-nix can be overridden for debugging purposes by setting
  # NIX_PATH=iohk_nix=/path/to/iohk-nix
  iohkNix = import (
    let try = builtins.tryEval <iohk_nix>;
    in if try.success
    then builtins.trace "using host <iohk_nix>" try.value
    else
      let
        spec = builtins.fromJSON (builtins.readFile ../pins/iohk-nix-src.json);
      in builtins.fetchTarball {
        url = "${spec.url}/archive/${spec.rev}.tar.gz";
        inherit (spec) sha256;
      }) {
      inherit config;
      nixpkgsJsonOverride = ../pins/nixpkgs-src.json;
      haskellNixJsonOverride = ../pins/haskell-nix-src.json;
    };

  pkgs = iohkNix.pkgs;
  lib = pkgs.lib;
in lib // { inherit iohkNix pkgs; inherit (iohkNix) nix-tools; }
