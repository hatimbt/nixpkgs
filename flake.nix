# Experimental flake interface to Nixpkgs.
# See https://github.com/NixOS/rfcs/pull/49 for details.
{
  description = "A collection of packages for the Nix package manager";

  outputs = { self }:
    let
      libVersionInfoOverlay = import ./lib/flake-version-info.nix self;
      lib = (import ./lib).extend libVersionInfoOverlay;

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;

      jobs = forAllSystems (system: import ./pkgs/top-level/release.nix {
        nixpkgs = self;
        inherit system;
      });
    in
    {
      /**
        `nixpkgs.lib` is a combination of the [Nixpkgs library](https://nixos.org/manual/nixpkgs/unstable/#id-1.4), and other attributes
        that are _not_ part of the Nixpkgs library, but part of the Nixpkgs flake:

        - `lib.nixosSystem` for creating a NixOS system configuration

        - `lib.nixos` for other NixOS-provided functionality, such as [`runTest`](https://nixos.org/manual/nixos/unstable/#sec-call-nixos-test-outside-nixos)
      */
      lib = lib.extend (final: prev: {

        /**
          Other NixOS-provided functionality, such as [`runTest`](https://nixos.org/manual/nixos/unstable/#sec-call-nixos-test-outside-nixos).
          See also `lib.nixosSystem`.
        */
        nixos = import ./nixos/lib { lib = final; };

        /**
          Create a NixOS system configuration.

          Example:

              lib.nixosSystem {
                modules = [ ./configuration.nix ];
              }

          Inputs:

          - `modules` (list of paths or inline modules): The NixOS modules to include in the system configuration.

          - `specialArgs` (attribute set): Extra arguments to pass to all modules, that are available in `imports` but can not be extended or overridden by the `modules`.

          - `modulesLocation` (path): A default location for modules that aren't passed by path, used for error messages.

          Legacy inputs:

          - `system`: Legacy alias for `nixpkgs.hostPlatform`, but this is already set in the generated `hardware-configuration.nix`, included by `configuration.nix`.
          - `pkgs`: Legacy alias for `nixpkgs.pkgs`; use `nixpkgs.pkgs` and `nixosModules.readOnlyPkgs` instead.
        */
        nixosSystem = args:
          import ./nixos/lib/eval-config.nix (
            {
              lib = final;
              # Allow system to be set modularly in nixpkgs.system.
              # We set it to null, to remove the "legacy" entrypoint's
              # non-hermetic default.
              system = null;

              modules = args.modules ++ [
                # This module is injected here since it exposes the nixpkgs self-path in as
                # constrained of contexts as possible to avoid more things depending on it and
                # introducing unnecessary potential fragility to changes in flakes itself.
                #
                # See: failed attempt to make pkgs.path not copy when using flakes:
                # https://github.com/NixOS/nixpkgs/pull/153594#issuecomment-1023287913
                ({ config, pkgs, lib, ... }: {
                  config.nixpkgs.flake.source = self.outPath;
                })
              ];
            } // builtins.removeAttrs args [ "modules" ]
          );

        /**
          The public interface to the Nixpkgs package set

          This sublibrary is part of the Nixpkgs flake, but not part of the Nixpkgs library.
         */
        # NOTE: Almost everything about Nixpkgs lives in the `pkgs` attribute set,
        #       so we better make very sure that if we add something here it really
        #       belongs here and we have a good plan for whatever kind of thing that is.
        nixpkgs = {
          /**
            _Create the Nixpkgs package set_

            See <https://nixos.org/manual/nixpkgs/unstable/index.html#sec-nixpkgs-function> for details descriptions of the arguments.

            # Inputs

            - `hostPlatform` (string or platform): The platform on which the packages will run.

            - `buildPlatform` (string or platform): The platform on which the derivations are built. Default: `hostPlatform`.

            - `config` (attrset): See <https://nixos.org/manual/nixpkgs/unstable/index.html#sec-nixpkgs-arguments-config>.

            - `overlays` (list of functions): List of overlays layers used to modify Nixpkgs.

            - `crossOverlays` (list of functions): List of overlays layers used to modify the host packages only.

            # Return value

            The "pkgs" attribute set, containing:
            - packages
            - package sets
            - other things such as functions that rely on the package set
            - `_type = "pkgs";`
           */
          # Note to developers:
          # This intentionally omits legacy arguments like `localSystem`
          # and `crossSystem`, so that the ecosystem moves towards a more
          # consistent terminology and usage. Please don't add them.
          # You won't be required to use this until perhaps we deprecate
          # inputs.nixpkgs.outPath (used by `import`), which would require a
          # change in Nix that may take another while.
          mkPkgs = args@{
            hostPlatform,
            buildPlatform ? null, # default handled downstream
            config ? null, # default handled downstream
            overlays ? null, # default handled downstream
            crossOverlays ? null, # default handled downstream
            stdenvStages ? null, # default handled downstream
          }:
            import ./pkgs/top-level/default.nix args;
        };

      });

      checks = forAllSystems (system: {
        tarball = jobs.${system}.tarball;
        # Exclude power64 due to "libressl is not available on the requested hostPlatform" with hostPlatform being power64
      } // lib.optionalAttrs (self.legacyPackages.${system}.stdenv.hostPlatform.isLinux && !self.legacyPackages.${system}.targetPlatform.isPower64) {
        # Test that ensures that the nixosSystem function can accept a lib argument
        # Note: prefer not to extend or modify `lib`, especially if you want to share reusable modules
        #       alternatives include: `import` a file, or put a custom library in an option or in `_module.args.<libname>`
        nixosSystemAcceptsLib = (self.lib.nixosSystem {
          pkgs = self.legacyPackages.${system};
          lib = self.lib.extend (final: prev: {
            ifThisFunctionIsMissingTheTestFails = final.id;
          });
          modules = [
            ./nixos/modules/profiles/minimal.nix
            ({ lib, ... }: lib.ifThisFunctionIsMissingTheTestFails {
              # Define a minimal config without eval warnings
              nixpkgs.hostPlatform = "x86_64-linux";
              boot.loader.grub.enable = false;
              fileSystems."/".device = "nodev";
              # See https://search.nixos.org/options?show=system.stateVersion&query=stateversion
              system.stateVersion = lib.trivial.release; # DON'T do this in real configs!
            })
          ];
        }).config.system.build.toplevel;
      });

      htmlDocs = {
        nixpkgsManual = builtins.mapAttrs (_: jobSet: jobSet.manual) jobs;
        nixosManual = (import ./nixos/release-small.nix {
          nixpkgs = self;
        }).nixos.manual;
      };

      devShells = forAllSystems (system: {
        /** A shell to get tooling for Nixpkgs development. See nixpkgs/shell.nix. */
        default = import ./shell.nix { inherit system; };
      });

      /**
        A nested structure of [packages](https://nix.dev/manual/nix/latest/glossary#package-attribute-set) and other values.

        The "legacy" in `legacyPackages` doesn't imply that the packages exposed
        through this attribute are "legacy" packages. Instead, `legacyPackages`
        is used here as a substitute attribute name for `packages`. The problem
        with `packages` is that it makes operations like `nix flake show
        nixpkgs` unusably slow due to the sheer number of packages the Nix CLI
        needs to evaluate. But when the Nix CLI sees a `legacyPackages`
        attribute it displays `omitted` instead of evaluating all packages,
        which keeps `nix flake show` on Nixpkgs reasonably fast, though less
        information rich.

        The reason why finding the tree structure of `legacyPackages` is slow,
        is that for each attribute in the tree, it is necessary to check whether
        the attribute value is a package or a package set that needs further
        evaluation. Evaluating the attribute value tends to require a significant
        amount of computation, even considering lazy evaluation.
      */
      legacyPackages = forAllSystems (system:
        (import ./. { inherit system; }).extend (final: prev: {
          lib = prev.lib.extend libVersionInfoOverlay;
        })
      );

      /**
        Optional modules that can be imported into a NixOS configuration.

        Example:

            # flake.nix
            outputs = { nixpkgs, ... }: {
              nixosConfigurations = {
                foo = nixpkgs.lib.nixosSystem {
                  modules = [
                    ./foo/configuration.nix
                    nixpkgs.nixosModules.notDetected
                  ];
                };
              };
            };
        */
      nixosModules = {
        notDetected = ./nixos/modules/installer/scan/not-detected.nix;

        /**
          Make the `nixpkgs.*` configuration read-only. Guarantees that `pkgs`
          is the way you initialize it.

          Example:

              {
                imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
                nixpkgs.pkgs = nixpkgs.legacyPackages.x86_64-linux;
              }
        */
        readOnlyPkgs = ./nixos/modules/misc/nixpkgs/read-only.nix;
      };
    };
}
