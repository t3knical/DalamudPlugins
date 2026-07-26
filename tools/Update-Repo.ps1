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

.PARAMETER Publish
    Upload each package to a GitHub Release (tag: <InternalName>-v<version>).
    Release assets are what make download counts possible - GitHub reports a
    download_count per asset, which the update-download-counts workflow sums
    back into repo.json. Raw files in the repo report nothing.

    Requires either the GitHub CLI (gh) on PATH, or $env:GITHUB_TOKEN set to a
    token with 'contents: write' on the repository.

.EXAMPLE
    .\tools\Update-Repo.ps1                    # build + package + write repo.json
    .\tools\Update-Repo.ps1 -Publish           # ...and upload releases
    .\tools\Update-Repo.ps1 -Plugin HunterV2 -Publish
    .\tools\Update-Repo.ps1 -NoBuild -Publish
#>
[CmdletBinding()]
param(
    [switch]$NoBuild,
    [string]$Plugin,
    [switch]$Publish
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

function Get-RepoSlug {
    param([string]$RepoUrl)
    # https://github.com/owner/name -> owner/name
    if ($RepoUrl -match 'github\.com/([^/]+)/([^/\s]+?)(\.git)?/?$') {
        return "$($Matches[1])/$($Matches[2])"
    }
    throw "Could not parse owner/repo from repoUrl '$RepoUrl'"
}

function Publish-Release {
    <#
        Creates (or reuses) the release for this plugin version and uploads the
        zip as <InternalName>.zip. Returns the browser download URL.

        Note: re-uploading over an existing asset resets that asset's download
        count, so bump the version rather than republishing the same one.
    #>
    param(
        [string]$Slug,
        [string]$Tag,
        [string]$AssetPath,
        [string]$AssetName,
        [string]$Title
    )

    $downloadUrl = "https://github.com/$Slug/releases/download/$Tag/$AssetName"

    if ($script:GhAvailable) {
        # NOTE: $ErrorActionPreference = 'Stop' makes PowerShell 5.1 treat a native
        # command's stderr as a terminating error. "gh release view" writes to stderr
        # whenever the release does not exist yet - the normal first-publish case - so
        # native calls run with 'Continue' and are judged on $LASTEXITCODE instead.
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $viewOutput = & gh release view $Tag --repo $Slug 2>&1
            $releaseExists = ($LASTEXITCODE -eq 0)

            if (-not $releaseExists) {
                Write-Host "  Creating release $Tag" -ForegroundColor DarkGray
                $createOutput = & gh release create $Tag --repo $Slug --title $Title `
                    --notes "Automated release of $Title." 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "gh release create failed for ${Tag}: $($createOutput -join ' ')"
                }
            }

            # The asset must be UPLOADED under the name <InternalName>.zip: the download
            # URL embeds the filename, and the counter workflow identifies plugins by it.
            # "gh release upload file#label" only sets a display label and would leave the
            # asset named latest.zip, so stage a correctly named copy instead.
            $staged = Join-Path ([System.IO.Path]::GetTempPath()) $AssetName
            Copy-Item $AssetPath $staged -Force
            try {
                $uploadOutput = & gh release upload $Tag $staged --repo $Slug --clobber 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "gh release upload failed for ${Tag}: $($uploadOutput -join ' ')"
                }
            }
            finally {
                Remove-Item $staged -Force -ErrorAction SilentlyContinue
            }
        }
        finally {
            $ErrorActionPreference = $prevEap
        }
        return $downloadUrl
    }

    # REST fallback - no gh required, just a token
    $headers = @{
        Authorization          = "Bearer $($script:GitHubToken)"
        Accept                 = 'application/vnd.github+json'
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent'           = 'DalamudPlugins-Update-Repo'
    }

    $release = $null
    try {
        $release = Invoke-RestMethod -Method Get -Headers $headers `
            -Uri "https://api.github.com/repos/$Slug/releases/tags/$Tag"
    }
    catch {
        $body = @{ tag_name = $Tag; name = $Title; body = "Automated release of $Title." } | ConvertTo-Json
        $release = Invoke-RestMethod -Method Post -Headers $headers -ContentType 'application/json' `
            -Uri "https://api.github.com/repos/$Slug/releases" -Body $body
    }

    # Replace an existing asset of the same name (resets its count - bump versions instead)
    foreach ($asset in @($release.assets)) {
        if ($asset.name -eq $AssetName) {
            Invoke-RestMethod -Method Delete -Headers $headers `
                -Uri "https://api.github.com/repos/$Slug/releases/assets/$($asset.id)" | Out-Null
        }
    }

    $uploadUrl = ($release.upload_url -replace '\{\?name,label\}', '') + "?name=$AssetName"
    Invoke-RestMethod -Method Post -Headers $headers -ContentType 'application/zip' `
        -Uri $uploadUrl -InFile $AssetPath | Out-Null

    return $downloadUrl
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

# Carry existing download counts forward so a publish never zeroes them between
# runs of the update-download-counts workflow.
$repoJsonPath   = Join-Path $repoRoot 'repo.json'
$existingCounts = @{}
if (Test-Path $repoJsonPath) {
    $priorText = [System.IO.File]::ReadAllText($repoJsonPath)
    if ($priorText.Trim()) {
        foreach ($prior in (ConvertFrom-Json $priorText)) {
            if ($prior.InternalName) { $existingCounts[$prior.InternalName] = $prior.DownloadCount }
        }
    }
}

# Publishing prerequisites
$script:GhAvailable = $false
$script:GitHubToken = $env:GITHUB_TOKEN
$repoSlug = $null
if ($Publish) {
    $repoSlug = Get-RepoSlug -RepoUrl $config.repoUrl
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $script:GhAvailable = $true
        Write-Host "Publishing to $repoSlug via GitHub CLI" -ForegroundColor DarkGray
    }
    elseif ($script:GitHubToken) {
        Write-Host "Publishing to $repoSlug via REST API (GITHUB_TOKEN)" -ForegroundColor DarkGray
    }
    else {
        throw @"
-Publish needs GitHub credentials. Either:
  1. Install the GitHub CLI and sign in:   winget install GitHub.cli   then   gh auth login
  2. Or set a token with 'contents: write': `$env:GITHUB_TOKEN = '<token>'
"@
    }
}

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

    # Download link: a GitHub Release asset when publishing (so downloads are
    # counted), otherwise the raw file in this repo.
    $download = "$($config.baseUrl)/plugins/$($p.internalName)/latest.zip"
    if ($Publish) {
        $tag       = "$($p.internalName)-v$($manifest.AssemblyVersion)"
        $assetName = "$($p.internalName).zip"
        try {
            $download = Publish-Release -Slug $repoSlug -Tag $tag -AssetPath $zip.FullName `
                                        -AssetName $assetName -Title "$($manifest.Name) $($manifest.AssemblyVersion)"
            Write-Host "  Released: $tag" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "  Release upload FAILED: $($_.Exception.Message)"
            $failed += $p.internalName
            continue
        }
    }

    # Preserve the count the workflow last wrote; it refreshes from the API on schedule.
    $priorCount = 0
    if ($existingCounts.ContainsKey($p.internalName) -and $existingCounts[$p.internalName]) {
        $priorCount = $existingCounts[$p.internalName]
    }

    $manifest | Add-Member -NotePropertyName 'IsHide'              -NotePropertyValue $false      -Force
    $manifest | Add-Member -NotePropertyName 'IsTestingExclusive'  -NotePropertyValue $false      -Force
    $manifest | Add-Member -NotePropertyName 'DownloadCount'       -NotePropertyValue $priorCount -Force
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
