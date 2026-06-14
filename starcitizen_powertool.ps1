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

$scriptVersion = "0.5.8"

$scbuild = "4.8"
$branch = "HOTFIX"             # PTU , LIVE, HOTFIX etc

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
    '4.keybinds.ps1'
)

$commonChildPath = "user\client\0\Profiles\default"

[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
[Reflection.Assembly]::LoadWithPartialName('System.Data')          | Out-Null
[Reflection.Assembly]::LoadWithPartialName('System.Drawing')       | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:xmlPath = $null
$script:xmlContent = @()
$script:dataTable = New-Object System.Data.DataTable
$script:xmlArray = @()
#$script:dataGridView = @()

$script:liveFolderPath = $null
$script:attributesXmlPath = $null
$fovTextBox = $null
$heightTextBox = $null
$widthTextBox = $null
$headtrackerEnabledComboBox = $null
$HeadtrackingSourceComboBox = $null
$dataTableGroupBox = $null
$darkModeMenuItem = $null

$keybind_column_width = 150 #(100 * $script:ScaleMultiplier)                         #pixels

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition '
public class DPIAware
{
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
'

[System.Windows.Forms.Application]::EnableVisualStyles()
[void] [DPIAware]::SetProcessDPIAware()
$defaultFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular) #segoia UI, 12pt, style=Regular

function Set-DefaultFont {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Windows.Forms.Control]$control
    )
    if ($PSCmdlet.ShouldProcess("Control", "Set default font")) {
        $control.Font = $defaultFont
        foreach ($child in $control.Controls) {
            Set-DefaultFont -control $child
        }
    }
}
if ($debug) {Write-Host "PSscriptRoot:`n" $PSScriptRoot -BackgroundColor White -ForegroundColor Black}


$script:ScaleMultiplier = 1.0
<#       We'll use the screen dimensions below for suggesting a max window size                   #>
function Get-MaxScreenResolution {
    Add-Type -AssemblyName System.Windows.Forms
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    return "$screenWidth x $screenHeight"
}
#if ($debug) {Get-MaxScreenResolution}
function Get-DesktopResolutionScale {
    Add-Type -AssemblyName System.Windows.Forms
    $graphics = [System.Drawing.Graphics]::FromHwnd([System.IntPtr]::Zero)
    $desktopDpiX = $graphics.DpiX
    $scaleFactor = $desktopDpiX / 96  # 96 DPI is the default scale (100%)
    switch ($scaleFactor) {
        1 { $script:ScaleMultiplier = 1.0; return "100%" }
        1.25 { $script:ScaleMultiplier = 1.25; return "125%" }
        1.5 { $script:ScaleMultiplier = 1.5; return "150%" }
        1.75 { $script:ScaleMultiplier = 1.75; return "175%" }
        2 { $script:ScaleMultiplier = 2.0; return "200%" }
        default { $script:ScaleMultiplier = [math]::Round($scaleFactor * 100) / 100; return "$([math]::Round($scaleFactor * 100))%" }
    }
}Get-DesktopResolutionScale | Out-Null
if ($debug) {
    write-host "Resolution Scale: " (Get-DesktopResolutionScale)
    Write-Host "Scale Multiplier: " $script:ScaleMultiplier -BackgroundColor White -ForegroundColor Black
    Write-Host "Max Screen Resolution: " (Get-MaxScreenResolution) -BackgroundColor White -ForegroundColor Black
}


$form = New-Object System.Windows.Forms.Form

$form.Text = "SC/VR Powertools (Attribute Editor "+$scriptVersion+")"
$form.Width = (620 * $script:ScaleMultiplier)
$form.Height = (600 * $script:ScaleMultiplier)
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size($form.Width,$form.Height)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.Add_Shown({
    $form.Activate()
    $form.TopMost = $true
    $form.TopMost = $false
})

# add a menu toolbar with one option called "File"
$mainMenu = New-Object System.Windows.Forms.MainMenu

$fileMenuItem = New-Object System.Windows.Forms.MenuItem
$fileMenuItem.Text = "&File"    # The & character indicates the shortcut key
$mainMenu.MenuItems.Add($fileMenuItem)  # Add the File menu item to the main menu


# new TabControl here to replace the parent groups below #>

$tabControl_VRSettings = New-Object System.Windows.Forms.TabControl
# Create TabControl
$tabControl_VRSettings.Top = (10 * $script:ScaleMultiplier)
$tabControl_VRSettings.Left = (10 * $script:ScaleMultiplier)
#$tabControl_VRSettings.Width = (550 * $script:ScaleMultiplier)
#$tabControl_VRSettings.Height = (330 * $script:ScaleMultiplier)
$tabControl_VRSettings.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$tabControl_VRSettings.Size = New-Object Drawing.Size((580 * $script:ScaleMultiplier),(470 * $script:ScaleMultiplier))
#$tabControl_VRSettings.Anchor = "Top, Left, Right"
$tabControl_VRSettings.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$form.Controls.Add($tabControl_VRSettings)
#tabs instead of parent groups

