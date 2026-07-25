# install.ps1 - online installer for SC-VRse
# ──────────────────────────────────────
# 0. Automatic Execution Policy Check & Bypass

param(
    [switch]$NoPrompt,      # Skip prompts for automated runs
    [switch]$Verbose,       # Enable verbose output
    [string]$Repo = 'https://raw.githubusercontent.com/troubleNZ/SC-VRse',
    [string]$BranchOrTag = 'refs/heads/main'  # change to a tag if desired
)

# Function to check and set execution policy
function Set-ScriptExecutionPolicy {
    param()
    
    $currentPolicy = Get-ExecutionPolicy -List | Where-Object Scope -eq 'CurrentUser'
    $effectivePolicy = Get-ExecutionPolicy
    
    if ($effectivePolicy -match 'Restricted|Unrestricted' -and $effectivePolicy -ne 'RemoteSigned') {
        Write-Host "Setting execution policy for current user scope..." -ForegroundColor Yellow
        
        try {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Confirm:$false | Out-Null
            
            # Verify the change took effect
            $newPolicy = Get-ExecutionPolicy -List | Where-Object Scope -eq 'CurrentUser'
            Write-Host "Execution policy set to: $($newPolicy.ExecutionPolicy)" -ForegroundColor Green
            
            return $true
        } catch {
            Write-Host "Failed to change execution policy. Attempting bypass method..." -ForegroundColor Red
            
            # Fallback: Try the bypass flag approach
            if ($PSVersionTable.PSVersion.Major -ge 5) {
                Write-Host "Consider running this script with:" -ForegroundColor Yellow
                Write-Host "powershell.exe -ExecutionPolicy Bypass -File '$($MyInvocation.ScriptPath)'" -ForegroundColor Cyan
            }
            return $false
        }
    }
    
    Write-Host "Execution policy is already set to: $($effectivePolicy)" -ForegroundColor Green
    return $true
}

# Only run the bypass if not already bypassed
if ($env:POWERSHELL_BYPASS -ne '1' -and (-not $NoPrompt)) {
    Set-ScriptExecutionPolicy
}

# Ensure console uses UTF-8 for proper ellipsis display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# ──────────────────────────────────────
# Interactive Install Location Selection
function Get-InstallLocation {
    param()
    
    Write-Host "Select installation location:" -ForegroundColor Cyan
    
    # Display menu options
    Write-Host "  [1] Current directory" -ForegroundColor White
    Write-Host "  [2] $HOME\SC-VRse (default location)" -ForegroundColor Gray
    Write-Host "  [3] Custom path (enter your own location)" -ForegroundColor Gray
    
    $choice = Read-Host "Enter selection (1, 2, or 3)"

    switch ($choice) {
        '1' {
            # Current directory
            return Get-Location | Select-Object -ExpandProperty Path
        }
        '2' {
            # Default HOME location
            return "$HOME\SC-VRse"
        }
        '3' {
                # Custom path
                Write-Host "Please enter a full Windows path (e.g., C:\Program Files\SC-VRse or D:\Games\VRse)" -ForegroundColor Yellow
                $customPath = Read-Host "Custom Path"
                
                if ([string]::IsNullOrWhiteSpace($customPath)) {
                    Write-Host "No path provided, defaulting to $HOME\SC-VRse" -ForegroundColor DarkYellow
                    return "$HOME\SC-VRse"
                }
                
                # Normalize the path (handle both forward and backward slashes)
                $normalizedPath = $customPath.Replace('/', '\')
                
                # Ensure path doesn't end with backslash for consistency
                if ($normalizedPath -match '\\$' -and $normalizedPath.Length -gt 3) {
                    $normalizedPath = $normalizedPath.TrimEnd('\')
                }
                
                return $normalizedPath
        }
        default {
            Write-Host "Invalid selection, defaulting to $HOME\SC-VRse" -ForegroundColor DarkYellow
            return "$HOME\SC-VRse"
        }
    }
}

# Get the install location from user prompt
$InstallDir = Get-InstallLocation


# ──────────────────────────────────────
# Prepare working directory
if (-Not (Test-Path $InstallDir)) {
    Write-Host "Creating installation directory at: $InstallDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
    
    # Verify creation succeeded
    if (Test-Path $InstallDir) {
        Write-Host "✓ Directory created successfully!" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Failed to create directory. Please check permissions." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Installation directory confirmed: $InstallDir" -ForegroundColor Green


# ──────────────────────────────────────
# List of files that need to be downloaded.
$files = @(
    'starcitizen_powertool.ps1',
    'modules/1.functions.ps1',
    'modules/2.buildpages.ps1',
    'modules/3.properties.ps1',
    'modules/4.keybinds.ps1',
    'modules/5.splash.ps1',
    'modules/builds/4.9/defaultProfile.xml'
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
Write-Host "SC-VRse installed successfully to $InstallDir"
