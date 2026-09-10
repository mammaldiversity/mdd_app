#Requires -Version 5.1
param(
    [string]$MilPath
)

$ErrorActionPreference = 'Stop'

# Native commands don't throw on failure, so check their exit code explicitly.
function Invoke-Native {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Command"
    }
}

Write-Host "========================================="
Write-Host "   Generate Prefilled Database Script"
Write-Host "========================================="

# Ensure we're in the project root
Push-Location (Join-Path $PSScriptRoot '..')
try {
    Write-Host "--> Installing Rust CLI (rust_lib_mdd)..."
    Push-Location rust
    try {
        Invoke-Native { cargo install --path . --force }
    }
    finally {
        Pop-Location
    }

    if (-not $MilPath) {
        if (Test-Path 'data/mil.json' -PathType Leaf) {
            $MilPath = 'data/mil.json'
        }
        else {
            # Find dated MIL release or MIL tarball in data/ directory
            $milArchive = Get-ChildItem -Path data -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like 'mil-v*.tar.gz' -or $_.Name -like '*mil*.tar.gz' } |
                Sort-Object Name -Descending |
                Select-Object -First 1
            if (-not $milArchive) {
                Write-Host "Error: data/mil.json, data/mil-v*.tar.gz, or data/MIL.tar.gz not found!"
                Write-Host "Please ensure MIL archive is downloaded into the data/ directory before generating."
                exit 1
            }
            $MilPath = "data/$($milArchive.Name)"
        }
    }

    if (-not (Test-Path 'data/MDD.zip' -PathType Leaf)) {
        Write-Host "Error: data/MDD.zip not found!"
        exit 1
    }

    Write-Host "--> Generating mdd.db using Rust CLI with named arguments..."
    Write-Host "    MDD: data/MDD.zip"
    Write-Host "    MIL: $MilPath"
    Invoke-Native { rust_lib_mdd --mdd data/MDD.zip --mil $MilPath }

    # Verify generation
    if (-not (Test-Path 'assets/data/mdd.db' -PathType Leaf)) {
        Write-Host "Error: assets/data/mdd.db was not generated successfully."
        exit 1
    }

    Write-Host "--> Database successfully generated at assets/data/mdd.db."
}
finally {
    Pop-Location
}
