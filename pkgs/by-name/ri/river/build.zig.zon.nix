# generated by zon2nix (https://github.com/Cloudef/zig2nix)

{
  lib,
  linkFarm,
  fetchurl,
  fetchgit,
  runCommandLocal,
  zig,
  name ? "zig-packages",
}:

with builtins;
with lib;

let
  unpackZigArtifact =
    { name, artifact }:
    runCommandLocal name { nativeBuildInputs = [ zig ]; } ''
      hash="$(zig fetch --global-cache-dir "$TMPDIR" ${artifact})"
      mv "$TMPDIR/p/$hash" "$out"
      chmod 755 "$out"
    '';

  fetchZig =
    {
      name,
      url,
      hash,
    }:
    let
      artifact = fetchurl { inherit url hash; };
    in
    unpackZigArtifact { inherit name artifact; };

  fetchGitZig =
    {
      name,
      url,
      hash,
      rev ? throw "rev is required, remove and regenerate the zon2json-lock file",
    }:
    let
      parts = splitString "#" url;
      url_base = elemAt parts 0;
      url_without_query = elemAt (splitString "?" url_base) 0;
    in
    fetchgit {
      inherit name rev hash;
      url = url_without_query;
      deepClone = false;
    };

  fetchZigArtifact =
    {
      name,
      url,
      hash,
      ...
    }@args:
    let
      parts = splitString "://" url;
      proto = elemAt parts 0;
      path = elemAt parts 1;
      fetcher = {
        "git+http" = fetchGitZig (
          args
          // {
            url = "http://${path}";
          }
        );
        "git+https" = fetchGitZig (
          args
          // {
            url = "https://${path}";
          }
        );
        http = fetchZig {
          inherit name hash;
          url = "http://${path}";
        };
        https = fetchZig {
          inherit name hash;
          url = "https://${path}";
        };
      };
    in
    fetcher.${proto};
in
linkFarm name [
  {
    name = "pixman-0.3.0-LClMnz2VAAAs7QSCGwLimV5VUYx0JFnX5xWU6HwtMuDX";
    path = fetchZigArtifact {
      name = "pixman";
      url = "https://codeberg.org/ifreund/zig-pixman/archive/v0.3.0.tar.gz";
      hash = "sha256-zX/jQV1NWGhalP3t0wjpmUo38BKCiUDPtgNGHefyxq0=";
    };
  }
  {
    name = "wayland-0.3.0-lQa1kjPIAQDmhGYpY-zxiRzQJFHQ2VqhJkQLbKKdt5wl";
    path = fetchZigArtifact {
      name = "wayland";
      url = "https://codeberg.org/ifreund/zig-wayland/archive/v0.3.0.tar.gz";
      hash = "sha256-xU8IrETSFOKKQQMgwVyRKLwGaek4USaKXg49S9oHSTQ=";
    };
  }
  {
    name = "wlroots-0.18.2-jmOlchnIAwBq45_cxU1V3OWErxxJjQZlc9PyJfR-l3uk";
    path = fetchZigArtifact {
      name = "wlroots";
      url = "https://codeberg.org/ifreund/zig-wlroots/archive/v0.18.2.tar.gz";
      hash = "sha256-4/MGFCCgMeN6+oCaj0Z5dsbVo3s88oYk1+q0mMXrj8I=";
    };
  }
  {
    name = "xkbcommon-0.3.0-VDqIe3K9AQB2fG5ZeRcMC9i7kfrp5m2rWgLrmdNn9azr";
    path = fetchZigArtifact {
      name = "xkbcommon";
      url = "https://codeberg.org/ifreund/zig-xkbcommon/archive/v0.3.0.tar.gz";
      hash = "sha256-HhhUI+ayPtlylhTmZ1GrdSLbRIffTg3MeisGN1qs2iM=";
    };
  }
]
