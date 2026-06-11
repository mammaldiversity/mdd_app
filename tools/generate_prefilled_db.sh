#!/bin/bash
set -e

echo "========================================="
echo "   Generate Prefilled Database Script"
echo "========================================="

# Ensure we're in the project root
cd "$(dirname "$0")/.."

echo "--> Compiling Rust CLI (rust_lib_mdd)..."
cd rust
cargo build --release
cd ..

if [ -f "data/mil.json" ]; then
    MIL_PATH="data/mil.json"
elif [ -f "data/MIL.tar.gz" ]; then
    MIL_PATH="data/MIL.tar.gz"
else
    echo "Error: data/mil.json or data/MIL.tar.gz not found!"
    echo "Please ensure they are downloaded into the data/ directory before generating."
    exit 1
fi

if [ ! -f "data/MDD.zip" ]; then
    echo "Error: data/MDD.zip not found!"
    exit 1
fi

echo "--> Generating mdd.db using Rust CLI..."
# The Rust CLI will automatically spawn the generator subprocess
./target/release/rust_lib_mdd data/MDD.zip "$MIL_PATH"

# Verify generation
if [ ! -f "assets/data/mdd.db" ]; then
    echo "Error: assets/data/mdd.db was not generated successfully."
    exit 1
fi

echo "--> Database successfully generated at assets/data/mdd.db."
