{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.inadyn;

  # check if a value of an attrset is not null or an empty collection
  nonEmptyValue = _: v: v != null && v != [ ] && v != { };

  renderOption =
    k: v:
    if
      builtins.elem k [
        "provider"
        "custom"
      ]
    then
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: config: ''
          ${k} ${name} {
              ${lib.concatStringsSep "\n    " (
                lib.mapAttrsToList renderOption (lib.filterAttrs nonEmptyValue config)
              )}
          }'') v
      )
    else if k == "include" then
      "${k}(\"${v}\")"
    else if k == "hostname" && builtins.isList v then
      "${k} = { ${builtins.concatStringsSep ", " (map (s: "\"${s}\"") v)} }"
    else if builtins.isBool v then
      "${k} = ${lib.boolToString v}"
    else if builtins.isString v then
      "${k} = \"${v}\""
    else
      "${k} = ${toString v}";

  configFile' = pkgs.writeText "inadyn.conf" ''
    # This file was generated by nix
    # do not edit

    ${
      (lib.concatStringsSep "\n" (
        lib.mapAttrsToList renderOption (lib.filterAttrs nonEmptyValue cfg.settings)
      ))
    }
  '';

  configFile = if (cfg.configFile != null) then cfg.configFile else configFile';
in
{
  options.services.inadyn =
    with lib.types;
    let
      providerOptions = {
        include = lib.mkOption {
          default = null;
          description = "File to include additional settings for this provider from.";
          type = nullOr path;
        };
        ssl = lib.mkOption {
          default = true;
          description = "Whether to use HTTPS for this DDNS provider.";
          type = bool;
        };
        username = lib.mkOption {
          default = null;
          description = "Username for this DDNS provider.";
          type = nullOr str;
        };
        password = lib.mkOption {
          default = null;
          description = ''
            Password for this DDNS provider.

            WARNING: This will be world-readable in the nix store.
            To store credentials securely, use the `include` or `configFile` options.
          '';
          type = nullOr str;
        };
        hostname = lib.mkOption {
          default = "*";
          example = "your.cool-domain.com";
          description = "Hostname alias(es).";
          type = either str (listOf str);
        };
      };
    in
    {
      enable = lib.mkEnableOption (''
        synchronise your machine's IP address with a dynamic DNS provider using inadyn
      '');
      user = lib.mkOption {
        default = "inadyn";
        type = lib.types.str;
        description = ''
          User account under which inadyn runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the inadyn service starts.
          :::
        '';
      };
      group = lib.mkOption {
        default = "inadyn";
        type = lib.types.str;
        description = ''
          Group account under which inadyn runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the inadyn service starts.
          :::
        '';
      };
      interval = lib.mkOption {
        default = "*-*-* *:*:00";
        description = ''
          How often to check the current IP.
          Uses the format described in {manpage}`systemd.time(7)`";
        '';
        type = str;
      };
      logLevel = lib.mkOption {
        type = lib.types.enum [
          "none"
          "err"
          "warning"
          "info"
          "notice"
          "debug"
        ];
        default = "notice";
        description = "Set inadyn's log level.";
      };
      settings = lib.mkOption {
        default = { };
        description = "See `inadyn.conf (5)`";
        type = submodule {
          freeformType = attrs;
          options = {
            allow-ipv6 = lib.mkOption {
              default = config.networking.enableIPv6;
              defaultText = "`config.networking.enableIPv6`";
              description = "Whether to get IPv6 addresses from interfaces.";
              type = bool;
            };
            forced-update = lib.mkOption {
              default = 2592000;
              description = "Duration (in seconds) after which an update is forced.";
              type = ints.positive;
            };
            provider = lib.mkOption {
              default = { };
              description = ''
                Settings for DDNS providers built-in to inadyn.

                For a list of built-in providers, see `inadyn.conf (5)`.
              '';
              type = attrsOf (submodule {
                freeformType = attrs;
                options = providerOptions;
              });
            };
            custom = lib.mkOption {
              default = { };
              description = ''
                Settings for custom DNS providers.
              '';
              type = attrsOf (submodule {
                freeformType = attrs;
                options = providerOptions // {
                  ddns-server = lib.mkOption {
                    description = "DDNS server name.";
                    type = str;
                  };
                  ddns-path = lib.mkOption {
                    description = ''
                      DDNS server path.

                      See `inadnyn.conf (5)` for a list for format specifiers that can be used.
                    '';
                    example = "/update?user=%u&password=%p&domain=%h&myip=%i";
                    type = str;
                  };
                };
              });
            };
          };
        };
      };
      configFile = lib.mkOption {
        default = null;
        description = ''
          Configuration file for inadyn.

          Setting this will override all other configuration options.

          Passed to the inadyn service using LoadCredential.
        '';
        type = nullOr path;
      };
    };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.inadyn = {
        description = "Update nameservers using inadyn";
        documentation = [
          "man:inadyn"
          "man:inadyn.conf"
          "file:${pkgs.inadyn}/share/doc/inadyn/README.md"
        ];
        requires = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        startAt = cfg.interval;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${lib.getExe pkgs.inadyn} -f ${configFile} --cache-dir ''${CACHE_DIRECTORY} -1 --foreground -l ${cfg.logLevel}'';
          LoadCredential = "config:${configFile}";
          CacheDirectory = "inadyn";

          User = cfg.user;
          Group = cfg.group;
          UMask = "0177";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectSystem = "strict";
          ProtectProc = "invisible";
          ProtectHome = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";
          SystemCallFilter = "@system-service";
          CapabilityBoundingSet = "";
        };
      };

      timers.inadyn.timerConfig.Persistent = true;
    };

    users.users.inadyn = lib.mkIf (cfg.user == "inadyn") {
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups = lib.mkIf (cfg.group == "inadyn") {
      inadyn = { };
    };
  };
}
