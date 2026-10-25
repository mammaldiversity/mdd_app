#Requires -Version 5.1
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
Write-Host "   MDD App Database & Build Script"
Write-Host "========================================="

# Ensure we're in the project root
Push-Location (Join-Path $PSScriptRoot '..')
try {
    # 1. Compile and run Rust CLI for DB generation
    Write-Host "--> Generating Database..."
    & (Join-Path $PSScriptRoot 'generate_prefilled_db.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw "Database generation failed with exit code $LASTEXITCODE."
    }

    # 2. Build Flutter Apps
    Write-Host "--> Running flutter pub get..."
    Invoke-Native { flutter pub get }

    Write-Host "--> Running flutter analyze..."
    Invoke-Native { flutter analyze }

    Write-Host "--> Building Android (APK)..."
    Invoke-Native { flutter build apk --release --split-per-abi }

    Write-Host "--> Building Windows..."
    # $IsWindows is undefined on Windows PowerShell 5.1, which only runs on Windows.
    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        Invoke-Native { flutter build windows --release }
    }
    else {
        Write-Host "Skipping Windows build (not on a Windows host)."
    }

    Write-Host "========================================="
    Write-Host "   Build process complete."
    Write-Host "========================================="
}
finally {
    Pop-Location
}
