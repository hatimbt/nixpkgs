# This module defines global configuration for the xonsh.

{ config, lib, pkgs, ... }:

let

  cfg = config.programs.xonsh;
  package = cfg.package.override { inherit (cfg) extraPackages; };
in

{

  options = {

    programs.xonsh = {

      enable = lib.mkOption {
        default = false;
        description = ''
          Whether to configure xonsh as an interactive shell.
        '';
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "xonsh" {
        example = "pkgs.xonsh.override { extraPackages = ps: [ ps.requests ]; }";
      };

      config = lib.mkOption {
        default = "";
        description = "Control file to customize your shell behavior.";
        type = lib.types.lines;
      };

      extraPackages = lib.mkOption {
        default = (ps: [ ]);
        type = with lib.types; coercedTo (listOf lib.types.package) (v: (_: v)) (functionTo (listOf lib.types.package));
        description = ''
          Add the specified extra packages to the xonsh package.
          Preferred over using `programs.xonsh.package` as it composes with `programs.xonsh.xontribs`.

          Take care in using this option along with manually defining the package
          option above, as the two can result in conflicting sets of build dependencies.
          This option assumes that the package option has an overridable argument
          called `extraPackages`, so if you override the package option but also
          intend to use this option, be sure that your resulting package still honors
          the necessary option.
        '';
      };
    };

  };

  config = lib.mkIf cfg.enable {

    environment.etc."xonsh/xonshrc".text = ''
      # /etc/xonsh/xonshrc: DO NOT EDIT -- this file has been generated automatically.


      if not ''${...}.get('__NIXOS_SET_ENVIRONMENT_DONE'):
          # The NixOS environment and thereby also $PATH
          # haven't been fully set up at this point. But
          # `source-bash` below requires `bash` to be on $PATH,
          # so add an entry with bash's location:
          $PATH.add('${pkgs.bash}/bin')

          # Stash xonsh's ls alias, so that we don't get a collision
          # with Bash's ls alias from environment.shellAliases:
          _ls_alias = aliases.pop('ls', None)

          # Source the NixOS environment config.
          source-bash "${config.system.build.setEnvironment}"

          # Restore xonsh's ls alias, overriding that from Bash (if any).
          if _ls_alias is not None:
              aliases['ls'] = _ls_alias
          del _ls_alias

      ${cfg.config}
    '';

    environment.systemPackages = [ package ];

    environment.shells = [
      "/run/current-system/sw/bin/xonsh"
      "${lib.getExe package}"
    ];
  };
}
