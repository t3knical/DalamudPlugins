<#
.SYNOPSIS
    Builds the configured plugins, copies their packaged zips into this repo, and
    regenerates repo.json (the plugin master list Dalamud reads).

.DESCRIPTION
    This is a distribution-only repository: plugin SOURCE lives elsewhere (see
    tools/plugins.json), and only the built artifacts are published here.

    For each plugin the script will:
      1. dotnet build -c Release   (skip with -NoBuild)
      2. locate the DalamudPackager output (<InternalName>/latest.zip)
      3. scan the zip for anything that must never be published
      4. copy zip + resolved manifest into plugins/<InternalName>/
      5. add an entry to repo.json with the correct download links

.PARAMETER NoBuild
    Use the existing build output instead of rebuilding.

.PARAMETER Plugin
    Only process the named plugin (InternalName). Defaults to all.

.EXAMPLE
    .\tools\Update-Repo.ps1
    .\tools\Update-Repo.ps1 -Plugin Hunter
    .\tools\Update-Repo.ps1 -NoBuild
#>
[CmdletBinding()]
param(
    [switch]$NoBuild,
    [string]$Plugin
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repoRoot   = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $PSScriptRoot 'plugins.json'
$pluginsDir = Join-Path $repoRoot 'plugins'
$licenseDir = Join-Path $repoRoot 'licenses'

if (-not (Test-Path $configPath)) { throw "Missing config: $configPath" }
$config = Get-Content $configPath -Raw | ConvertFrom-Json

if (-not (Test-Path $pluginsDir)) { New-Item -ItemType Directory -Path $pluginsDir | Out-Null }
if (-not (Test-Path $licenseDir)) { New-Item -ItemType Directory -Path $licenseDir | Out-Null }

# Files that must never end up in a published zip.
$forbiddenNames = @(
    '*.pdb', '.env', '.env.*', 'secrets.json', 'appsettings.Development.json',
    '*.local.json', '*.user', 'settings.local.json',
    # Runtime debris - debug logs can capture session/party/character detail
    '*.log', '*debug*', '*.tmp', '*.bak', '*.dmp'
)
# Config keys that would indicate baked-in credentials.
$secretPattern = '(?i)"(discord(bot)?token|bottoken|clientsecret|client_secret|apikey|api_key|password|access_token|refresh_token|webhookurl)"\s*:\s*"[^"]{8,}"'

function Test-ZipSafe {
    param([string]$ZipPath, [string]$Name)

    $problems = @()
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        foreach ($entry in $zip.Entries) {
            foreach ($pattern in $forbiddenNames) {
                if ($entry.Name -like $pattern) {
                    $problems += "contains $($entry.FullName)"
                }
            }

            # Peek inside small json files for credential-shaped values
            if ($entry.Name -like '*.json' -and $entry.Length -lt 512000) {
                $reader = New-Object System.IO.StreamReader($entry.Open())
                try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }

                if ($text -match $secretPattern) {
                    $problems += "possible credential in $($entry.FullName)"
                }
                if ($text -match '(?i)C:\\+Users\\+[^\\"]+') {
                    $problems += "local user path in $($entry.FullName)"
                }
            }
        }
    }
    finally { $zip.Dispose() }

    return $problems
}

function Find-PackagedZip {
    param([string]$ProjectDir, [string]$InternalName)

    # DalamudPackager writes <OutputPath>/<InternalName>/latest.zip. OutputPath varies
    # per project, so search the project tree and its parent for the newest match.
    $searchRoots = @($ProjectDir, (Split-Path -Parent $ProjectDir)) | Select-Object -Unique

    $candidates = foreach ($root in $searchRoots) {
        if (-not (Test-Path $root)) { continue }
        Get-ChildItem -Path $root -Filter 'latest.zip' -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Directory.Name -eq $InternalName -and $_.FullName -notmatch '\\obj\\' }
    }

    return $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

$entries = @()
$failed  = @()

