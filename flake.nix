{
  inputs = {
    nixpkgs.url =
      "github:dpaetzel/nixpkgs/update-clipmenu";

    # overlays.url = "github:dpaetzel/overlays/master";

    systems.url = "github:nix-systems/default";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      # overlays,
      devenv,
      systems,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # overlays = [
            #   overlays.overlays.mydefaults
            #   overlays.overlays.xcsf
            # ];
          };
          # Only if using dpaetzel overlays.
          # mypython = pkgs.mypython;
          mypython = pkgs.python311;
        in
        rec {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              {
                # https://devenv.sh/reference/options/
                languages.python.enable = true;
                languages.python.package = mypython;

                languages.julia.enable = true;
                # Only if using dpaetzel overlays.
                # languages.julia.package = pkgs.myjulia;

                env = {
                  # Required for Julia's PyCall. Have to Pkg.build("PyCall")
                  # whenever this is changed!
                  "PYTHON" = "${mypython}/bin/python";
                };

                # I somehow can't specify Python dependencies via
                # `mypython.withPackages` rn.
                packages =
                  [
                    # Better makefiles.
                    pkgs.just
                  ]
                  ++ (with mypython.pkgs; [
                    mlflow
                    # setuptools is required by mlflow, it seems.
                    setuptools
                  ]);

              }
            ];
          };
          devShell.${system} = default;
        }
      );
    };
}
