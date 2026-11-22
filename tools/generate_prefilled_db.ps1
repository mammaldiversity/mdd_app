#Requires -Version 5.1
# Generates assets/data/mdd.db, assets/data/mil.json, assets/mil-images/ and
# assets/data/data_version.json from MDD.zip and a MIL release tarball.
#
# Usage:
#   .\tools\generate_prefilled_db.ps1                  # fetch latest data, then generate
#   .\tools\generate_prefilled_db.ps1 -Offline         # use the newest tarball already in data/
#   .\tools\generate_prefilled_db.ps1 -MilPath PATH    # use a specific MIL tarball (offline)
param(
    [string]$MilPath,
    [switch]$Offline
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

# Sort key for MIL tarballs so that e.g. mil-v2026-10-31.2 wins over
# mil-v2026-10-31 (a plain name sort gets this wrong).
function Get-MilSortKey {
    param([string]$Name)
    if ($Name -match '^mil-v(\d{4})-(\d{2})-(\d{2})(?:\.(\d+))?\.tar\.gz$') {
        $point = if ($Matches[4]) { [int]$Matches[4] } else { 0 }
        return '{0}{1}{2}.{3:D6}' -f $Matches[1], $Matches[2], $Matches[3], $point
    }
    return '0'
}

Write-Host "========================================="
Write-Host "   Generate Prefilled Database Script"
Write-Host "========================================="

# Ensure we're in the project root
Push-Location (Join-Path $PSScriptRoot '..')
try {
    if ($MilPath) { $Offline = $true }
    if (-not $Offline) {
        & (Join-Path $PSScriptRoot 'fetch_latest_data.ps1')
    }

    Write-Host "--> Installing Rust CLI (rust_lib_mdd)..."
    Invoke-Native { cargo install --path rust --force }

    if (-not $MilPath) {
        $milArchive = Get-ChildItem -Path data -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'mil-v*.tar.gz' -or $_.Name -eq 'MIL.tar.gz' } |
            Sort-Object { Get-MilSortKey $_.Name } |
            Select-Object -Last 1
        if (-not $milArchive) {
            throw 'No data/mil-v*.tar.gz found. Run tools/fetch_latest_data.ps1 first.'
        }
        $MilPath = "data/$($milArchive.Name)"
    }

    if (-not (Test-Path 'data/MDD.zip' -PathType Leaf)) {
        throw 'data/MDD.zip not found!'
    }

    # Images come from the tarball; start from an empty directory so images
    # that were removed or renumbered in a newer MIL release do not linger.
    if ($MilPath -like '*.tar.gz' -or $MilPath -like '*.tgz') {
        if (Test-Path 'assets/mil-images') {
            Remove-Item 'assets/mil-images' -Recurse -Force
        }
    }
    else {
        Write-Host "Warning: $MilPath is not a tarball; assets/mil-images is left unchanged."
    }
    foreach ($f in 'assets/data/mdd.db', 'assets/data/mil.json', 'assets/data/data_version.json') {
        if (Test-Path $f) { Remove-Item $f -Force }
    }

    Write-Host "--> Generating mdd.db using Rust CLI..."
    Write-Host "    MDD: data/MDD.zip"
    Write-Host "    MIL: $MilPath"
    Invoke-Native { rust_lib_mdd --mdd data/MDD.zip --mil $MilPath }

    # Verify generation
    foreach ($f in 'assets/data/mdd.db', 'assets/data/mil.json') {
        if (-not (Test-Path $f -PathType Leaf) -or (Get-Item $f).Length -eq 0) {
            throw "$f was not generated."
        }
    }
    $imageCount = @(Get-ChildItem -Path 'assets/mil-images' -Filter '*.webp' -File -ErrorAction SilentlyContinue).Count
    if ($imageCount -eq 0) {
        throw 'No MIL images in assets/mil-images.'
    }

    # Stamp the data the bundle was built from. The snap build checks it
    # against the latest upstream release, and the app uses it to decide
    # whether to replace an installed database. Must match the format written
    # by generate_prefilled_db.sh.
    $mddSha = (Get-FileHash -Path 'data/MDD.zip' -Algorithm SHA256).Hash.ToLowerInvariant()
    $milRelease = Split-Path $MilPath -Leaf
    $milRelease = $milRelease -replace '^mil-', '' -replace '\.tar\.gz$', '' -replace '\.tgz$', ''
    $stamp = @"
{
  "mil_release": "$milRelease",
  "mdd_sha256": "$mddSha",
  "mil_image_count": $imageCount
}
"@
    # WriteAllText writes UTF-8 without a BOM; Set-Content -Encoding UTF8 on
    # Windows PowerShell 5.1 adds one, which breaks jsonDecode in the app.
    $stampPath = Join-Path (Get-Location) 'assets/data/data_version.json'
    [IO.File]::WriteAllText($stampPath, ($stamp -replace "`r`n", "`n") + "`n")

    Write-Host "--> Generated assets/data/mdd.db, assets/data/mil.json and $imageCount MIL images."
    Write-Host "    MIL release: $milRelease"
}
finally {
    Pop-Location
}