# --- Tab 1: Experimental VR Settings ---
$tabVRSettings_Experimental = New-Object System.Windows.Forms.TabPage
$tabVRSettings_Experimental.Text = "Experimental VR"
$tabVRSettings_Experimental.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$tabVRSettings_Experimental.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)

# --- Tab 2: Legacy Headtracking ---
$tabVRSettings_LegacySettings = New-Object System.Windows.Forms.TabPage
$tabVRSettings_LegacySettings.Text = "Legacy Headtracking"
$tabVRSettings_LegacySettings.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$tabVRSettings_LegacySettings.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)

# --- Tab 3: Keybind Viewer ---
$tabVRSettings_Keybinds = New-Object System.Windows.Forms.TabPage
$tabVRSettings_Keybinds.Text = "Keybind Viewer"
$tabVRSettings_Keybinds.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$tabVRSettings_Keybinds.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)

$tabControl_VRSettings.TabPages.Add($tabVRSettings_Experimental)
$tabControl_VRSettings.TabPages.Add($tabVRSettings_LegacySettings)
$tabControl_VRSettings.TabPages.Add($tabVRSettings_Keybinds)


# Load the required modules
foreach ($file in $moduleFiles) {
    $fullPath = Join-Path $moduleDir $file
    if (Test-Path $fullPath) {
        Write-Host "Loading module: $file" -ForegroundColor Cyan
        . $fullPath          # dot‑source – import into current scope
    } else {
        throw "Required module file not found: $fullPath"
    }
}



$splash = New-Object System.Windows.Forms.Form

$splash.Text = "SC/VR Powertools (Attribute Editor "+$scriptVersion+")"
$splash.Width = (640 * $script:ScaleMultiplier)
$splash.Height = (480 * $script:ScaleMultiplier)
$splash.StartPosition = 'CenterScreen'
$splash.Size = New-Object System.Drawing.Size($splash.Width,$splash.Height)
$splash.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$splash.MaximizeBox = $false
$splash.MinimizeBox = $true
$splash.Add_Shown({
    $splash.Activate()
    $splash.TopMost = $true
    $splash.TopMost = $false
})
#$splash.Icon = $scriptIcon
#$splash.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

$splashWarrantyBlurb = "Thanks for trying out this tool. Please understand that the user acknowledges and agrees that the use of the Software is at user's sole risk. The Software and related documentation are provided 'AS IS' and without any warranty of any kind and Seller EXPRESSLY DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE."

#$splashLabel
$splashLabel = New-Object System.Windows.Forms.Label
$splashLabel.Text = $splashWarrantyBlurb
$splashLabel.Top = (60 * $script:ScaleMultiplier)
$splashLabel.Left = (10 * $script:ScaleMultiplier)
$splashLabel.Height = (200 * $script:ScaleMultiplier)
$splashLabel.Width = ($splash.Width - $splashLabel.Left)
$splashLabel.Font = New-Object System.Drawing.Font($splashLabel.Font.FontFamily, [math]::Round($splashLabel.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$splashLabel.Size = New-Object System.Drawing.Size((550 * $script:ScaleMultiplier),(200 * $script:ScaleMultiplier))
$splash.Controls.Add($splashLabel)

$splashbuttonLoadMainForm = New-Object System.Windows.Forms.Button
$splashbuttonLoadMainForm.Text = "Thanks!"
#$splashbuttonLoadMainForm.Location = ((10 * $script:ScaleMultiplier),(310 * $script:ScaleMultiplier))
#$splashbuttonLoadMainForm.Location = "10,310"
$splashbuttonLoadMainForm.Top = (310 * $script:ScaleMultiplier)
#$splashbuttonLoadMainForm.Left = ((($splash.Width /2)-($splashbuttonLoadMainForm.Size /2))  * $script:ScaleMultiplier)
$splashbuttonLoadMainForm.Left = ($splash.Width /2)
$splashbuttonLoadMainForm.Font = New-Object System.Drawing.Font($splashbuttonLoadMainForm.Font.FontFamily, [math]::Round($splashbuttonLoadMainForm.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$splashbuttonLoadMainForm.Size = New-Object System.Drawing.Size((100 * $script:ScaleMultiplier), (30 * $script:ScaleMultiplier))
$splashbuttonLoadMainForm.Width = (80 * $script:ScaleMultiplier)
$splashbuttonLoadMainForm.TabIndex = 4
$splash.Controls.Add($splashbuttonLoadMainForm)

$splashbuttonLoadMainForm.Add_Click({
    $splash.Hide()
    $form.ShowDialog()
    })


Set-DefaultFont -control $form
#Set-DefaultFont -control $formHIDLookup

#Set-DefaultFont -control $groupExperimentalVRSettings
#Set-DefaultFont -control $keyBindsForm
Set-DefaultFont -control $splash
Switch-DarkMode

$splash.ShowDialog()