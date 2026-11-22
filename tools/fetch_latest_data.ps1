#Requires -Version 5.1
# Downloads the latest MDD.zip and the latest MIL release tarball into data/.
#
# Older MIL tarballs and any stale data/mil.json are removed so that
# tools/generate_prefilled_db.ps1 can only pick up the release fetched here.
$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 renders a progress bar that slows large downloads to
# a crawl, and may default to TLS versions GitHub no longer accepts.
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$MddUrl = 'https://github.com/mammaldiversity/mammaldiversity.github.io/raw/master/assets/data/MDD.zip'
$MilApi = 'https://api.github.com/repos/mammaldiversity/asm-mil/releases/latest'
$MilRepo = 'https://github.com/mammaldiversity/asm-mil'

# Download to a .part file first so an interrupted download is never mistaken
# for a complete one.
function Save-Url {
    param([string]$Url, [string]$OutFile)
    $part = "$OutFile.part"
    Invoke-WebRequest -Uri $Url -OutFile $part -UseBasicParsing
    Move-Item -Path $part -Destination $OutFile -Force
}

Push-Location (Join-Path $PSScriptRoot '..')
try {
    New-Item -ItemType Directory -Path data -Force | Out-Null

    Write-Host "--> Resolving latest MIL release..."
    $headers = @{ 'User-Agent' = 'mdd-app-build' }
    if ($env:GH_TOKEN) { $headers['Authorization'] = "Bearer $env:GH_TOKEN" }
    $release = Invoke-RestMethod -Uri $MilApi -Headers $headers
    $milTag = $release.tag_name
    if (-not $milTag) {
        throw 'Could not resolve the latest MIL release tag.'
    }
    $milFile = "mil-$milTag.tar.gz"
    Write-Host "    Latest MIL release: $milTag"

    # Drop anything that could shadow the latest release.
    Get-ChildItem -Path data -File |
        Where-Object {
            ($_.Name -like '*mil*.tar.gz' -or $_.Name -eq 'MIL.tar.gz' -or $_.Name -eq 'mil.json') -and
            $_.Name -ne $milFile
        } |
        ForEach-Object {
            Write-Host "    Removing $($_.FullName)"
            Remove-Item $_.FullName -Force
        }

    $milTarget = Join-Path data $milFile
    if ((Test-Path $milTarget -PathType Leaf) -and (Get-Item $milTarget).Length -gt 0) {
        Write-Host "--> $milTarget already present, skipping download."
    }
    else {
        Write-Host "--> Downloading $milFile..."
        Save-Url "$MilRepo/releases/download/$milTag/$milFile" $milTarget
    }

    Write-Host "--> Downloading latest MDD.zip..."
    Save-Url $MddUrl (Join-Path data 'MDD.zip')

    Write-Host "--> Data ready: data/MDD.zip, $milTarget"
}
finally {
    Pop-Location
}
