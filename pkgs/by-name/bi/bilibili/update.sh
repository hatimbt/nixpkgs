#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix git curl cacert nix-prefetch-git jq

set -euo pipefail

cd $(readlink -e $(dirname "${BASH_SOURCE[0]}"))

payload=$(curl https://api.github.com/repos/msojocs/bilibili-linux/releases/latest)
version=$(jq -r .tag_name <<< "$payload" | cut -c 2-)
amd64_url=https://github.com/msojocs/bilibili-linux/releases/download/v${version}/io.github.msojocs.bilibili_${version}_amd64.deb
arm64_url=https://github.com/msojocs/bilibili-linux/releases/download/v${version}/io.github.msojocs.bilibili_${version}_arm64.deb

amd64_hash=$(nix-prefetch-url $amd64_url)
arm64_hash=$(nix-prefetch-url $arm64_url)

# use friendlier hashes
amd64_hash=$(nix hash convert --to sri --hash-algo sha256 "$amd64_hash")
arm64_hash=$(nix hash convert --to sri --hash-algo sha256 "$arm64_hash")

cat >sources.nix <<EOF
# Generated by ./update.sh - do not update manually!
{
  version = "$version";
  arm64-hash = "$arm64_hash";
  x86_64-hash = "$amd64_hash";
}
EOF
