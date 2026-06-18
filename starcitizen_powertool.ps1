<#▄█    █▄     ▄████████    ▄████████    ▄████████         ▄████████    ▄████████
 ███    ███   ███    ███   ███    ███   ███    ███        ███    ███   ███    ███
 ███    ███   ███    ███   ███    █▀    ███    █▀ github/ ███    ███   ███    █▀
 ███    ███  ▄███▄▄▄▄██▀   ███         ▄███▄▄▄ troublenz/ ███    ███  ▄███▄▄▄
 ███    ███ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀  SC-VRse ▀███████████ ▀▀███▀▀▀
 ███    ███ ▀███████████          ███   ███    █▄         ███    ███   ███    █▄
 ███    ███   ███    ███    ▄█    ███   ███    ███        ███    ███   ███    ███
  ▀██████▀    ███    ███  ▄████████▀    ██████████        ███    █▀    ██████████
              ███    ███  SC/VR Powertools - Attribute Editor  Author: @troublenz
#>

$scriptVersion = "0.5.9"

$scbuild = "4.8"
$branch = "LIVE"             # PTU , LIVE, HOTFIX etc

$debug = $false

$BackupFolderName = "VRSE AE Backup"
$profileContent = @()
$script:profileArray = [System.Collections.ArrayList]@()
$script:loadedProfile = $false

$moduleDir = Join-Path $PSScriptRoot 'modules'
$moduleFiles = @(
    '1.functions.ps1',
    '2.buildpages.ps1',
    '3.properties.ps1',
    '4.keybinds.ps1',
    '5.splash.ps1'
)

$commonChildPath = "user\client\0\Profiles\default"


# Load the required modules
foreach ($file in $moduleFiles) {
    $fullPath = Join-Path $moduleDir $file
    if (Test-Path $fullPath) {
        if ($debug) {Write-Host "Loading module: $file" -ForegroundColor Cyan}
        . $fullPath          # dot‑source – import into current scope
    } else {
        throw "Required module file not found: $fullPath"
    }
}
