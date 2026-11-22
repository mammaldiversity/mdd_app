#!/bin/bash
# Builds the snap from the latest MDD and MIL data.
#
# Fetches the latest MDD.zip and MIL release, regenerates the database,
# mil.json and MIL images, rebuilds the Linux bundle, then runs snapcraft.
# Extra arguments are passed to snapcraft (e.g. --use-lxd).
set -euo pipefail

cd "$(dirname "$0")/.."

./tools/generate_prefilled_db.sh

echo "--> Building Linux bundle..."
flutter pub get
# Clean so no assets from an earlier build survive in the bundle.
rm -rf build/linux/x64/release/bundle
flutter build linux --release

echo "--> Packing snap..."
snapcraft pack "$@"
