import ./make-test-python.nix (
  { pkgs, lib, ... }:
  {
    name = "apparmor";
    meta.maintainers = with lib.maintainers; [
      julm
      grimmauld
    ];

    nodes.machine =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        security.apparmor.enable = lib.mkDefault true;
      };

    testScript = ''
      machine.wait_for_unit("multi-user.target")

      with subtest("AppArmor profiles are loaded"):
          machine.succeed("systemctl status apparmor.service")

      # AppArmor securityfs
      with subtest("AppArmor securityfs is mounted"):
          machine.succeed("mountpoint -q /sys/kernel/security")
          machine.succeed("cat /sys/kernel/security/apparmor/profiles")

      # Test apparmorRulesFromClosure by:
      # 1. Prepending a string of the relevant packages' name and version on each line.
      # 2. Sorting according to those strings.
      # 3. Removing those prepended strings.
      # 4. Using `diff` against the expected output.
      with subtest("apparmorRulesFromClosure"):
          machine.succeed(
              "${pkgs.diffutils}/bin/diff -u ${pkgs.writeText "expected.rules" ''
                ixr ${pkgs.bash}/libexec/**,
                mr ${pkgs.bash}/lib/**.so*,
                mr ${pkgs.bash}/lib64/**.so*,
                mr ${pkgs.bash}/share/**,
                r ${pkgs.bash},
                r ${pkgs.bash}/etc/**,
                r ${pkgs.bash}/lib/**,
                r ${pkgs.bash}/lib64/**,
                x ${pkgs.bash}/foo/**,
                ixr ${pkgs.glibc}/libexec/**,
                mr ${pkgs.glibc}/lib/**.so*,
                mr ${pkgs.glibc}/lib64/**.so*,
                mr ${pkgs.glibc}/share/**,
                r ${pkgs.glibc},
                r ${pkgs.glibc}/etc/**,
                r ${pkgs.glibc}/lib/**,
                r ${pkgs.glibc}/lib64/**,
                x ${pkgs.glibc}/foo/**,
                ixr ${pkgs.libcap}/libexec/**,
                mr ${pkgs.libcap}/lib/**.so*,
                mr ${pkgs.libcap}/lib64/**.so*,
                mr ${pkgs.libcap}/share/**,
                r ${pkgs.libcap},
                r ${pkgs.libcap}/etc/**,
                r ${pkgs.libcap}/lib/**,
                r ${pkgs.libcap}/lib64/**,
                x ${pkgs.libcap}/foo/**,
                ixr ${pkgs.libcap.lib}/libexec/**,
                mr ${pkgs.libcap.lib}/lib/**.so*,
                mr ${pkgs.libcap.lib}/lib64/**.so*,
                mr ${pkgs.libcap.lib}/share/**,
                r ${pkgs.libcap.lib},
                r ${pkgs.libcap.lib}/etc/**,
                r ${pkgs.libcap.lib}/lib/**,
                r ${pkgs.libcap.lib}/lib64/**,
                x ${pkgs.libcap.lib}/foo/**,
                ixr ${pkgs.libidn2.out}/libexec/**,
                mr ${pkgs.libidn2.out}/lib/**.so*,
                mr ${pkgs.libidn2.out}/lib64/**.so*,
                mr ${pkgs.libidn2.out}/share/**,
                r ${pkgs.libidn2.out},
                r ${pkgs.libidn2.out}/etc/**,
                r ${pkgs.libidn2.out}/lib/**,
                r ${pkgs.libidn2.out}/lib64/**,
                x ${pkgs.libidn2.out}/foo/**,
                ixr ${pkgs.libunistring}/libexec/**,
                mr ${pkgs.libunistring}/lib/**.so*,
                mr ${pkgs.libunistring}/lib64/**.so*,
                mr ${pkgs.libunistring}/share/**,
                r ${pkgs.libunistring},
                r ${pkgs.libunistring}/etc/**,
                r ${pkgs.libunistring}/lib/**,
                r ${pkgs.libunistring}/lib64/**,
                x ${pkgs.libunistring}/foo/**,
                ixr ${pkgs.glibc.libgcc}/libexec/**,
                mr ${pkgs.glibc.libgcc}/lib/**.so*,
                mr ${pkgs.glibc.libgcc}/lib64/**.so*,
                mr ${pkgs.glibc.libgcc}/share/**,
                r ${pkgs.glibc.libgcc},
                r ${pkgs.glibc.libgcc}/etc/**,
                r ${pkgs.glibc.libgcc}/lib/**,
                r ${pkgs.glibc.libgcc}/lib64/**,
                x ${pkgs.glibc.libgcc}/foo/**,
              ''} ${
                pkgs.runCommand "actual.rules" { preferLocalBuild = true; } ''
                  ${pkgs.gnused}/bin/sed -e 's:^[^ ]* ${builtins.storeDir}/[^,/-]*-\([^/,]*\):\1 \0:' ${
                    pkgs.apparmorRulesFromClosure {
                      name = "ping";
                      additionalRules = [ "x $path/foo/**" ];
                    } [ pkgs.libcap ]
                  } |
                  ${pkgs.coreutils}/bin/sort -n -k1 |
                  ${pkgs.gnused}/bin/sed -e 's:^[^ ]* ::' >$out
                ''
              }"
          )
    '';
  }
)
