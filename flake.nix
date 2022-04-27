{
  description = "xsd flattener";
  nixConfig.bash-prompt = "\[python\]$ ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      pythonVersion = "python27";
    in
    flake-utils.lib.eachDefaultSystem
    (system: let 
      pkgs = nixpkgs.legacyPackages.${system};
      buildInputs = with pkgs; [
        python27 python27Packages.lxml
      ];
    in rec {
      packages = flake-utils.lib.flattenTree rec {
        xsdflatten-py = ./xsdflatten.py; 
        xsdflatten = pkgs.writeScriptBin "xsdflatten" ''
          #!${pkgs.runtimeShell}
          PATH=${pkgs.lib.makeBinPath buildInputs}:$PATH
          ${pkgs.python27}/bin/python2.7 ${xsdflatten-py} $1
          '';
        };
        defaultPackage = packages.xsdflatten;
        devShell = pkgs.mkShell {
          inherit buildInputs;
        };
        }
      );
}
