# This file was generated by pkgs.mastodon.updateScript.
{
  fetchFromGitHub,
  applyPatches,
  patches ? [ ],
}:
let
  version = "4.2.14";
in
(applyPatches {
  src = fetchFromGitHub {
    owner = "mastodon";
    repo = "mastodon";
    rev = "v${version}";
    hash = "sha256-oRbwoCjsc3f+ldG9HFEHifvvBZlz/U3HCsqYxsWwewY=";
  };
  patches = patches ++ [ ];
})
// {
  inherit version;
  yarnHash = "sha256-qoLesubmSvRsXhKwMEWHHXcpcqRszqcdZgHQqnTpNPE=";
}
