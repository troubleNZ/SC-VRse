# install.ps1 - One-liner installer for SC-VRse

param(
    [string]$Repo = 'https://raw.githubusercontent.com/troubleNZ/SC-VRse',
    [string]$BranchOrTag = 'refs/heads/main',   # change to a tag if desired
    [string]$InstallDir = "$HOME\SC-VRse"        # default install location
)

# Ensure console uses UTF-8 for proper ellipsis display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ──────────────────────────────────────
# 1. Prepare working directory
if (-Not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# ──────────────────────────────────────
# 2. List of files that need to be downloaded.
$files = @(
    'starcitizen_powertool.ps1',
    'modules/1.functions.ps1',
    'modules/2.buildpages.ps1',
    'modules/3.properties.ps1',
    'modules/4.keybinds.ps1',
    'modules/5.splash.ps1'
    # Add any other .ps1, .xml etc. you want to ship
)

foreach ($path in $files) {
    $rawUrl = "$Repo/$BranchOrTag/$path"
    Write-Host ("Downloading {0}..." -f $rawUrl)
    try {
        $content = Invoke-WebRequest -Uri $rawUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    } catch {
        Write-Warning "Failed to download $rawUrl - skipping."
        continue
    }
    $targetPath = Join-Path $InstallDir $path
    $dirName = Split-Path $targetPath -Parent
    if (-Not (Test-Path $dirName)) { New-Item -ItemType Directory -Path $dirName | Out-Null }
    Set-Content -Path $targetPath -Value $content -Encoding UTF8
}

# ──────────────────────────────────────
Write-Host "`nSC-VRse installed successfully to $InstallDir"
Write-Host "Run any script directly from $InstallDir, e.g. `.\"