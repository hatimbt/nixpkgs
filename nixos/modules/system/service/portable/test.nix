# Run:
#   nix-instantiate --eval nixos/modules/system/service/portable/test.nix
let
  lib = import ../../../../../lib;

  inherit (lib) mkOption types;

  portable-lib = import ./lib.nix { inherit lib; };

  dummyPkg =
    name:
    derivation {
      system = "dummy";
      name = name;
      builder = "/bin/false";
    };

  exampleConfig = {
    _file = "${__curPos.file}:${toString __curPos.line}";
    services = {
      service1 = {
        process = {
          executable = "/usr/bin/echo"; # *giggles*
          args = [ "hello" ];
        };
        assertions = [
          {
            assertion = false;
            message = "you can't enable this for that reason";
          }
        ];
        warnings = [
          "The `foo' service is deprecated and will go away soon!"
        ];
      };
      service2 = {
        process = {
          # No meta.mainProgram, because it's supposedly an executable script _file_,
          # not a directory with a bin directory containing the main program.
          executable = dummyPkg "cowsay.sh";
          args = [ "world" ];
        };
      };
      service3 = {
        process = {
          executable = "/bin/false";
          args = [ ];
        };
        services.exclacow = {
          process = {
            executable = dummyPkg "cowsay-ng" // {
              meta.mainProgram = "cowsay";
            };
            args = [ "!" ];
          };
          assertions = [
            {
              assertion = false;
              message = "you can't enable this for such reason";
            }
          ];
          warnings = [
            "The `bar' service is deprecated and will go away soon!"
          ];
        };
      };
    };
  };

  exampleEval = lib.evalModules {
    modules = [
      {
        options.services = mkOption {
          type = types.attrsOf (
            types.submoduleWith {
              class = "service";
              modules = [
                ./service.nix
              ];
            }
          );
        };
      }
      exampleConfig
    ];
  };

  test =
    assert
      exampleEval.config == {
        services = {
          service1 = {
            process = {
              executable = "/usr/bin/echo";
              args = [ "hello" ];
            };
            services = { };
            assertions = [
              {
                assertion = false;
                message = "you can't enable this for that reason";
              }
            ];
            warnings = [
              "The `foo' service is deprecated and will go away soon!"
            ];
          };
          service2 = {
            process = {
              executable = "${dummyPkg "cowsay.sh"}";
              args = [ "world" ];
            };
            services = { };
            assertions = [ ];
            warnings = [ ];
          };
          service3 = {
            process = {
              executable = "/bin/false";
              args = [ ];
            };
            services.exclacow = {
              process = {
                executable = "${dummyPkg "cowsay-ng"}/bin/cowsay";
                args = [ "!" ];
              };
              services = { };
              assertions = [
                {
                  assertion = false;
                  message = "you can't enable this for such reason";
                }
              ];
              warnings = [ "The `bar' service is deprecated and will go away soon!" ];
            };
            assertions = [ ];
            warnings = [ ];
          };
        };
      };

    assert
      portable-lib.getWarnings [ "service1" ] exampleEval.config.services.service1 == [
        "in service1: The `foo' service is deprecated and will go away soon!"
      ];

    assert
      portable-lib.getAssertions [ "service1" ] exampleEval.config.services.service1 == [
        {
          message = "in service1: you can't enable this for that reason";
          assertion = false;
        }
      ];

    assert
      portable-lib.getWarnings [ "service3" ] exampleEval.config.services.service3 == [
        "in service3.services.exclacow: The `bar' service is deprecated and will go away soon!"
      ];
    assert
      portable-lib.getAssertions [ "service3" ] exampleEval.config.services.service3 == [
        {
          message = "in service3.services.exclacow: you can't enable this for such reason";
          assertion = false;
        }
      ];

    "ok";

in
test
