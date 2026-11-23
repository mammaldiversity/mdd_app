#!/bin/bash
# Builds the snap from the latest MDD and MIL data.
#
# snapcraft does the whole build (see snap/snapcraft.yaml): it fetches the
# latest MDD.zip and MIL release, regenerates the database, mil.json and MIL
# images, builds the Linux bundle, then packs it.
# Extra arguments are passed to snapcraft (e.g. --use-lxd).
set -euo pipefail

cd "$(dirname "$0")/.."

echo "--> Packing snap..."
snapcraft pack "$@"
