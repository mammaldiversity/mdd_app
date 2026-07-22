#!/bin/bash
set -e

echo "========================================="
echo "   Generate Prefilled Database Script"
echo "========================================="

# Ensure we're in the project root
cd "$(dirname "$0")/.."

echo "--> Installing Rust CLI (rust_lib_mdd)..."
cd rust
cargo install --path . --force
cd ..

if [ -n "$1" ]; then
    MIL_PATH="$1"
elif [ -f "data/mil.json" ]; then
    MIL_PATH="data/mil.json"
else
    # Find dated MIL release or MIL tarball in data/ directory
    MIL_PATH=$(find data -maxdepth 1 \( -name "mil-v*.tar.gz" -o -name "MIL.tar.gz" -o -name "*mil*.tar.gz" \) 2>/dev/null | sort -r | head -n 1)
    if [ -z "$MIL_PATH" ]; then
        echo "Error: data/mil.json, data/mil-v*.tar.gz, or data/MIL.tar.gz not found!"
        echo "Please ensure MIL archive is downloaded into the data/ directory before generating."
        exit 1
    fi
fi

if [ ! -f "data/MDD.zip" ]; then
    echo "Error: data/MDD.zip not found!"
    exit 1
fi

echo "--> Generating mdd.db using Rust CLI with named arguments..."
echo "    MDD: data/MDD.zip"
echo "    MIL: $MIL_PATH"
rust_lib_mdd --mdd data/MDD.zip --mil "$MIL_PATH"

# Verify generation
if [ ! -f "assets/data/mdd.db" ]; then
    echo "Error: assets/data/mdd.db was not generated successfully."
    exit 1
fi

echo "--> Database successfully generated at assets/data/mdd.db."
