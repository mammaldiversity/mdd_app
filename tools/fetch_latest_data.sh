#!/bin/bash
# Downloads the latest MDD.zip and the latest MIL release tarball into data/.
#
# Older MIL tarballs and any stale data/mil.json are removed so that
# tools/generate_prefilled_db.sh can only pick up the release fetched here.
set -euo pipefail

MDD_URL="https://github.com/mammaldiversity/mammaldiversity.github.io/raw/master/assets/data/MDD.zip"
MIL_REPO="https://github.com/mammaldiversity/asm-mil"

cd "$(dirname "$0")/.."
mkdir -p data

echo "--> Resolving latest MIL release..."
# The /releases/latest page redirects to /releases/tag/<tag>; reading the
# redirect avoids the GitHub API and its rate limit.
MIL_TAG=$(curl -fsSI "$MIL_REPO/releases/latest" \
    | tr -d '\r' \
    | sed -n 's|^[Ll]ocation: .*/releases/tag/\(.*\)$|\1|p')
if [ -z "$MIL_TAG" ]; then
    echo "Error: could not resolve the latest MIL release tag." >&2
    exit 1
fi
MIL_FILE="mil-$MIL_TAG.tar.gz"
echo "    Latest MIL release: $MIL_TAG"

# Drop anything that could shadow the latest release.
find data -maxdepth 1 \( -name '*mil*.tar.gz' -o -name 'MIL.tar.gz' -o -name 'mil.json' \) \
    ! -name "$MIL_FILE" -print -delete

if [ -f "data/$MIL_FILE" ] && gzip -t "data/$MIL_FILE" 2>/dev/null; then
    echo "--> data/$MIL_FILE already present, skipping download."
else
    echo "--> Downloading $MIL_FILE..."
    curl -fL --retry 3 -o "data/$MIL_FILE.part" "$MIL_REPO/releases/download/$MIL_TAG/$MIL_FILE"
    mv "data/$MIL_FILE.part" "data/$MIL_FILE"
fi

echo "--> Downloading latest MDD.zip..."
curl -fL --retry 3 -o data/MDD.zip.part "$MDD_URL"
mv data/MDD.zip.part data/MDD.zip

echo "--> Data ready: data/MDD.zip, data/$MIL_FILE"
