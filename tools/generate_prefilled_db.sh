#!/bin/bash
# Generates assets/data/mdd.db, assets/data/mil.json, assets/mil-images/ and
# assets/data/data_version.json from MDD.zip and a MIL release tarball.
#
# Usage:
#   tools/generate_prefilled_db.sh              # fetch latest data, then generate
#   tools/generate_prefilled_db.sh --offline    # use the newest tarball already in data/
#   tools/generate_prefilled_db.sh PATH         # use a specific MIL tarball (offline)
set -euo pipefail

echo "========================================="
echo "   Generate Prefilled Database Script"
echo "========================================="

# Ensure we're in the project root
cd "$(dirname "$0")/.."

OFFLINE=0
MIL_PATH=""
for arg in "$@"; do
    case "$arg" in
        --offline) OFFLINE=1 ;;
        *) MIL_PATH="$arg"; OFFLINE=1 ;;
    esac
done

if [ "$OFFLINE" -eq 0 ]; then
    ./tools/fetch_latest_data.sh
fi

echo "--> Installing Rust CLI (rust_lib_mdd)..."
cargo install --path rust --force

if [ -z "$MIL_PATH" ]; then
    # Version sort so that e.g. mil-v2026-10-31.2 wins over mil-v2026-10-31.
    MIL_PATH=$(find data -maxdepth 1 \( -name "mil-v*.tar.gz" -o -name "MIL.tar.gz" \) 2>/dev/null \
        | sort -V | tail -n 1)
    if [ -z "$MIL_PATH" ]; then
        echo "Error: no data/mil-v*.tar.gz found. Run tools/fetch_latest_data.sh first." >&2
        exit 1
    fi
fi

if [ ! -f "data/MDD.zip" ]; then
    echo "Error: data/MDD.zip not found!" >&2
    exit 1
fi

# Images come from the tarball; start from an empty directory so images that
# were removed or renumbered in a newer MIL release do not linger.
case "$MIL_PATH" in
    *.tar.gz|*.tgz) rm -rf assets/mil-images ;;
    *) echo "Warning: $MIL_PATH is not a tarball; assets/mil-images is left unchanged." ;;
esac
rm -f assets/data/mdd.db assets/data/mil.json assets/data/data_version.json

echo "--> Generating mdd.db using Rust CLI..."
echo "    MDD: data/MDD.zip"
echo "    MIL: $MIL_PATH"
rust_lib_mdd --mdd data/MDD.zip --mil "$MIL_PATH"

# Verify generation
for f in assets/data/mdd.db assets/data/mil.json; do
    if [ ! -s "$f" ]; then
        echo "Error: $f was not generated." >&2
        exit 1
    fi
done
IMAGE_COUNT=$(find assets/mil-images -maxdepth 1 -name '*.webp' 2>/dev/null | wc -l | tr -d ' ')
if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo "Error: no MIL images in assets/mil-images." >&2
    exit 1
fi

# Stamp the data the bundle was built from. The app uses it to decide
# whether to replace an installed database.
if command -v sha256sum >/dev/null 2>&1; then
    MDD_SHA=$(sha256sum data/MDD.zip | cut -d' ' -f1)
else
    MDD_SHA=$(shasum -a 256 data/MDD.zip | cut -d' ' -f1)
fi
MIL_RELEASE=$(basename "$MIL_PATH")
MIL_RELEASE="${MIL_RELEASE#mil-}"
MIL_RELEASE="${MIL_RELEASE%.tar.gz}"
MIL_RELEASE="${MIL_RELEASE%.tgz}"
cat > assets/data/data_version.json <<EOF
{
  "mil_release": "$MIL_RELEASE",
  "mdd_sha256": "$MDD_SHA",
  "mil_image_count": $IMAGE_COUNT
}
EOF

echo "--> Generated assets/data/mdd.db, assets/data/mil.json and $IMAGE_COUNT MIL images."
echo "    MIL release: $MIL_RELEASE"