foreach ($p in $config.plugins) {
    if ($Plugin -and $p.internalName -ne $Plugin) { continue }

    Write-Host ""
    Write-Host "=== $($p.internalName) ===" -ForegroundColor Cyan

    $projectPath = Join-Path $repoRoot $p.project
    if (-not (Test-Path $projectPath)) {
        Write-Warning "  Project not found: $projectPath"
        $failed += $p.internalName
        continue
    }
    $projectDir = Split-Path -Parent (Resolve-Path $projectPath)

    if (-not $NoBuild) {
        Write-Host "  Building..." -ForegroundColor DarkGray
        # ContinuousIntegrationBuild normalises embedded source paths so local
        # directory names never end up inside the published assembly.
        & dotnet build $projectPath -c Release -p:ContinuousIntegrationBuild=true --nologo -v quiet
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "  Build FAILED"
            $failed += $p.internalName
            continue
        }
    }

    $zip = Find-PackagedZip -ProjectDir $projectDir -InternalName $p.internalName
    if (-not $zip) {
        Write-Warning "  No packaged zip found (expected <output>/$($p.internalName)/latest.zip). Is DalamudPackager referenced?"
        $failed += $p.internalName
        continue
    }
    Write-Host "  Package: $($zip.FullName)" -ForegroundColor DarkGray

    # Safety gate - refuse to publish anything questionable
    $problems = Test-ZipSafe -ZipPath $zip.FullName -Name $p.internalName
    if ($problems.Count -gt 0) {
        Write-Warning "  BLOCKED - not published:"
        foreach ($problem in $problems) { Write-Warning "    - $problem" }
        $failed += $p.internalName
        continue
    }

    $manifestSrc = Join-Path $zip.Directory.FullName "$($p.internalName).json"
    if (-not (Test-Path $manifestSrc)) {
        Write-Warning "  Manifest not found next to zip: $manifestSrc"
        $failed += $p.internalName
        continue
    }
    $manifest = Get-Content $manifestSrc -Raw | ConvertFrom-Json

    # Publish artifacts
    $outDir = Join-Path $pluginsDir $p.internalName
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
    Copy-Item $zip.FullName (Join-Path $outDir 'latest.zip') -Force
    Copy-Item $manifestSrc  (Join-Path $outDir "$($p.internalName).json") -Force

    # Carry the upstream licence for forks so redistribution stays compliant
    if ($p.license) {
        $licenseSrc = Join-Path $repoRoot $p.license
        if (Test-Path $licenseSrc) {
            Copy-Item $licenseSrc (Join-Path $licenseDir "$($p.internalName)-LICENSE") -Force
            Write-Host "  Licence carried across" -ForegroundColor DarkGray
        }
        else {
            Write-Warning "  Declared licence file missing: $licenseSrc"
        }
    }
    elseif ($p.fork) {
        Write-Warning "  Fork of $($p.fork.upstream) has no licence file declared - verify redistribution terms."
    }

    # repo.json entry
    $download = "$($config.baseUrl)/plugins/$($p.internalName)/latest.zip"
    $manifest | Add-Member -NotePropertyName 'IsHide'              -NotePropertyValue $false   -Force
    $manifest | Add-Member -NotePropertyName 'IsTestingExclusive'  -NotePropertyValue $false   -Force
    $manifest | Add-Member -NotePropertyName 'DownloadCount'       -NotePropertyValue 0        -Force
    $manifest | Add-Member -NotePropertyName 'LastUpdate'          -NotePropertyValue ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) -Force
    $manifest | Add-Member -NotePropertyName 'DownloadLinkInstall' -NotePropertyValue $download -Force
    $manifest | Add-Member -NotePropertyName 'DownloadLinkUpdate'  -NotePropertyValue $download -Force
    $manifest | Add-Member -NotePropertyName 'DownloadLinkTesting' -NotePropertyValue $download -Force

    if (-not $manifest.RepoUrl) {
        $manifest | Add-Member -NotePropertyName 'RepoUrl' -NotePropertyValue $config.repoUrl -Force
    }

    $entries += $manifest
    Write-Host "  OK  v$($manifest.AssemblyVersion)  (API $($manifest.DalamudApiLevel))" -ForegroundColor Green
}

# Preserve entries for plugins we skipped this run
$repoJsonPath = Join-Path $repoRoot 'repo.json'
if ($Plugin -and (Test-Path $repoJsonPath)) {
    $existing = Get-Content $repoJsonPath -Raw | ConvertFrom-Json
    $updatedNames = $entries | ForEach-Object { $_.InternalName }
    foreach ($old in $existing) {
        if ($updatedNames -notcontains $old.InternalName) { $entries += $old }
    }
}

if ($entries.Count -eq 0) {
    Write-Warning "Nothing to publish - repo.json left unchanged."
}
else {
    # Force an array even with a single entry; Dalamud requires a JSON array.
    $json = ConvertTo-Json -InputObject @($entries) -Depth 10
    # UTF-8 WITHOUT BOM - Set-Content -Encoding UTF8 emits a BOM on PowerShell 5.1,
    # which trips strict JSON parsers reading the raw file.
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($repoJsonPath, $json, $utf8NoBom)
    Write-Host ""
    Write-Host "repo.json written with $($entries.Count) plugin(s): $repoJsonPath" -ForegroundColor Green
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Warning "Not published: $($failed -join ', ')"
}

Write-Host ""
Write-Host "Next: git add -A; git commit -m 'Update plugins'; git push" -ForegroundColor Yellow
