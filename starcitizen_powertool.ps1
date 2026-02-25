<#▄█    █▄     ▄████████    ▄████████    ▄████████         ▄████████    ▄████████
 ███    ███   ███    ███   ███    ███   ███    ███        ███    ███   ███    ███
 ███    ███   ███    ███   ███    █▀    ███    █▀         ███    ███   ███    █▀
 ███    ███  ▄███▄▄▄▄██▀   ███         ▄███▄▄▄            ███    ███  ▄███▄▄▄
 ███    ███ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀          ▀███████████ ▀▀███▀▀▀
 ███    ███ ▀███████████          ███   ███    █▄         ███    ███   ███    █▄
 ███    ███   ███    ███    ▄█    ███   ███    ███        ███    ███   ███    ███
  ▀██████▀    ███    ███  ▄████████▀    ██████████        ███    █▀    ██████████
              ███    ███  SC/VR Powertools - Attribute Editor  Author: @troubleshooternz
#>

$scriptVersion = "0.5.4"

$scbuild = "4.6"
$branch = "LIVE"             # PTU , LIVE, HOTFIX etc

$debug = $false

$BackupFolderName = "VRSE AE Backup"
$profileContent = @()
$script:profileArray = [System.Collections.ArrayList]@()
$loadedProfile = $false

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

$textboxExpCategory_EscMenuSettings_EscMenuDistance = $null
$textboxExpCategory_EscMenuSettings_EscMenuYPos = $null
$textboxExpCategory_EscMenuSettings_EscMenuScale = $null
$textboxExpCategory_HelmetVisorLensDepth = $null
$textboxExpCategory_HelmetVisorLens_AspectModifier = $null
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight = $null
$textboxExpCategory_HelmetVisorLens_HmdVisorScale = $null
$ComboboxExpCategory_MirrorMode_StereoMirrorMode = $null
$textboxExpCategory_TheatreMode_Scale = $null
$textboxExpCategory_TheatreMode_Curvature = $null
$textboxExpCategory_TheatreMode_Distance = $null
#$textboxExpCategory_UserSettings_StereoScaleformDepth = $null
$textboxExpCategory_UserSettings_StereoStrength = $null
$textboxExpCategory_ConsoleSettings_StereoCursorScale = $null
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch = $null
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode = $null
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye = $null

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


<# Replaced real ico file with embedded base64 ico below.
    $scriptIcon = $null
    if (![string]::IsNullOrEmpty($PSScriptRoot)) { # if the script is run from a path, not from the console
        $iconPath = Join-Path -Path $PSScriptRoot -ChildPath "icon.ico"
        if (Test-Path $iconPath) {
            $scriptIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
        } else {
            $iconwebPath = "https://raw.githubusercontent.com/troubleNZ/SC-VRse/main/"
            try {
                $tempIconPath = Join-Path -Path $env:TEMP -ChildPath "icon.ico"
                Invoke-WebRequest -Uri $iconwebPath -OutFile $tempIconPath -ErrorAction Stop
                $scriptIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($tempIconPath)
            } catch {
                if ($debug) {Write-Host "Failed to download icon"}
            }
        }
    }
#>

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
$form.Height = (500 * $script:ScaleMultiplier)
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

<# new embedded icon base64 (709Kb)
    $iconBase64      = '' # removed for now to reduce filesize
    $iconBytes       = [Convert]::FromBase64String($iconBase64)
    # initialize a Memory stream holding the bytes
    $stream          = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
    $Form.Icon       = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

    # PowerShell versions older than 5.0 use this:
    # $stream        = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
    # $Form.Icon     = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

    #$form.Icon = $scriptIcon
#>

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
$tabControl_VRSettings.Size = New-Object Drawing.Size((580 * $script:ScaleMultiplier),(370 * $script:ScaleMultiplier))
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
function Update-ButtonState {                           # used to grey out buttons when no XML file is loaded
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Button State Update", "Update the state of import and save buttons")) {
        if ($null -ne $script:xmlContent) {
            $importButton.Enabled = $true
            $applySaveButton.Enabled = $true
            
            if ($loadedProfile -eq $true) {
                $loadFromProfileButton.Enabled = $true
            } else {
                $loadFromProfileButton.Enabled = $false
            }
        } else {
            $importButton.Enabled = $false
            $applySaveButton.Enabled = $false
            $loadFromProfileButton.Enabled = $false
            
        }
    }
}

function Set-DarkMode {     # INVICTUS BLUE AND YELLOW
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Windows.Forms.Control]$control
    )
    if ($PSCmdlet.ShouldProcess("Control", "Set dark mode")) {
        #$control.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        if ($null -ne $control.BackColor) { $control.BackColor = [System.Drawing.Color]::FromArgb(11, 29, 41)}
        if ($null -ne $control.ForeColor) { $control.ForeColor = [System.Drawing.Color]::White}
        #$control.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

        $applySaveButton.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
        $applySaveButton.ForeColor = [System.Drawing.Color]::White
        $applySaveButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $applySaveButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(11, 29, 41)
        
        $saveAndCloseButton.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
        $saveAndCloseButton.ForeColor = [System.Drawing.Color]::White
        $saveAndCloseButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $saveAndCloseButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(11, 29, 41)
        
        $fovTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $fovTextBox.ForeColor = [System.Drawing.Color]::White
        $fovTextBox.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        
        $widthTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $widthTextBox.ForeColor = [System.Drawing.Color]::White
        $widthTextBox.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        
        $heightTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $heightTextBox.ForeColor = [System.Drawing.Color]::White
        $heightTextBox.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        
        $chromaticAberrationTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $ShakeScaleTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $CameraSpringMovementTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $GForceBoostZoomScaleTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $GForceHeadBobScaleTextBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $headtrackerEnabledComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $HeadtrackingSourceComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $AutoZoomComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $HeadtrackingEnableRollFPSComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$HeadtrackingDuringFPSComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $HeadtrackingThirdPersonCameraToggleComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $FilmGrainComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $MotionBlurComboBox.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$MotionBlurComboBox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        
        #$closeKeyBindsButton.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$closeKeyBindsButton.ForeColor = [System.Drawing.Color]::White
        #$closeKeyBindsButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        #$closeKeyBindsButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(26, 66, 116)

        $textboxExpCategory_EscMenuSettings_EscMenuDistance.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_EscMenuSettings_EscMenuDistance.ForeColor = [System.Drawing.Color]::White
        #$textboxExpCategory_EscMenuSettings_EscMenuDistance.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $textboxExpCategory_EscMenuSettings_EscMenuYPos.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_EscMenuSettings_EscMenuYPos.ForeColor = [System.Drawing.Color]::White
        #$textboxExpCategory_EscMenuSettings_EscMenuYPos.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $textboxExpCategory_EscMenuSettings_EscMenuScale.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_EscMenuSettings_EscMenuScale.ForeColor = [System.Drawing.Color]::White
        #$textboxExpCategory_EscMenuSettings_EscMenuScale.borderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $textboxExpCategory_HelmetVisorLensDepth.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_HelmetVisorLensDepth.ForeColor = [System.Drawing.Color]::White

        $textboxExpCategory_HelmetVisorLens_AspectModifier.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $textboxExpCategory_HelmetVisorLens_HmdVisorScale.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)

        $textboxExpCategory_TheatreMode_Scale.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_TheatreMode_Scale.ForeColor = [System.Drawing.Color]::White

        $textboxExpCategory_TheatreMode_Curvature.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_TheatreMode_Curvature.ForeColor = [System.Drawing.Color]::White
        
        $textboxExpCategory_TheatreMode_Distance.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_TheatreMode_Distance.ForeColor = [System.Drawing.Color]::White
        #$textboxExpCategory_UserSettings_StereoScaleformDepth.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_UserSettings_StereoScaleformDepth.ForeColor = [System.Drawing.Color]::White
        $textboxExpCategory_UserSettings_StereoStrength.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_UserSettings_StereoStrength.ForeColor = [System.Drawing.Color]::White

        $textboxExpCategory_ConsoleSettings_StereoCursorScale.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        #$textboxExpCategory_ConsoleSettings_StereoCursorScale.ForeColor = [System.Drawing.Color]::White
        
        foreach ($child in $control.Controls) {
            if ($null -eq $child.BackColor) { return }
            elseif($null -eq $child.ForeColor) { return }
            else { Set-DarkMode -control $child }
        }
    }
}

function Set-LightMode {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Windows.Forms.Control]$control
    )
    if ($PSCmdlet.ShouldProcess("Control", "Set light mode")) {
        $control.BackColor = [System.Drawing.Color]::White
        $control.ForeColor = [System.Drawing.Color]::Black
        foreach ($child in $control.Controls) {
            Set-LightMode -control $child
        }
    }
}

# Apply light mode to the form and its controls by default
Set-LightMode -control $form

function Switch-DarkMode {
    #if ($form.BackColor -eq [System.Drawing.Color]::FromArgb(45, 45, 48)) { #black
    if ($form.BackColor -eq [System.Drawing.Color]::FromArgb(11, 29, 41)) {
        Set-LightMode -control $form
        Set-LightMode -control $formHIDLookup
        #Set-LightMode -control $keyBindsForm
        $darkModeMenuItem.Text = "Enable Dark Mode"
        $script:profileArray.Add([PSCustomObject]@{ DarkMode = $false }) | Out-Null
        # Set light mode for the dataTable
        #$script:dataGridView.BackgroundColor = [System.Drawing.Color]::White
        #$script:dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::White
        #$script:dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
        #$script:dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::White
        #$script:dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
    } else {
        Set-DarkMode -control $form
        Set-DarkMode -control $formHIDLookup
        #Set-DarkMode -control $keyBindsForm
        $darkModeMenuItem.Text = "Disable Dark Mode"
        $script:profileArray.Add([PSCustomObject]@{ DarkMode = $true }) | Out-Null
        # Set dark mode for the dataTable
        #$script:dataGridView.BackgroundColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        #$script:dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        #$script:dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
        #$script:dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        #$script:dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    }
}


# Helper – update a single attribute value in the XML file.
function Update-XMLAttribute {
    param(
        [string]$XmlPath,   # Full path to attributes.xml
        [string]$AttrName,  # e.g. 'FOV', 'Height', etc.
        [string]$NewValue   # New string to store in the `value` attribute
    )

    if (-not (Test-Path $XmlPath)) { return }

    try {
        # Load XML once
        $xml = [xml](Get-Content $XmlPath)

        # Find the <Attr> element that has name="$AttrName"
        $node = $xml.Attributes.SelectSingleNode("Attr[@name='$AttrName']")

        if ($null -ne $node) {
            # Replace its `value` attribute
            $node.SetAttribute('value', $NewValue)

            # Write back to disk
            $xml.Save($XmlPath)
        } else {
            Write-Host "Warning: Attribute '$AttrName' not found in $XmlPath" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "[Error 104] Failed to update attribute '$AttrName': $_" -ForegroundColor Red
    }
}



function Set-ProfileArray {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Profile Array", "Set the profile array")) {
        $script:profileArray.Clear()  # Clear the existing profile array

        $script:profileArray.Add([PSCustomObject]@{
            SCPath = $script:liveFolderPath;
            AttributesXmlPath = $script:xmlPath;
            DarkMode = if ($darkModeMenuItem.Text -eq "Disable Dark Mode") { $true } else { $false };
            FOV = $fovTextBox.Text;
            Height = $heightTextBox.Text;
            Width = $widthTextBox.Text;
            Headtracking = $headtrackerEnabledComboBox.SelectedIndex;
            HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex;
            ChromaticAberration = $chromaticAberrationTextBox.Text;
            #AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text;
            AutoZoomOnSelectedTarget = $AutoZoomComboBox.SelectedIndex;
            #MotionBlur = $MotionBlurTextBox.Text;
            MotionBlur = $MotionBlurComboBox.SelectedIndex;
            ShakeScale = $ShakeScaleTextBox.Text;
            CameraSpringMovement = $CameraSpringMovementTextBox.Text;
            #FilmGrain = $FilmGrainTextBox.Text;
            FilmGrain = $FilmGrainComboBox.SelectedIndex;
            GForceBoostZoomScale = $GForceBoostZoomScaleTextBox.Text;
            GForceHeadBobScale = $GForceHeadBobScaleTextBox.Text;
            HeadtrackingEnableRollFPS = $HeadtrackingEnableRollFPSComboBox.SelectedIndex;
            HeadtrackingDisableDuringWalking = $HeadtrackingDuringFPSComboBox.SelectedIndex;
            HeadtrackingThirdPersonCameraToggle = $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex;
            # the new stuff below here
            HmdUIDistance = $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text;
            HmdUIHeight = $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text;
            HmdUIScale = $textboxExpCategory_EscMenuSettings_EscMenuScale.Text;
            HmdVisorDistance = $textboxExpCategory_HelmetVisorLensDepth.Text;
            HmdVisorAspectModifier = $textboxExpCategory_HelmetVisorLens_AspectModifier.Text;
            HmdVisorHeight = $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text;
            HmdVisorScale = $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text;
            HmdTheaterMode = $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex;
            HmdTheaterModeScale = $textboxExpCategory_TheatreMode_Scale.Text;
            HmdTheaterModeCurvature = $textboxExpCategory_TheatreMode_Curvature.Text;
            HmdTheaterModeDistance = $textboxExpCategory_TheatreMode_Distance.Text;
            #HmdUIDistance = $textboxExpCategory_UserSettings_StereoScaleformDepth.Text;
            HmdIPDScale = $textboxExpCategory_UserSettings_StereoStrength.Text;
            HmdCursorSize = $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text;
            HmdAutomaticSwitching = $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex;
            HmdActorControlMode = $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex;
            HmdfpsAdsDominantEye = $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex

        }) | Out-Null
    }

    if ($debug) {Write-Host "func:ProfileArray : " $script:profileArray -BackgroundColor White -ForegroundColor Black}
}

function Open-XMLViewer {
    param (
        [string]$Path
    )

    if (Test-Path $Path) {
        try {
            $script:xmlContent = [xml](Get-Content $Path)
            $gridGroup.Controls.Clear()

            #$script:dataGridView = New-Object System.Windows.Forms.DataGridView
            #$script:dataGridView.Width = 550
            #$script:dataGridView.Height = 200
            #$script:dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
            #$script:dataGridView.Visible = $false       # grid hidden now. maybe put on another panel later

            $script:dataTable = New-Object System.Data.DataTable

            # Add columns to the DataTable
            if ($script:xmlContent.ChildNodes.Count -gt 0) {
                foreach ($node in $script:xmlContent.SelectNodes("//*")) {
                    foreach ($attribute in $node.Attributes) {
                        if (-not $script:dataTable.Columns.Contains($attribute.Name)) {
                            $script:dataTable.Columns.Add($attribute.Name) | Out-Null
                            #Write-Host "func:XMLViewer .Columns.Add : " + "$($attribute.Name): $($attribute.Value)"
                            $script:xmlArray += $($attribute.Name) + " : " + "$($attribute.Value)"
                        }
                    }
                }

                # Add rows to the DataTable
                foreach ($node in $script:xmlContent.SelectNodes("//*")) {
                    $row = $script:dataTable.NewRow()
                    foreach ($attribute in $node.Attributes) {
                        if ($script:dataTable.Columns.Contains($attribute.Name)) {
                            $row[$attribute.Name] = $attribute.Value
                        }
                    }
                    $script:dataTable.Rows.Add($row) | Out-Null
                    #Write-Host "func:XMLViewer .Rows.Add : " + "$($attribute.Name): $($attribute.Value)"
                }

                # Bind the DataTable to the DataGridView
                #$script:dataGridView.DataSource = $script:dataTable

                #$gridGroup.Controls.Add($script:dataGridView)

                # Show the dataTableGroupBox and set its text to the XML path
                #$dataTableGroupBox.Text = $Path
                #$dataTableGroupBox.Visible = $true
                Update-ButtonState

                # Populate the input boxes with the first row values
                
                    if ($null -ne $script:profileArray.FOV) {
                        $fovTextBox.Text = $script:profileArray.FOV
                    }else {
                        $fovTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.Height) {
                        $heightTextBox.Text = $script:profileArray.Height
                    } else {
                        $heightTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.Width) {
                        $widthTextBox.Text = $script:profileArray.Width
                    } else {
                        $widthTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.Headtracking) {
                        $headtrackerEnabledComboBox.SelectedIndex = $script:profileArray.Headtracking
                    } else {
                        $headtrackerEnabledComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HeadtrackingSource) {
                        $HeadtrackingSourceComboBox.SelectedIndex = $script:profileArray.HeadtrackingSource
                    } else {
                        $HeadtrackingSourceComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.ChromaticAberration) {
                        $chromaticAberrationTextBox.Text = $script:profileArray.ChromaticAberration
                    } else {
                        $chromaticAberrationTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ChromaticAberration" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.AutoZoomOnSelectedTarget) {
                        #$AutoZoomTextBox.Text = $script:profileArray.AutoZoomOnSelectedTarget
                        $AutoZoomComboBox.SelectedIndex = $script:profileArray.AutoZoomOnSelectedTarget
                    } else {
                        #$AutoZoomTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                        $AutoZoomComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.MotionBlur) {
                        #$MotionBlurTextBox.Text = $script:profileArray.MotionBlur
                        $MotionBlurComboBox.SelectedIndex = $script:profileArray.MotionBlur
                    } else {
                        #$MotionBlurTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
                        $MotionBlurComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.ShakeScale) {
                        $ShakeScaleTextBox.Text = $script:profileArray.ShakeScale
                    } else {
                        $ShakeScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ShakeScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.CameraSpringMovement) {
                        $CameraSpringMovementTextBox.Text = $script:profileArray.CameraSpringMovement
                    } else {
                        $CameraSpringMovementTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "CameraSpringMovement" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.FilmGrain) {
                        #$FilmGrainTextBox.Text = $script:profileArray.FilmGrain
                        $FilmGrainComboBox.SelectedIndex = $script:profileArray.FilmGrain
                    } else {
                        #$FilmGrainTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
                        $FilmGrainComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.GForceBoostZoomScale) {
                        $GForceBoostZoomScaleTextBox.Text = $script:profileArray.GForceBoostZoomScale
                    } else {
                        $GForceBoostZoomScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceBoostZoomScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.GForceHeadBobScale) {
                        $GForceHeadBobScaleTextBox.Text = $script:profileArray.GForceHeadBobScale
                    } else {
                        $GForceHeadBobScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceHeadBobScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HeadtrackingEnableRollFPS) {
                        $HeadtrackingEnableRollFPSComboBox.SelectedIndex = $script:profileArray.HeadtrackingEnableRollFPS
                    } else {
                        $HeadtrackingEnableRollFPSComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingEnableRollFPS" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HeadtrackingDisableDuringWalking) {
                        $HeadtrackingDuringFPSComboBox.SelectedIndex = $script:profileArray.HeadtrackingDisableDuringWalking
                    } else {
                        $HeadtrackingDuringFPSComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingDisableDuringWalking" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HeadtrackingThirdPersonCameraToggle) {
                        $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = $script:profileArray.HeadtrackingThirdPersonCameraToggle
                    } else {
                        $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingThirdPersonCameraToggle" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdUIDistance) {
                        $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text = $script:profileArray.HmdUIDistance
                    } else {
                        $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIDistance" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdUIHeight) {
                        $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text = $script:profileArray.HmdUIHeight
                    } else {
                        $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIHeight" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdUIScale) {
                        $textboxExpCategory_EscMenuSettings_EscMenuScale.Text = $script:profileArray.HmdUIScale
                    } else {
                        $textboxExpCategory_EscMenuSettings_EscMenuScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdVisorDistance) {
                        $textboxExpCategory_HelmetVisorLensDepth.Text = $script:profileArray.HmdVisorDistance
                    } else {
                        $textboxExpCategory_HelmetVisorLensDepth.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorDistance" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdVisorAspectModifier) {
                        $textboxExpCategory_HelmetVisorLens_AspectModifier.Text = $script:profileArray.HmdVisorAspectModifier
                    } else {
                        $textboxExpCategory_HelmetVisorLens_AspectModifier.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorAspectModifier" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdVisorHeight) {
                        $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text= $script:profileArray.HmdVisorHeight
                    } else {
                        $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorHeight" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdVisorScale) {
                        $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text = $script:profileArray.HmdVisorScale
                    } else {
                        $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdTheaterMode) {
                        $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = $script:profileArray.HmdTheaterMode
                    } else {
                        $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterMode" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdTheaterModeScale) {
                        $textboxExpCategory_TheatreMode_Scale.Text = $script:profileArray.HmdTheaterModeScale
                    } else {
                        $textboxExpCategory_TheatreMode_Scale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdTheaterModeCurvature) {
                        $textboxExpCategory_TheatreMode_Curvature.Text = $script:profileArray.HmdTheaterModeCurvature
                    } else {
                        $textboxExpCategory_TheatreMode_Curvature.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeCurvature" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdTheaterModeDistance) {
                        $textboxExpCategory_TheatreMode_Curvature.Text = $script:profileArray.HmdTheaterModeDistance
                    } else {
                        $textboxExpCategory_TheatreMode_Curvature.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeDistance" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdIPDScale) {
                        $textboxExpCategory_UserSettings_StereoStrength.Text = $script:profileArray.HmdIPDScale
                    } else {
                        $textboxExpCategory_UserSettings_StereoStrength.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdIPDScale" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdCursorSize) {
                        $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text = $script:profileArray.HmdCursorSize
                    } else {
                        $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdCursorSize" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdAutomaticSwitching) {
                        $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex = $script:profileArray.HmdAutomaticSwitching
                    } else {
                        $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdAutomaticSwitching" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdActorControlMode) {
                        $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex = $script:profileArray.HmdActorControlMode
                    } else {
                        $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdActorControlMode" } | Select-Object -ExpandProperty value
                    }
                    if ($null -ne $script:profileArray.HmdfpsAdsDominantEye) {
                        $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex = $script:profileArray.HmdfpsAdsDominantEye
                    } else {
                        $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdfpsAdsDominantEye" } | Select-Object -ExpandProperty value
                    }


                if ($debug) {Write-Host "debug: try to Populate the input boxes with the profile array values" -BackgroundColor White -ForegroundColor Black}
                Set-ProfileArray

            } else {
                [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file?")
            }
        } catch {
            #if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")}
            if ($debug) { Write-Host "[Error 100] An error occurred while loading the XML file: $_"}
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("XML file not found.")
    }
}

function Save-Profile {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Profile", "Save the profile to JSON")) {
        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "JSON Files (*.json)|*.json"
        $saveFileDialog.Title = "Save Profile As"
        $saveFileDialog.FileName = "profile.json"

        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $profileJsonPath = $saveFileDialog.FileName
            try {
                if ($debug) { Write-Host "debug: Copying values to profile array" -BackgroundColor White -ForegroundColor Black }
                $script:profileArray[0].SCPath = $script:liveFolderPath
                $script:profileArray[0].AttributesXmlPath = $script:xmlPath
                $script:profileArray[0].DarkMode = if ($darkModeMenuItem.Text -eq "Disable Dark Mode") { $true } else { $false }
                $script:profileArray[0].FOV = $fovTextBox.Text
                $script:profileArray[0].Height = $heightTextBox.Text
                $script:profileArray[0].Width = $widthTextBox.Text
                $script:profileArray[0].Headtracking = $headtrackerEnabledComboBox.SelectedIndex
                $script:profileArray[0].HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex
                $script:profileArray[0].ChromaticAberration = $chromaticAberrationTextBox.Text
                #$script:profileArray[0].AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text
                $script:profileArray[0].AutoZoomOnSelectedTarget = $AutoZoomComboBox.SelectedIndex
                #$script:profileArray[0].MotionBlur = $MotionBlurTextBox.Text
                $script:profileArray[0].MotionBlur = $MotionBlurComboBox.SelectedIndex
                $script:profileArray[0].ShakeScale = $ShakeScaleTextBox.Text
                $script:profileArray[0].CameraSpringMovement = $CameraSpringMovementTextBox.Text
                #$script:profileArray[0].FilmGrain = $FilmGrainTextBox.Text
                $script:profileArray[0].FilmGrain = $FilmGrainComboBox.SelectedIndex
                $script:profileArray[0].GForceBoostZoomScale = $GForceBoostZoomScaleTextBox.Text
                $script:profileArray[0].GForceHeadBobScale = $GForceHeadBobScaleTextBox.Text
                $script:profileArray[0].HeadtrackingEnableRollFPS = $HeadtrackingEnableRollFPSComboBox.SelectedIndex
                $script:profileArray[0].HeadtrackingDisableDuringWalking = $HeadtrackingDuringFPSComboBox.SelectedIndex
                #$script:profileArray[0].HeadtrackingDuringFPS = $HeadtrackingDuringFPSComboBox.SelectedIndex
                $script:profileArray[0].HeadtrackingThirdPersonCameraToggle = $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex
                $script:profileArray[0].HmdUIDistance = $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text
                $script:profileArray[0].HmdUIHeight = $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text
                $script:profileArray[0].HmdUIScale = $textboxExpCategory_EscMenuSettings_EscMenuScale.Text
                $script:profileArray[0].HmdVisorDistance = $textboxExpCategory_HelmetVisorLensDepth.Text
                $script:profileArray[0].HmdVisorAspectModifier = $textboxExpCategory_HelmetVisorLens_AspectModifier
                $script:profileArray[0].HmdVisorHeight = $textboxExpCategory_HelmetVisorLens_HmdVisorHeight
                $script:profileArray[0].HmdVisorScale = $textboxExpCategory_HelmetVisorLens_HmdVisorScale
                $script:profileArray[0].HmdTheaterMode = $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex
                $script:profileArray[0].HmdTheaterModeScale = $textboxExpCategory_TheatreMode_Scale.Text
                $script:profileArray[0].HmdTheaterModeCurvature = $textboxExpCategory_TheatreMode_Curvature.Text
                $script:profileArray[0].HmdTheaterModeDistance = $textboxExpCategory_TheatreMode_Distance.Text
                #$script:profileArray[0].HmdUIDistance = $textboxExpCategory_UserSettings_StereoScaleformDepth.Text
                $script:profileArray[0].HmdIPDScale = $textboxExpCategory_UserSettings_StereoStrength.Text
                $script:profileArray[0].HmdCursorSize = $textboxExpCategory_ConsoleSettings_StereoCursorScale
                $script:profileArray[0].HmdAutomaticSwitching = $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex
                $script:profileArray[0].HmdActorControlMode = $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex
                $script:profileArray[0].HmdfpsAdsDominantEye = $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex

                $jsonContent = $script:profileArray[0] | ConvertTo-Json -Depth 10 -ErrorAction Stop
                if ($null -ne $jsonContent) {
                    [System.IO.File]::WriteAllText($profileJsonPath, $jsonContent)
                } else {
                    #[System.Windows.Forms.MessageBox]::Show("Failed to generate JSON content.")
                    $statusBar.Text = "Failed to generate JSON content."
                }
                #[System.Windows.Forms.MessageBox]::Show("Profile saved successfully to $profileJsonPath")
                $statusBar.Text = "Profile saved successfully to $profileJsonPath"
            } catch {
                #[System.Windows.Forms.MessageBox]::Show("An error occurred while saving the profile.json file: $_")
                $statusBar.Text = "An error occurred while saving the profile.json file: $_"
            }
        }
    }
}

function Open-Profile {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Profile", "Open a previously saved JSON")) {
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "JSON Files (*.json)|*.json"
        $openFileDialog.Title = "Select a Profile JSON File"

        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $profileJsonPath = $openFileDialog.FileName

            if (Test-Path -Path $profileJsonPath) {
                # Import-ProfileJson
                try {
                    $profileContent = Get-Content -Path $profileJsonPath -Raw -ErrorAction Stop
                    if ($debug) { Write-Host "profileJsonPath: $profileJsonPath" -BackgroundColor White -ForegroundColor Black }
                    $parsedJson = $profileContent | ConvertFrom-Json -ErrorAction Stop

                    if ($parsedJson -is [PSCustomObject]) {
                        $script:profileArray = [System.Collections.ArrayList]@($parsedJson)
                        if ($debug) { Write-Host "Parsed JSON object converted to ArrayList." -BackgroundColor White -ForegroundColor Black }
                        if ($debug) {
                            foreach ($item in $script:profileArray) {
                                Write-Host "Item: $item" -BackgroundColor White -ForegroundColor Black
                            }
                        }
                        $loadedProfile = $true
                        $script:liveFolderPath = $script:profileArray.SCPath
                        $script:attributesXmlPath = if ($null -ne $script:profileArray.AttributesXmlPath) { $script:profileArray.AttributesXmlPath } else { $script:xmlPath }
                        $script:xmlPath = $script:attributesXmlPath
                        $script:darkMode = $script:profileArray.DarkMode
                        if ($script:darkMode) {
                            Switch-DarkMode
                        } else {
                            Set-LightMode -control $form
                        }
                        Open-XMLViewer($script:xmlPath)
                    } else {
                        throw "Invalid JSON structure. Expected an array or object."
                    }
                } catch {
                    $statusBar.Text = "Error parsing JSON"
                }
            } else {
                $statusBar.Text =  "Selected file does not exist."
            }
        }
    }
}

function Get-GameRootDirFromRegistry {
    $keyPath = "HKCU:\System\GameConfigStore\Children"
    try {
        $key = Get-Item $keyPath -ErrorAction Stop
    } catch {
        Write-Error "Unable to open registry key: $keyPath"
        return $null
    }

    $subKeys = Get-ChildItem $key.PSPath
    foreach ($subKey in $subKeys) {
        $matchedExeFullPath = (Get-ItemProperty -Path $subKey.PSPath).MatchedExeFullPath
        if (-not $matchedExeFullPath) {
            continue
        }

        $matchedExe = Get-Item $matchedExeFullPath -ErrorAction SilentlyContinue
        if ($matchedExe -and $matchedExe.Name -eq "StarCitizen.exe") {
            if ($debug) {Write-Host "Found Star Citizen as $($subKey.PSChildName): $matchedExeFullPath"}
            $dir = (Get-Item $matchedExe.Directory.FullName).Parent.Parent
            if (-not $dir -or -not (Test-Path $dir.FullName)) {
                Write-Error "Star Citizen's root directory does not exist or is invalid: $($dir.FullName)"
                continue
            }
            if ($debug) {Write-Host  "Found Star Citizen's root directory: $($dir.FullName)"}
            return $dir.FullName
        }
    }

    Write-Error "Could not find Star Citizen's root directory in the registry, please select it manually!"
    return $null
}

function Open-LiveFolder {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($AutoDetectSCPath -ne $null -and (Test-Path -Path $AutoDetectSCPath)) {
        $folderBrowserDialog.SelectedPath = $AutoDetectSCPath
    }
    $statusBar.Text = "Opening SC Folder..."
    $folderBrowserDialog.Description = "Select the 'Star Citizen' folder containing 'Live'"
    if ($script:profileArray -and ($null -ne $script:profileArray.SCPath)) {
        if ($folderBrowserDialog -ne $null) {
            $folderBrowserDialog.SelectedPath = [System.IO.Path]::GetDirectoryName($script:profileArray.SCPath)
        } else {
            Write-Error "Error: FolderBrowserDialog is not initialized." -ForegroundColor Red
        }
    }
    if ($folderBrowserDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowserDialog.SelectedPath
        $script:liveFolderPath = Join-Path -Path $selectedPath -ChildPath $branch
        if (Test-Path -Path $script:liveFolderPath -PathType Container) {
            $statusBar.Text = "SC Folder found at: $script:liveFolderPath"
            #[System.Windows.Forms.MessageBox]::Show("Found 'Live' folder at: $script:liveFolderPath")
            $defaultProfilePath = Join-Path -Path $script:liveFolderPath -ChildPath "user\client\0\Profiles\default"
            if (-not (Test-Path -Path $defaultProfilePath -PathType Container)) {
                $statusBar.Text = "'default' folder not found."
                [System.Windows.Forms.MessageBox]::Show("'default' folder not found.")
                return
            }
            elseif (Test-Path -Path $defaultProfilePath -PathType Container) {
                $script:attributesXmlPath = Join-Path -Path $defaultProfilePath -ChildPath "attributes.xml"
                if (Test-Path -Path $script:attributesXmlPath) {
                    if (![string]::IsNullOrEmpty($PSScriptRoot)) {
                        $backupDir = Join-Path -Path $PSScriptRoot -ChildPath $BackupFolderName
                        if (-not (Test-Path -Path $backupDir)) {
                            New-Item -ItemType Directory -Path $backupDir | Out-Null
                        }
                    }
                    $destinationPath = Join-Path -Path $backupDir -ChildPath "attributes_backup_$niceDate.xml"
                    Copy-Item -Path $script:attributesXmlPath -Destination $destinationPath -Force
                    $script:xmlPath = $script:attributesXmlPath
                    Open-XMLViewer($script:xmlPath)
                } else {
                    $statusBar.Text = "attributes.xml file not found in the 'default' profile folder."
                    [System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")

                }
            }
        } else {
            $statusBar.Text = "'Live' folder not found."
            [System.Windows.Forms.MessageBox]::Show("'Live' folder not found in the selected directory.")
        }
    }else {
        $statusBar.Text = "Folder selection canceled."
        #[System.Windows.Forms.MessageBox]::Show("Folder selection canceled.")
    }
}

function Save-SettingsToGame {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Game", "Save settings to game")) {
        try {
            if ($null -eq $script:xmlContent) {
                if ($debug) {[System.Windows.Forms.MessageBox]::Show("XML content is null. Please load a valid XML file before saving.")}
                return
            }
    
            #$fovNode = $script:xmlContent.SelectSingleNode("//attribute[@name='FOV']")
            $fovNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" }
            if ($null -ne $fovNode) {
                $fovNode.SetAttribute("value", $fovTextBox.Text)  # FOV
            }
    
            #$heightNode = $script:xmlContent.SelectSingleNode("//attribute[@name='Height']")
            $heightNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" }
            if ($null -ne $heightNode) {
                $heightNode.SetAttribute("value", $heightTextBox.Text)  # HEIGHT
            }
    
            #$widthNode = $script:xmlContent.SelectSingleNode("//attribute[@name='Width']")
            $widthNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" }
            if ($null -ne $widthNode) {
                $widthNode.SetAttribute("value", $widthTextBox.Text)  # WIDTH
            }
    
            #$headtrackingNode = $script:xmlContent.SelectSingleNode("//attribute[@name='Headtracking']")
            $headtrackingNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" }
            if ($null -ne $headtrackingNode) {
                if ($headtrackerEnabledComboBox.SelectedItem -eq "Disabled") {
                    $headtrackerEnabledComboBox.SelectedIndex = 0
                } elseif ($headtrackerEnabledComboBox.SelectedItem -eq "Enabled") {
                    $headtrackerEnabledComboBox.SelectedIndex = 1
                }
                $headtrackingNode.SetAttribute("value", $headtrackerEnabledComboBox.SelectedIndex.ToString())  # HEADTRACKING
            } else {
                $newElement = $script:xmlContent.CreateElement("Attr")
                $newElement.SetAttribute("name", "HeadtrackingToggle")
                $newElement.SetAttribute("value", $headtrackerEnabledComboBox.SelectedIndex.ToString())
                $script:xmlContent.DocumentElement.AppendChild($newElement) | Out-Null
            }
    
            #$headtrackingSourceNode = $script:xmlContent.SelectSingleNode("//attribute[@name='HeadtrackingSource']")
            $headtrackingSourceNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" }
            if ($null -ne $headtrackingSourceNode) {
    
                if ($HeadtrackingSourceComboBox.SelectedItem -eq "None") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 0
                } elseif ($HeadtrackingSourceComboBox.SelectedItem -eq "TrackIR") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 1
                } elseif ($HeadtrackingSourceComboBox.SelectedItem -eq "Faceware") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 2
                } elseif ($HeadtrackingSourceComboBox.SelectedItem -eq "Tobii") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 3
                } elseif ($HeadtrackingSourceComboBox.SelectedItem -eq "unknown") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 4
                    # there seems to be no index4.
                } elseif ($HeadtrackingSourceComboBox.SelectedItem -eq "HMD") {
                    $HeadtrackingSourceComboBox.SelectedIndex = 5
                }
                $headtrackingSourceNode.SetAttribute("value", $HeadtrackingSourceComboBox.SelectedIndex.ToString())  # HEADTRACKINGSOURCE
            } else {
                $newElement = $script:xmlContent.CreateElement("Attr")
                $newElement.SetAttribute("name", "HeadtrackingSource")
                $newElement.SetAttribute("value", $HeadtrackingSourceComboBox.SelectedIndex.ToString())
                $script:xmlContent.DocumentElement.AppendChild($newElement) | Out-Null
            }
    
            $chromaticAberrationNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ChromaticAberration" }
            if ($null -ne $chromaticAberrationNode) {
                $chromaticAberrationNode.SetAttribute("value", $chromaticAberrationTextBox.Text)  # CHROMATICABERRATION
            }
            $AutoZoomNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" }
            if ($null -ne $AutoZoomNode) {
                #$AutoZoomNode.SetAttribute("value", $AutoZoomTextBox.Text)  # AUTOZOOM
                if ($AutoZoomComboBox.SelectedItem -eq "Disabled") {
                    $AutoZoomComboBox.SelectedIndex = 0
                } elseif ($AutoZoomComboBox.SelectedItem -eq "Enabled") {
                    $AutoZoomComboBox.SelectedIndex = 1
                }
                $AutoZoomNode.SetAttribute("value", $AutoZoomComboBox.SelectedIndex.ToString())  # AUTOZOOM
            }
            $MotionBlurNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" }
            if ($null -ne $MotionBlurNode) {
                if ($MotionBlurComboBox.SelectedItem -eq "Disabled") {
                    $MotionBlurComboBox.SelectedIndex = 0
                } elseif ($MotionBlurComboBox.SelectedItem -eq "Enabled") {
                    $MotionBlurComboBox.SelectedIndex = 1
                } elseif ($MotionBlurComboBox.SelectedItem -eq "Ship Only") {
                    $MotionBlurComboBox.SelectedIndex = 2
                } elseif ($MotionBlurComboBox.SelectedItem -eq "Debug Mode") {
                    $MotionBlurComboBox.SelectedIndex = 3
                }
                #$MotionBlurNode.SetAttribute("value", $MotionBlurTextBox.Text)  # MOTIONBLUR
                $MotionBlurNode.SetAttribute("value", $MotionBlurComboBox.SelectedIndex.ToString())  # MOTIONBLUR
            }
            $ShakeScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ShakeScale" }
            if ($null -ne $ShakeScaleNode) {
                $ShakeScaleNode.SetAttribute("value", $ShakeScaleTextBox.Text)  # SHAKESCALE
            }
            $CameraSpringMovementNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "CameraSpringMovement" }
            if ($null -ne $CameraSpringMovementNode) {
                $CameraSpringMovementNode.SetAttribute("value", $CameraSpringMovementTextBox.Text)  # CAMERASPRINGMOVEMENT
            }
            $FilmGrainNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" }
            if ($null -ne $FilmGrainNode) {
                #$FilmGrainNode.SetAttribute("value", $FilmGrainTextBox.Text)  # FILM GRAIN
                if ($FilmGrainComboBox.SelectedItem -eq "Disabled") {
                    $FilmGrainComboBox.SelectedIndex = 0
                } elseif ($FilmGrainComboBox.SelectedItem -eq "Enabled") {
                    $FilmGrainComboBox.SelectedIndex = 1
                }
                $FilmGrainNode.SetAttribute("value", $FilmGrainComboBox.SelectedIndex.ToString())  # FILM GRAIN
            }
            $GForceBoostZoomScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceBoostZoomScale" }
            if ($null -ne $GForceBoostZoomScaleNode) {
                $GForceBoostZoomScaleNode.SetAttribute("value", $GForceBoostZoomScaleTextBox.Text)  # GFORCEBOOSTZOOMSCALE
            }
            $GForceHeadBobScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceHeadBobScale" }
            if ($null -ne $GForceHeadBobScaleNode) {
                $GForceHeadBobScaleNode.SetAttribute("value", $GForceHeadBobScaleTextBox.Text)  # GFORCEHEADBOBSCALE
            }
            $HeadtrackingEnableRollFPSNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingEnableRollFPS" }
            if ($null -ne $HeadtrackingEnableRollFPSNode) {
                if ($HeadtrackingEnableRollFPSComboBox.SelectedItem -eq "Disabled") {
                    $HeadtrackingEnableRollFPSComboBox.SelectedIndex = 0
                } elseif ($HeadtrackingEnableRollFPSComboBox.SelectedItem -eq "Enabled") {
                    $HeadtrackingEnableRollFPSComboBox.SelectedIndex = 1
                }
                $HeadtrackingEnableRollFPSNode.SetAttribute("value", $HeadtrackingEnableRollFPSComboBox.SelectedIndex.ToString())  # HEADTRACKINGENABLEROLLFPS
            }
            $HeadtrackingDisableDuringWalkingNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingDisableDuringWalking" }
            if ($null -ne $HeadtrackingDisableDuringWalkingNode) {
                if ($HeadtrackingDisableDuringWalkingComboBox.SelectedItem -eq "On") {
                    $HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 0
                } elseif ($HeadtrackingDisableDuringWalkingComboBox.SelectedItem -eq "Off") {
                    $HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 1
                }
                $HeadtrackingDisableDuringWalkingNode.SetAttribute("value", $HeadtrackingDisableDuringWalkingComboBox.SelectedIndex.ToString())  # HEADTRACKINGDISABLEDURINGWALKING
            }
            $HeadtrackingThirdPersonCameraToggleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingThirdPersonCameraToggle" }
            if ($null -ne $HeadtrackingThirdPersonCameraToggleNode) {
                if ($HeadtrackingThirdPersonCameraToggleComboBox.SelectedItem -eq "Off") {
                    $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 0
                } elseif ($HeadtrackingThirdPersonCameraToggleComboBox.SelectedItem -eq "On") {
                    $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 1
                }
                $HeadtrackingThirdPersonCameraToggleNode.SetAttribute("value", $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex.ToString())  # HEADTRACKINGTHIRDPERSONCAMERATOGGLE
            }

            $HmdUIDistanceNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIDistance" }
            if ($null -ne $HmdUIDistanceNode) {
                $HmdUIDistanceNode.SetAttribute("value", $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text)  # HmdUIDistance
            }
            $HmdUIHeightNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIHeight" }
            if ($null -ne $HmdUIHeightNode) {
                $HmdUIHeightNode.SetAttribute("value", $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text)  # HmdUIHeight
            }
            $HmdUIScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIScale" }
            if ($null -ne $HmdUIScaleNode) {
                $HmdUIScaleNode.SetAttribute("value", $textboxExpCategory_EscMenuSettings_EscMenuScale.Text)  # HmdUIScale
            }
            $HmdVisorDistanceNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorDistance" }
            if ($null -ne $HmdVisorDistanceNode) {
                $HmdVisorDistanceNode.SetAttribute("value", $textboxExpCategory_HelmetVisorLensDepth.Text)  # HmdVisorDistance
            }
            $HmdVisorAspectModifierNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorAspectModifier" }
            if ($null -ne $HmdVisorAspectModifierNode) {
                $HmdVisorAspectModifierNode.SetAttribute("value", $textboxExpCategory_HelmetVisorLens_AspectModifier.Text)  # HmdVisorAspectModifier
            }
            $HmdVisorHeightNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorHeight" }
            if ($null -ne $HmdVisorHeightNode) {
                $HmdVisorHeightNode.SetAttribute("value", $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text)  # HmdVisorHeight
            }
            $HmdVisorScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorScale" }
            if ($null -ne $HmdVisorScaleNode) {
                $HmdVisorScaleNode.SetAttribute("value", $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text)  # HmdVisorScale
            }


            $HmdTheaterModeNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeNode" }
            if ($null -ne $HmdTheaterModeNode) {
                if ($ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedItem -eq "Disabled") {
                    $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = 0
                } elseif ($ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedItem -eq "Enabled") {
                    $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = 1
                }
                $HmdTheaterModeNode.SetAttribute("value", $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex.ToString())  # HmdTheaterModeNode
            }
            $HmdTheaterModeScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeScale" }
            if ($null -ne $HmdTheaterModeScaleNode) {
                $HmdTheaterModeScaleNode.SetAttribute("value", $textboxExpCategory_TheatreMode_Scale.Text)  # HmdTheaterModeScale
            }
            $HmdTheaterModeCurvatureNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeCurvature" }
            if ($null -ne $HmdTheaterModeCurvatureNode) {
                $HmdTheaterModeCurvatureNode.SetAttribute("value", $textboxExpCategory_TheatreMode_Curvature.Text)  # HmdTheaterModeCurvature
            }
            $HmdTheaterModeDistanceNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeDistance" }
            if ($null -ne $HmdTheaterModeDistanceNode) {
                $HmdTheaterModeDistanceNode.SetAttribute("value", $textboxExpCategory_TheatreMode_Distance.Text)  # HmdTheaterModeDistance
            }
            #$HmdVisorDistanceNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIDistance" }
            #if ($null -ne $HmdVisorDistanceNode) {
            #    $HmdVisorDistanceNode.SetAttribute("value", $textboxExpCategory_UserSettings_StereoScaleformDepth.Text)  # HmdUIDistance
            #}
            $HmdIPDScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdIPDScale" }
            if ($null -ne $HmdIPDScaleNode) {
                $HmdIPDScaleNode.SetAttribute("value", $textboxExpCategory_UserSettings_StereoStrength.Text)  # HmdIPDScale
            }
            $HmdCursorSizeNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdCursorSize" }
            if ($null -ne $HmdIPDScaleNode) {
                $HmdCursorSizeNode.SetAttribute("value", $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text)  # HmdCursorSize
            }
            $HmdAutomaticSwitchingNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdAutomaticSwitching" }
            if ($null -ne $HmdAutomaticSwitchingNode) {
                $HmdAutomaticSwitchingNode.SetAttribute("value", $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Text)  # HmdAutomaticSwitching
            }
            $HmdActorControlModeNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdActorControlMode" }
            if ($null -ne $HmdActorControlModeNode) {
                $HmdActorControlModeNode.SetAttribute("value", $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Text)  # HmdActorControlMode
            }
            $HmdfpsAdsDominantEyeNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdfpsAdsDominantEye" }
            if ($null -ne $HmdfpsAdsDominantEyeNode) {
                $HmdfpsAdsDominantEyeNode.SetAttribute("value", $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Text)  # HmdfpsAdsDominantEye
            }

            # Save the XML content to the specified path

            try {
                $script:xmlContent.Save($script:xmlPath)
                #[System.Windows.Forms.MessageBox]::Show("Settings have been saved.")
                $statusBar.Text = "Settings have been saved."
                ### $saveAcknowledgeLabel.Visible = $true
                ### Start-Sleep -Seconds 5
                ### $saveAcknowledgeLabel.Visible = $false
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while saving the XML file to $script:xmlPath: $_")
            }
                #$script:xmlContent.Save($script:xmlPath)
    
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to save the XML file: $_")
        }
    
        # Refresh and update the dataTable with the new data
        $script:dataTable.Clear()
        if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
        #if ($script:xmlContent.Attributes -and $script:xmlContent.Attributes.Attr) {
            #$script:xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
            #$script:xmlContent.Attributes | ForEach-Object {
                #if ($debug) {Write-Host "debug: $_.Name" -BackgroundColor White -ForegroundColor Black}
            #    $script:dataTable.Columns.Add($_) | Out-Null                              #investigate why this says column already exists
            #}
            foreach ($node in $script:xmlContent.SelectNodes("//*")) {
                foreach ($attribute in $node.Attributes) {
                    if (-not $script:dataTable.Columns.Contains($attribute.Name)) {
                        $script:dataTable.Columns.Add($attribute.Name) | Out-Null
                        #Write-Host "func:XMLViewer .Columns.Add : " + "$($attribute.Name): $($attribute.Value)"
                        $script:xmlArray += $($attribute.Name) + " : " + "$($attribute.Value)"
                    }
                }
            }
    
            # Add rows to the DataTable
            foreach ($node in $script:xmlContent.SelectNodes("//*")) {
                $row = $script:dataTable.NewRow()
                foreach ($attribute in $node.Attributes) {
                    if ($script:dataTable.Columns.Contains($attribute.Name)) {
                        $row[$attribute.Name] = $attribute.Value
                    }
                }
                $script:dataTable.Rows.Add($row) | Out-Null
                #Write-Host "func:XMLViewer .Rows.Add : " + "$($attribute.Name): $($attribute.Value)"
            }
    
            # Bind the DataTable to the DataGridView
            #$script:dataGridView.DataSource = $script:dataTable
    
            #$gridGroup.Controls.Add($script:dataGridView)
    
            # Show the dataTableGroupBox and set its text to the XML path
            #dataTableGroupBox.Text = $xmlPath
            #$dataTableGroupBox.Visible = $true
            #$fileTextBox.Text = $xmlPath
            #$fileTextBox.Visible = $true
            Update-ButtonState
    
            # Populate the input boxes with the first row values
            $script:xmlContent = [xml](Get-Content $script:xmlPath)
            #if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
            if ($script:xmlContent.Attributes -and $script:xmlContent.Attributes.Attr) {
    
    
                $fovTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value
                $heightTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value
                $widthTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value
                $headtrackerEnabledComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                $HeadtrackingSourceComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
    
                    if ($debug) {Write-Host "debug: try to Populate the input boxes with the first row values" -BackgroundColor White -ForegroundColor Black}
    
                Set-ProfileArray

            }

            # Update button state
            Update-ButtonState
        } else {
            [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
        }


    }
}

$AutoDetectSCPath = Get-GameRootDirFromRegistry

$openLiveFolderMenuItem = New-Object System.Windows.Forms.MenuItem
$openLiveFolderMenuItem.Text = "&Find Star Citizen Directory Manually"
$openLiveFolderMenuItem.Add_Click({
    Open-LiveFolder
})
$fileMenuItem.MenuItems.Add($openLiveFolderMenuItem)  # Add the Open Live Folder menu item to the File menu

#add an item Open Profile, which will load the profile.json file
$openProfileMenuItem = New-Object System.Windows.Forms.MenuItem
$openProfileMenuItem.Text = "&Open Profile"
$openProfileMenuItem.Add_Click({
    Open-Profile
})
$fileMenuItem.MenuItems.Add($openProfileMenuItem)  # Add the Open Profile menu item to the File menu

#add am item - Save Profile, which will save the profile.json file
$saveProfileMenuItem = New-Object System.Windows.Forms.MenuItem
$saveProfileMenuItem.Text = "&Save Profile"
$saveProfileMenuItem.Add_Click({
    Save-Profile
})
$fileMenuItem.MenuItems.Add($saveProfileMenuItem)  # Add the Save Profile menu item to the File menu


$actionsMenuItem = New-Object System.Windows.Forms.MenuItem
$actionsMenuItem.Text = "&Actions"
$mainMenu.MenuItems.Add($actionsMenuItem)

#$toolsMenuItem = New-Object System.Windows.Forms.MenuItem
#$toolsMenuItem.Text = "&Tools"
#$mainMenu.MenuItems.Add($toolsMenuItem)

$helpMenuItem = New-Object System.Windows.Forms.MenuItem
$helpMenuItem.Text = "&Help"
$mainMenu.MenuItems.Add($helpMenuItem)

$loadsettingsfromGameMenuItem = New-Object System.Windows.Forms.MenuItem
$loadsettingsfromGameMenuItem.Text = "&Load Settings from Game"
$loadsettingsfromGameMenuItem.Add_Click({
    Import-SettingsFromGame
})
$actionsMenuItem.MenuItems.Add($loadsettingsfromGameMenuItem)  # Add the Load Settings from Game menu item to the Actions menu

$loadsettingsfromProfileMenuItem = New-Object System.Windows.Forms.MenuItem
$loadsettingsfromProfileMenuItem.Text = "&Load Settings from Profile"
$loadsettingsfromProfileMenuItem.Add_Click({
    $script:xmlPath = $($script:profileArray.AttributesXmlPath)
    #Write-Host "Loading from profile: $($script:profileArray.AttributesXmlPath)" -BackgroundColor White -ForegroundColor Black
    if ($null -ne $script:xmlPath) {
        Open-XMLViewer($script:xmlPath)
    } else {
        $statusBar.Text = "Profile JSON doesn't contain attributes path."
        [System.Windows.Forms.MessageBox]::Show("profile json doesnt contain attributes path?")
    }
})
$actionsMenuItem.MenuItems.Add($loadsettingsfromProfileMenuItem)  # Add the Load Settings from Profile menu item to the Actions menu
$saveSettingsToGameMenuItem = New-Object System.Windows.Forms.MenuItem
$saveSettingsToGameMenuItem.Text = "&Save Settings to Game"
$saveSettingsToGameMenuItem.Add_Click({
    Save-SettingsToGame
})
$actionsMenuItem.MenuItems.Add($saveSettingsToGameMenuItem)  # Add the Save Settings to Game menu item to the Actions menu

# Add an item to the menu called "Open XML"
$openXmlMenuItem = New-Object System.Windows.Forms.MenuItem
$openXmlMenuItem.Text = "&Open XML"
$openXmlMenuItem.Enabled = $false
$openXmlMenuItem.Visible = $false

$openXmlMenuItem.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "XML Files (attributes.xml)|attributes.xml"
    $openFileDialog.Title = "Select the attributes.xml file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:xmlPath = $openFileDialog.FileName
        if (Test-Path $script:xmlPath) {
            try {
                $script:xmlContent = [xml](Get-Content $script:xmlPath)
                $gridGroup.Controls.Clear()

                #$script:dataGridView = New-Object System.Windows.Forms.DataGridView
                #$script:dataGridView.Width = 550
                #$script:dataGridView.Height = 200
                #$script:dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                $script:dataTable = New-Object System.Data.DataTable

                # Add columns to the DataTable
                if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                    $script:xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                        $script:dataTable.Columns.Add($_.Name) | Out-Null
                    }

                    # Add rows to the DataTable
                    $script:xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                        $row = $script:dataTable.NewRow()
                        $_.Attributes | ForEach-Object {
                            $row[$_.Name] = $_.Value
                        }
                        $script:dataTable.Rows.Add($row)
                    }

                    # Bind the DataTable to the DataGridView
                    #$script:dataGridView.DataSource = $script:dataTable

                    #$gridGroup.Controls.Add($script:dataGridView)

                    # Show the dataTableGroupBox and set its text to the XML path
                    $dataTableGroupBox.Text = $xmlPath
                    $dataTableGroupBox.Visible = $true
                    Update-ButtonState

                    # Populate the input boxes with the first row values
                    $script:xmlContent = [xml](Get-Content $script:xmlPath)
                    if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {


                        $fovTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value
                        $heightTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value
                        $widthTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value
                        $headtrackerEnabledComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                        $HeadtrackingSourceComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
                        $chromaticAberrationTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ChromaticAberration" } | Select-Object -ExpandProperty value
                        #$AutoZoomTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                        $AutoZoomComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                        #$MotionBlurTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
                        $MotionBlurComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
                        $ShakeScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ShakeScale" } | Select-Object -ExpandProperty value
                        $CameraSpringMovementTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "CameraSpringMovement" } | Select-Object -ExpandProperty value
                        #$FilmGrainTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
                        $FilmGrainComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
                        $GForceBoostZoomScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceBoostZoomScale" } | Select-Object -ExpandProperty value
                        $GForceHeadBobScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceHeadBobScale" } | Select-Object -ExpandProperty value
                        $HeadtrackingEnableRollFPSComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingEnableRollFPS" } | Select-Object -ExpandProperty value
                        $HeadtrackingDuringFPSComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingDisableDuringWalking" } | Select-Object -ExpandProperty value
                        $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingThirdPersonCameraToggle" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIDistance" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIHeight" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_EscMenuSettings_EscMenuScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIScale" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_HelmetVisorLensDepth.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorDistance" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_HelmetVisorLens_AspectModifier.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorAspectModifier" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorHeight" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdVisorScale" } | Select-Object -ExpandProperty value
                        $ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterMode" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_TheatreMode_Scale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeScale" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_TheatreMode_Curvature.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeCurvature" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_TheatreMode_Distance.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdTheaterModeDistance" } | Select-Object -ExpandProperty value
                        #$textboxExpCategory_UserSettings_StereoScaleformDepth.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdUIDistance" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_UserSettings_StereoStrength.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdIPDScale" } | Select-Object -ExpandProperty value
                        $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdCursorSize" } | Select-Object -ExpandProperty value
                        $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdAutomaticSwitching" } | Select-Object -ExpandProperty value
                        $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdActorControlMode" } | Select-Object -ExpandProperty value
                        $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HmdfpsAdsDominantEye" } | Select-Object -ExpandProperty value
                        
                        if ($debug) {Write-Host "debug: try to Populate the input boxes with the xml data" -BackgroundColor White -ForegroundColor Black}


                        Set-ProfileArray

                    }


                    # Update button state
                    Update-ButtonState
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                }
            } catch {
                #[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
                $statusBar.Text = "[Error 101] An error occurred while loading the XML file"
            }
        } else {
            $statusBar.Text = "[Error 103] XML file not found."
            [System.Windows.Forms.MessageBox]::Show("[Error 103] XML file not found.")
        }
    }
})
$actionsMenuItem.MenuItems.Add($openXmlMenuItem)

$darkModeMenuItem = New-Object System.Windows.Forms.MenuItem
$darkModeMenuItem.Text = "Enable Dark Mode"
$darkModeMenuItem.Add_Click({
    Switch-DarkMode
})
$actionsMenuItem.MenuItems.Add($darkModeMenuItem)

$CheckForUpdatesMenuItem = New-Object System.Windows.Forms.MenuItem
$CheckForUpdatesMenuItem.Text = "Check for &Updates"
$CheckForUpdatesMenuItem.Add_Click({
    # Version check script block
    try {
        $url = "https://raw.githubusercontent.com/troubleNZ/SC-VRse/main/starcitizen_powertool.ps1"
        $remoteContent = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        if ($remoteContent.StatusCode -eq 200) {
            $remoteScriptVersion = ($remoteContent.Content -split "`n" | Where-Object { $_ -match '\$scriptVersion' } | Select-Object -First 1) -replace '.*"(.*)".*', '$1'
            if ([version]$scriptVersion -lt [version]$remoteScriptVersion) {
                $statusBar.Text = "Update available! Current version: $scriptVersion, Latest version: $remoteScriptVersion"
            } else {
                $statusBar.Text = "You are using the latest version: $scriptVersion"
            }
        } else {
            $statusBar.Text = "Failed to check for updates. HTTP Status: $($remoteContent.StatusCode)"
        }
    } catch {
        $statusBar.Text = "Error checking for updates: $($_.Exception.Message)"
        Write-Host "Error checking for updates: $($_.Exception.Message)" -ForegroundColor Red
    }
})
$helpMenuItem.MenuItems.Add($CheckForUpdatesMenuItem)  # Add the GitHub menu item to the main menu


$GithubMenuItem = New-Object System.Windows.Forms.MenuItem
$GithubMenuItem.Text = "Open &GitHub Repo"
$GithubMenuItem.Add_Click({
    Start-Process "https://github.com/troubleNZ/SC-VRse"
})
$helpMenuItem.MenuItems.Add($GithubMenuItem)  # Add the GitHub menu item to the main menu

$DiscordMenuItem = New-Object System.Windows.Forms.MenuItem
$DiscordMenuItem.Text = "Open The VR Citizen &Discord"
$DiscordMenuItem.Add_Click({
    Start-Process "https://discord.gg/g2jn2vzju3"
})
$helpMenuItem.MenuItems.Add($DiscordMenuItem)  # Add the Discord menu item to the main menu

$creditsMenuItem = New-Object System.Windows.Forms.MenuItem
$creditsMenuItem.Text = "&Credits"
$creditsMenuItem.Add_Click({
    $creditsForm = New-Object System.Windows.Forms.Form
    $creditsForm.Text = "Credits"
    $creditsForm.Width = (400 * $script:ScaleMultiplier)
    $creditsForm.Height = (350 * $script:ScaleMultiplier)
    $creditsForm.StartPosition = 'CenterScreen'
    $creditsForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $creditsForm.MaximizeBox = $false
    $creditsForm.MinimizeBox = $false

    $creditsPanel = New-Object System.Windows.Forms.Panel
    $creditsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $creditsPanel.AutoScroll = $false
    $creditsForm.Controls.Add($creditsPanel)

    $creditsLabel = New-Object System.Windows.Forms.Label
    $creditsLabel.Text = "SC/VR Powertools Credits:" +
        "`n`n" +
        "This tool is not affiliated with CIG or Star Citizen. Use at your own risk." +
        "`n`n" +
        "This tool is open source and available on GitHub:" +
        "`n" +
        "https://github.com/troubleNZ/SC-VRse" +
        "`n" +
        "`n" +
        "To get help with Star Citzen in VR, and find other VR enthusiasts," +
        "`n" +
        "Join Chachi's VR Citizen Discord"

    $creditsLabel.AutoSize = $false
    $creditsLabel.Top = (10 * $script:ScaleMultiplier)
    $creditsLabel.Left = (10 * $script:ScaleMultiplier)
    $creditsLabel.Width = (380 * $script:ScaleMultiplier)
    $creditsLabel.Height = (250 * $script:ScaleMultiplier)
    $creditsLabel.TextAlign = 'MiddleCenter'
    $creditsLabel.BackColor = [System.Drawing.Color]::Transparent
    $creditsLabel.Font = New-Object System.Drawing.Font("Arial", [math]::Round(10 * $script:ScaleMultiplier))
    $creditsLabel.ForeColor = [System.Drawing.Color]::Black
    $creditsLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $creditsLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $creditsLabel.Text = $creditsLabel.Text -replace "`n", [Environment]::NewLine  # Replace `n with new line

    $creditsPanel.Controls.Add($creditsLabel)

    $creditsForm.ShowDialog()
})

$helpMenuItem.MenuItems.Add($creditsMenuItem)  # Add the Credits menu item to the Help menu



#add an item - Exit, which will close the application
$exitMenuItem = New-Object System.Windows.Forms.MenuItem
$exitMenuItem.Text = "E&xit"
$exitMenuItem.Add_Click({
    $form.Close()
})
$fileMenuItem.MenuItems.Add($exitMenuItem)  # Add the Exit menu item to the File menu

$form.Menu = $mainMenu  # Set the main menu of the form to the created menu

$gridGroup = New-Object System.Windows.Forms.Panel
$gridGroup.Width = (550 * $script:ScaleMultiplier)
$gridGroup.Height = (300 * $script:ScaleMultiplier)
$gridGroup.Top = (200 * $script:ScaleMultiplier)  # Adjusted the Top property to move the panel up
$gridGroup.Left = (20 * $script:ScaleMultiplier)
#$gridGroup.Visible = $false

#$form.Controls.Add($gridGroup)

# Add a group box for the DataTable
$dataTableGroupBox = New-Object System.Windows.Forms.GroupBox
$dataTableGroupBox.Top = (180 * $script:ScaleMultiplier)  # Position it above the DataTable
$dataTableGroupBox.Left = (20 * $script:ScaleMultiplier)
$dataTableGroupBox.Width = (550 * $script:ScaleMultiplier)
$dataTableGroupBox.Height = (220 * $script:ScaleMultiplier)  # Adjust height to fit the DataTable
$dataTableGroupBox.Visible = $false  # Initially hide the group box

#$form.Controls.Add($dataTableGroupBox)

$loadFromProfileButton = New-Object System.Windows.Forms.Button
$loadFromProfileButton.Name = "LoadFromProfileButton"
$loadFromProfileButton.Text = "Import settings from profile"
$loadFromProfileButton.Width = (200 * $script:ScaleMultiplier)
$loadFromProfileButton.Height = (30 * $script:ScaleMultiplier)
$loadFromProfileButton.Top = (30 * $script:ScaleMultiplier)
$loadFromProfileButton.Left = (20 * $script:ScaleMultiplier)
$loadFromProfileButton.TabIndex = 4
$loadFromProfileButton.Enabled = $loadedProfile                 #$false  # Initially disabled
$loadFromProfileButton.Visible = $loadedProfile
#$tabVRSettings_LegacySettings.Controls.Add($loadFromProfileButton)

$loadFromProfileButton.Add_Click({
    $script:xmlPath = $($script:profileArray.AttributesXmlPath)
    #Write-Host "Loading from profile: $($script:profileArray.AttributesXmlPath)" -BackgroundColor White -ForegroundColor Black
    if ($null -ne $script:xmlPath) {
        Open-XMLViewer($script:xmlPath)
    } else {
        $statusBar.Text = "Profile JSON doesn't contain attributes path."
        [System.Windows.Forms.MessageBox]::Show("profile json doesnt contain attributes path?")
    }
})

# Helper function to safely extract attribute values when results are not found in XML
function Get-AttributeValue {
    param (
        [string]$attributeName
    )
    if ($script:xmlContent.Attributes.Attr) {
        $attribute = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq $attributeName }
        if ($attribute) {
            return $attribute.value
        } else {    # return our DEFAULT VALUE
            switch ($attributeName) {
                "FilmGrain" { return 1 }
                "MotionBlur" { return 1 }
                "AutoZoomOnSelectedTarget" { return 1 }
                "HeadtrackingDisableDuringWalking" { return 1 }
                default { return $null }
            }
        }
    } else {
        return $null
    }
}
# Safely parse and set combo box values
function SetComboBoxValue {
    param (
        [System.Windows.Forms.ComboBox]$comboBox,
        [string]$value,
        [int]$defaultValue = 0
    )
    if ($value -match '^\d+$') {
        $comboBox.SelectedIndex = [int]$value
    } else {
        #if ($debug){[System.Windows.Forms.MessageBox]::Show("Invalid value for $($comboBox.Name). Setting to default ($defaultValue).")}
        #$statusBar.Text = "Invalid value for $($comboBox.Name). Setting to default ($defaultValue)."
        $comboBox.SelectedIndex = $comboBox.$defaultValue
    }
}

function Import-SettingsFromGame {
    try {
        $script:xmlContent = [xml](Get-Content $script:xmlPath)
        if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {

            if ($script:xmlContent.Attributes -and $script:xmlContent.Attributes.Attr) {

                $fovTextBox.Text = Get-AttributeValue "FOV"
                $widthTextBox.Text = Get-AttributeValue "Width"
                $heightTextBox.Text = Get-AttributeValue "Height"

                SetComboBoxValue -comboBox $headtrackerEnabledComboBox -value (Get-AttributeValue "HeadtrackingToggle")
                SetComboBoxValue -comboBox $HeadtrackingSourceComboBox -value (Get-AttributeValue "HeadtrackingSource")
                $chromaticAberrationTextBox.Text = Get-AttributeValue "ChromaticAberration"
                SetComboBoxValue -comboBox $AutoZoomComboBox -value (Get-AttributeValue "AutoZoomOnSelectedTarget")
                SetComboBoxValue -comboBox $MotionBlurComboBox -value (Get-AttributeValue "MotionBlur")
                $ShakeScaleTextBox.Text = Get-AttributeValue "ShakeScale"
                $CameraSpringMovementTextBox.Text = Get-AttributeValue "CameraSpringMovement"
                SetComboBoxValue -comboBox $FilmGrainComboBox -value (Get-AttributeValue "FilmGrain")
                $GForceBoostZoomScaleTextBox.Text = Get-AttributeValue "GForceBoostZoomScale"
                $GForceHeadBobScaleTextBox.Text = Get-AttributeValue "GForceHeadBobScale"
                SetComboBoxValue -comboBox $HeadtrackingEnableRollFPSComboBox -value (Get-AttributeValue "HeadtrackingEnableRollFPS")
                SetComboBoxValue -comboBox $HeadtrackingDisableDuringWalkingComboBox -value (Get-AttributeValue "HeadtrackingDisableDuringWalking")
                SetComboBoxValue -comboBox $HeadtrackingThirdPersonCameraToggleComboBox -value (Get-AttributeValue "HeadtrackingThirdPersonCameraToggle")

                $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text = Get-AttributeValue "HmdUIDistance"
                $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text = (Get-AttributeValue "HmdUIHeight")
                $textboxExpCategory_EscMenuSettings_EscMenuScale.Text = Get-AttributeValue "HmdUIScale"
                $textboxExpCategory_HelmetVisorLensDepth.Text = Get-AttributeValue "HmdVisorDistance"
                $textboxExpCategory_HelmetVisorLens_AspectModifier.Text = Get-AttributeValue "HmdVisorAspectModifier"
                $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text = Get-AttributeValue "HmdVisorHeight"
                $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text = Get-AttributeValue "HmdVisorScale"
                SetComboBoxValue -comboBox $ComboboxExpCategory_MirrorMode_StereoMirrorMode -value (Get-AttributeValue "HmdTheaterMode")
                $textboxExpCategory_TheatreMode_Scale.Text = Get-AttributeValue "HmdTheaterModeScale"
                $textboxExpCategory_TheatreMode_Curvature.Text = Get-AttributeValue "HmdTheaterModeCurvature"
                $textboxExpCategory_TheatreMode_Distance.Text = Get-AttributeValue "HmdTheaterModeDistance"
                #$textboxExpCategory_UserSettings_StereoScaleformDepth.Text = Get-AttributeValue "HmdUIDistance"
                $textboxExpCategory_UserSettings_StereoStrength.Text = Get-AttributeValue "HmdIPDScale"
                $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text = Get-AttributeValue "HmdCursorSize"
                SetComboBoxValue -comboBox $ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch -value (Get-AttributeValue "HmdAutomaticSwitching")
                SetComboBoxValue -comboBox $ComboboxExpCategory_EscMenuSettings_HmdActorControlMode -value (Get-AttributeValue "HmdActorControlMode")
                SetComboBoxValue -comboBox $ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye -value (Get-AttributeValue "HmdfpsAdsDominantEye")

                if ($debug) {[System.Windows.Forms.MessageBox]::Show("Debug: XML looks good.")}
                Update-ButtonState
                Set-ProfileArray
                #if ($debug) {Write-Host "importButton lets see Paul Allens ProfileArray : " $script:profileArray -BackgroundColor White -ForegroundColor Black}
            } else {
                $statusBar.Text = "No attributes found in the XML file."
                #if ($debug) {[System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")}
            }
        }
    } catch {
        $statusBar.Text = "[Error 102] An error occurred while loading the XML file"
        if ($debug) {[System.Windows.Forms.MessageBox]::Show("[Error 102] An error occurred while loading the XML file: $($_.Exception.Message)")
        Write-Host "[Error 102] An error occurred while loading the XML file: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "------------"
        Write-Host "xmlPath " $script:xmlPath
        Set-ProfileArray
        }
    }
}



$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import settings from Game"
$importButton.Name = "ImportButton"
$importButton.Width = (200 * $script:ScaleMultiplier)
$importButton.Height = (30 * $script:ScaleMultiplier)
$importButton.Top = (30 * $script:ScaleMultiplier)
$importButton.Left = (260 * $script:ScaleMultiplier)
$importButton.TabIndex = 5
$importButton.TabStop = $false
$importButton.Visible = $false  # Initially hidden
$importButton.Enabled = $false  # Initially disabled


$importButton.Add_Click({
    Import-SettingsFromGame
})

# Initially disable the import and save buttons
$importButton.Enabled = $false
#$tabVRSettings_LegacySettings.Controls.Add($importButton)

$fovLabel = New-Object System.Windows.Forms.Label
$fovLabel.Text = "FOV"
$fovLabel.Top = (70 * $script:ScaleMultiplier)
$fovLabel.Left = (150 * $script:ScaleMultiplier)
$fovLabel.Width = (30 * $script:ScaleMultiplier)
$fovLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($fovLabel)

$fovTextBox = New-Object System.Windows.Forms.TextBox
$fovTextBox.Name = "FOVTextBox"
$fovTextBox.Top = (70 * $script:ScaleMultiplier)
$fovTextBox.Left = (185 * $script:ScaleMultiplier)
$fovTextBox.Width = (40 * $script:ScaleMultiplier)
$fovTextBox.TextAlign = 'Left'
$fovTextBox.AcceptsTab = $true
$fovTextBox.TabIndex = 6
$tabVRSettings_LegacySettings.Controls.Add($fovTextBox)

$widthLabel = New-Object System.Windows.Forms.Label
$widthLabel.Text = "Width"
$widthLabel.Top = (70 * $script:ScaleMultiplier)
$widthLabel.Left = (215 * $script:ScaleMultiplier)
$widthLabel.Width = (50 * $script:ScaleMultiplier)
$widthLabel.Height = (20 * $script:ScaleMultiplier)
$widthLabel.TextAlign = 'MiddleRight'
$tabVRSettings_LegacySettings.Controls.Add($widthLabel)

$widthTextBox = New-Object System.Windows.Forms.TextBox
$widthTextBox.Name = "WidthTextBox"
$widthTextBox.Top = (70 * $script:ScaleMultiplier)
$widthTextBox.Left = (280 * $script:ScaleMultiplier)
$widthTextBox.Width = (40 * $script:ScaleMultiplier)
$widthTextBox.TextAlign = 'Left'
$widthTextBox.TabIndex = 7
$tabVRSettings_LegacySettings.Controls.Add($widthTextBox)

$heightLabel = New-Object System.Windows.Forms.Label
$heightLabel.Text = "Height"
$heightLabel.Top = (70 * $script:ScaleMultiplier)
$heightLabel.Left = (330 * $script:ScaleMultiplier)
$heightLabel.Width = (50 * $script:ScaleMultiplier)
$heightLabel.Height = (20 * $script:ScaleMultiplier)
$heightLabel.TextAlign = 'MiddleRight'
$tabVRSettings_LegacySettings.Controls.Add($heightLabel)

$heightTextBox = New-Object System.Windows.Forms.TextBox
$heightTextBox.Name = "HeightTextBox"
$heightTextBox.Top = (70 * $script:ScaleMultiplier)
$heightTextBox.Left = (390 * $script:ScaleMultiplier)
$heightTextBox.Width = (40 * $script:ScaleMultiplier)
$heightTextBox.TextAlign = 'Left'
$heightTextBox.TabIndex = 8
$tabVRSettings_LegacySettings.Controls.Add($heightTextBox)

$HeadtrackingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingLabel.Text = "Headtracking Toggle"
$HeadtrackingLabel.Top = (110 * $script:ScaleMultiplier)
$HeadtrackingLabel.Left = (10 * $script:ScaleMultiplier)
$HeadtrackingLabel.Width = (150 * $script:ScaleMultiplier)
$HeadtrackingLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingLabel)

$headtrackerEnabledComboBox = New-Object System.Windows.Forms.ComboBox
$headtrackerEnabledComboBox.Name = "headtrackerEnabledComboBox"
$headtrackerEnabledComboBox.Top = (110 * $script:ScaleMultiplier)
$headtrackerEnabledComboBox.Left = (190 * $script:ScaleMultiplier)
$headtrackerEnabledComboBox.Width = (90 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$headtrackerEnabledComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$headtrackerEnabledComboBox.Items.AddRange(@(0, 1))
$headtrackerEnabledComboBox.items.Add("Disabled")
$headtrackerEnabledComboBox.items.Add("Enabled")
$headtrackerEnabledComboBox.TabIndex = 9
$headtrackerEnabledComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($headtrackerEnabledComboBox)

$HeadtrackingSourceLabel = New-Object System.Windows.Forms.Label
$HeadtrackingSourceLabel.Text = "Headtracking Source"
$HeadtrackingSourceLabel.Top = (110 * $script:ScaleMultiplier)
$HeadtrackingSourceLabel.Left = (290 * $script:ScaleMultiplier)
$HeadtrackingSourceLabel.Width = (150 * $script:ScaleMultiplier)
$HeadtrackingSourceLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingSourceLabel)

$HeadtrackingSourceComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingSourceComboBox.Name = "HeadtrackingSourceComboBox"
$HeadtrackingSourceComboBox.Top = (110 * $script:ScaleMultiplier)
$HeadtrackingSourceComboBox.Left = (440 * $script:ScaleMultiplier)
$HeadtrackingSourceComboBox.Width = (90 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$HeadtrackingSourceComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingSourceComboBox.Items.Add("None")
$HeadtrackingSourceComboBox.Items.Add("TrackIR")
$HeadtrackingSourceComboBox.Items.Add("Faceware")
$HeadtrackingSourceComboBox.Items.Add("Tobii")
$HeadtrackingSourceComboBox.Items.Add("unknown")
$HeadtrackingSourceComboBox.Items.Add("HMD")

$HeadtrackingSourceComboBox.TabIndex = 10
$HeadtrackingSourceComboBox.SelectedItem = $HeadtrackingSourceComboBox.Items[0]  # Set the default selected item to the first one
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingSourceComboBox)

$chromaticAberrationLabel = New-Object System.Windows.Forms.Label
$chromaticAberrationLabel.Text = "Chromatic Aberration"
$chromaticAberrationLabel.Top = (260 * $script:ScaleMultiplier)
$chromaticAberrationLabel.Left = (10 * $script:ScaleMultiplier)
$chromaticAberrationLabel.Width = (150 * $script:ScaleMultiplier)
$chromaticAberrationLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($chromaticAberrationLabel)

$chromaticAberrationTextBox = New-Object System.Windows.Forms.TextBox
$chromaticAberrationTextBox.Name = "ChromaticAberrationTextBox"
$chromaticAberrationTextBox.Top = (260 * $script:ScaleMultiplier)
$chromaticAberrationTextBox.Left = (230 * $script:ScaleMultiplier)
$chromaticAberrationTextBox.Width = (50 * $script:ScaleMultiplier)
$chromaticAberrationTextBox.TextAlign = 'Left'
$chromaticAberrationTextBox.TabIndex = 19
#$chromaticAberrationTextBox.DefaultValue  = 1
$chromaticAberrationTextBox.Text = "1"
$tabVRSettings_LegacySettings.Controls.Add($chromaticAberrationTextBox)

$AutoZoomLabel = New-Object System.Windows.Forms.Label
$AutoZoomLabel.Text = "Auto Zoom"
$AutoZoomLabel.Top = (260 * $script:ScaleMultiplier)
$AutoZoomLabel.Left = (290 * $script:ScaleMultiplier)
$AutoZoomLabel.Width = (80 * $script:ScaleMultiplier)
$AutoZoomLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($AutoZoomLabel)

$AutoZoomComboBox = New-Object System.Windows.Forms.ComboBox
$AutoZoomComboBox.Name = "AutoZoomComboBox"
$AutoZoomComboBox.Top = (260 * $script:ScaleMultiplier)
$AutoZoomComboBox.Left = (440 * $script:ScaleMultiplier)
$AutoZoomComboBox.Width = (90 * $script:ScaleMultiplier)
$AutoZoomComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$AutoZoomComboBox.Items.Add("Disabled")
$AutoZoomComboBox.Items.Add("Enabled")
$AutoZoomComboBox.TabIndex = 20
$AutoZoomComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($AutoZoomComboBox)

$MotionBlurLabel = New-Object System.Windows.Forms.Label
$MotionBlurLabel.Text = "Motion Blur"
$MotionBlurLabel.Top = (290 * $script:ScaleMultiplier)
$MotionBlurLabel.Left = (70 * $script:ScaleMultiplier)
$MotionBlurLabel.Width = (80 * $script:ScaleMultiplier)
$MotionBlurLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($MotionBlurLabel)

$MotionBlurComboBox = New-Object System.Windows.Forms.ComboBox
$MotionBlurComboBox.Name = "MotionBlurComboBox"
$MotionBlurComboBox.Top = (290 * $script:ScaleMultiplier)
$MotionBlurComboBox.Left = (190 * $script:ScaleMultiplier)
$MotionBlurComboBox.Width = (90 * $script:ScaleMultiplier)
$MotionBlurComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$MotionBlurComboBox.Items.Add("Disabled")
$MotionBlurComboBox.Items.Add("Enabled")
$MotionBlurComboBox.Items.Add("Ship Only")
$MotionBlurComboBox.Items.Add("Debug Mode")
$MotionBlurComboBox.TabIndex = 21
$MotionBlurComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($MotionBlurComboBox)

$ShakeScaleLabel = New-Object System.Windows.Forms.Label
$ShakeScaleLabel.Text = "Shake Scale"
$ShakeScaleLabel.Top = (170 * $script:ScaleMultiplier)
$ShakeScaleLabel.Left = (290 * $script:ScaleMultiplier)
$ShakeScaleLabel.Width = (80 * $script:ScaleMultiplier)
$ShakeScaleLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($ShakeScaleLabel)

$ShakeScaleTextBox = New-Object System.Windows.Forms.TextBox
$ShakeScaleTextBox.Name = "ShakeScaleTextBox"
$ShakeScaleTextBox.Top = (170 * $script:ScaleMultiplier)
$ShakeScaleTextBox.Left = (480 * $script:ScaleMultiplier)
$ShakeScaleTextBox.Width = (50 * $script:ScaleMultiplier)
$ShakeScaleTextBox.TextAlign = 'Left'
$ShakeScaleTextBox.TabIndex = 14
#$ShakeScaleTextBox.DefaultValue  = 1.0
$ShakeScaleTextBox.Text = "1.0"
$tabVRSettings_LegacySettings.Controls.Add($ShakeScaleTextBox)

$CameraSpringMovementLabel = New-Object System.Windows.Forms.Label
$CameraSpringMovementLabel.Text = "Camera Spring Movement"
$CameraSpringMovementLabel.Top = (200 * $script:ScaleMultiplier)
$CameraSpringMovementLabel.Left = (10 * $script:ScaleMultiplier)
$CameraSpringMovementLabel.Width = (180 * $script:ScaleMultiplier)
$CameraSpringMovementLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($CameraSpringMovementLabel)

$CameraSpringMovementTextBox = New-Object System.Windows.Forms.TextBox
$CameraSpringMovementTextBox.Name = "CameraSpringMovementTextBox"
$CameraSpringMovementTextBox.Top = (200 * $script:ScaleMultiplier)
$CameraSpringMovementTextBox.Left = (230 * $script:ScaleMultiplier)
$CameraSpringMovementTextBox.Width = (50 * $script:ScaleMultiplier)
$CameraSpringMovementTextBox.TextAlign = 'Left'
$CameraSpringMovementTextBox.TabIndex = 15
#$CameraSpringMovementTextBox.DefaultValue  = 1
$CameraSpringMovementTextBox.Text  = "1"
$tabVRSettings_LegacySettings.Controls.Add($CameraSpringMovementTextBox)

$FilmGrainLabel = New-Object System.Windows.Forms.Label
$FilmGrainLabel.Text = "Film Grain"
$FilmGrainLabel.Top = (200 * $script:ScaleMultiplier)
$FilmGrainLabel.Left = (290 * $script:ScaleMultiplier)
$FilmGrainLabel.Width = (80 * $script:ScaleMultiplier)
$FilmGrainLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($FilmGrainLabel)

$FilmGrainComboBox = New-Object System.Windows.Forms.ComboBox
$FilmGrainComboBox.Name = "FilmGrainComboBox"
$FilmGrainComboBox.Top = (200 * $script:ScaleMultiplier)
$FilmGrainComboBox.Left = (440 * $script:ScaleMultiplier)
$FilmGrainComboBox.Width = (90 * $script:ScaleMultiplier)
$FilmGrainComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$FilmGrainComboBox.Items.Add("Disabled")
$FilmGrainComboBox.Items.Add("Enabled")
$FilmGrainComboBox.TabIndex = 16
$FilmGrainComboBox.SelectedIndex = 1
#$FilmGrainComboBox.DefaultValue  = 1
$tabVRSettings_LegacySettings.Controls.Add($FilmGrainComboBox)

$GForceBoostZoomScaleLabel = New-Object System.Windows.Forms.Label
$GForceBoostZoomScaleLabel.Text = "G-Force Boost Zoom Scale"
$GForceBoostZoomScaleLabel.Top = (230 * $script:ScaleMultiplier)
$GForceBoostZoomScaleLabel.Left = (10 * $script:ScaleMultiplier)
$GForceBoostZoomScaleLabel.Width = (180 * $script:ScaleMultiplier)
$GForceBoostZoomScaleLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($GForceBoostZoomScaleLabel)

$GForceBoostZoomScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceBoostZoomScaleTextBox.Name = "GForceBoostZoomScaleTextBox"
$GForceBoostZoomScaleTextBox.Top = (230 * $script:ScaleMultiplier)
$GForceBoostZoomScaleTextBox.Left = (230 * $script:ScaleMultiplier)
$GForceBoostZoomScaleTextBox.Width = (50 * $script:ScaleMultiplier)
$GForceBoostZoomScaleTextBox.TextAlign = 'Left'
$GForceBoostZoomScaleTextBox.TabIndex = 17
#$GForceBoostZoomScaleTextBox.DefaultValue = 1.0
$GForceBoostZoomScaleTextBox.Text = "1.0"
$tabVRSettings_LegacySettings.Controls.Add($GForceBoostZoomScaleTextBox)

$GForceHeadBobScaleLabel = New-Object System.Windows.Forms.Label
$GForceHeadBobScaleLabel.Text = "G-Force Head Bob Scale"
$GForceHeadBobScaleLabel.Top = (230 * $script:ScaleMultiplier)
$GForceHeadBobScaleLabel.Left = (290 * $script:ScaleMultiplier)
$GForceHeadBobScaleLabel.Width = (170 * $script:ScaleMultiplier)
$GForceHeadBobScaleLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($GForceHeadBobScaleLabel)

$GForceHeadBobScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceHeadBobScaleTextBox.Name = "GForceHeadBobScaleTextBox"
$GForceHeadBobScaleTextBox.Top = (230 * $script:ScaleMultiplier)
$GForceHeadBobScaleTextBox.Left = (480 * $script:ScaleMultiplier)
$GForceHeadBobScaleTextBox.Width = (50 * $script:ScaleMultiplier)
$GForceHeadBobScaleTextBox.TextAlign = 'Left'
$GForceHeadBobScaleTextBox.TabIndex = 18
$tabVRSettings_LegacySettings.Controls.Add($GForceHeadBobScaleTextBox)

$HeadtrackingEnableRollFPSLabel = New-Object System.Windows.Forms.Label
$HeadtrackingEnableRollFPSLabel.Text = "Headtracking FPS Head Roll"
$HeadtrackingEnableRollFPSLabel.Top = (140 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSLabel.Left = (10 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSLabel.Width = (180 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingEnableRollFPSLabel)

$HeadtrackingEnableRollFPSComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingEnableRollFPSComboBox.Name = "HeadtrackingEnableRollFPSComboBox"
$HeadtrackingEnableRollFPSComboBox.Top = (140 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSComboBox.Left = (190 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSComboBox.Width = (90 * $script:ScaleMultiplier)
$HeadtrackingEnableRollFPSComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingEnableRollFPSComboBox.Items.Add("Disabled")
$HeadtrackingEnableRollFPSComboBox.Items.Add("Enabled")
$HeadtrackingEnableRollFPSComboBox.TabIndex = 11
$HeadtrackingEnableRollFPSComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingEnableRollFPSComboBox)

$HeadtrackingDisableDuringWalkingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingDisableDuringWalkingLabel.Text = "Headtracking in FPS"
$HeadtrackingDisableDuringWalkingLabel.Top = (140 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingLabel.Left = (290 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingLabel.Width = (150 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingDisableDuringWalkingLabel)

$HeadtrackingDisableDuringWalkingComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingDisableDuringWalkingComboBox.Name = "HeadtrackingDisableDuringWalkingComboBox"
$HeadtrackingDisableDuringWalkingComboBox.Top = (140 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingComboBox.Left = (440 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingComboBox.Width = (90 * $script:ScaleMultiplier)
$HeadtrackingDisableDuringWalkingComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingDisableDuringWalkingComboBox.Items.Add("On")
$HeadtrackingDisableDuringWalkingComboBox.Items.Add("Off")
$HeadtrackingDisableDuringWalkingComboBox.TabIndex = 12
$HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingDisableDuringWalkingComboBox)

$HeadtrackingThirdPersonCameraToggleLabel = New-Object System.Windows.Forms.Label
$HeadtrackingThirdPersonCameraToggleLabel.Text = "Headtracking in Third Person"
$HeadtrackingThirdPersonCameraToggleLabel.Top = (170 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleLabel.Left = (10 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleLabel.Width = (180 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleLabel.Height = (20 * $script:ScaleMultiplier)
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingThirdPersonCameraToggleLabel)

$HeadtrackingThirdPersonCameraToggleComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingThirdPersonCameraToggleComboBox.Name = "HeadtrackingThirdPersonCameraToggleComboBox"
$HeadtrackingThirdPersonCameraToggleComboBox.Top = (170 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleComboBox.Left = (190 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleComboBox.Width = (90 * $script:ScaleMultiplier)
$HeadtrackingThirdPersonCameraToggleComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingThirdPersonCameraToggleComboBox.Items.Add("Off")
$HeadtrackingThirdPersonCameraToggleComboBox.Items.Add("On")
$HeadtrackingThirdPersonCameraToggleComboBox.TabIndex = 13
$HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 0
$tabVRSettings_LegacySettings.Controls.Add($HeadtrackingThirdPersonCameraToggleComboBox)

# Update the state of the buttons after loading the XML content

$applySaveButton = New-Object System.Windows.Forms.Button
$applySaveButton.Name = "ApplySaveButton"
$applySaveButton.Text = "Apply Changes"
$applySaveButton.Font = New-Object System.Drawing.Font($applySaveButton.Font.FontFamily, [math]::Round($applySaveButton.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Bold)
$applySaveButton.Width = (150 * $script:ScaleMultiplier)
$applySaveButton.Height = (30 * $script:ScaleMultiplier)
$applySaveButton.Top = (385 * $script:ScaleMultiplier)
$applySaveButton.Left = (250 * $script:ScaleMultiplier)
$applySaveButton.TabIndex = 22
$applySaveButton.Enabled = $false  # Initially disabled
#$applySaveButton.Add_Click({Save-SettingsToGame})
$applySaveButton.Add_Click({
    # Validate that we have a loaded XML file
    if (-not $script:attributesXmlPath) { return }

    # Update every mapped attribute in the XML file
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "FOV" `
                        -NewValue $fovTextBox.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "Height" `
                        -NewValue $heightTextBox.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "Width" `
                        -NewValue $widthTextBox.Text

    # Headtracking
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HeadtrackingToggle" `
                        -NewValue ($headtrackerEnabledComboBox.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HeadtrackingSource" `
                        -NewValue ($HeadtrackingSourceComboBox.SelectedIndex)

    # Chromatic Aberration
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "ChromaticAberration" `
                        -NewValue $chromaticAberrationTextBox.Text

    # Auto‑Zoom (store index, not text)
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "AutoZoomOnSelectedTarget" `
                        -NewValue ($AutoZoomComboBox.SelectedIndex)

    # MotionBlur
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "MotionBlur" `
                        -NewValue ($MotionBlurComboBox.SelectedIndex)

    # ShakeScale, CameraSpringMovement, FilmGrain, G‑Force scales
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "ShakeScale" `
                        -NewValue $ShakeScaleTextBox.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "CameraSpringMovement" `
                        -NewValue $CameraSpringMovementTextBox.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "FilmGrain" `
                        -NewValue ($FilmGrainComboBox.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "GForceBoostZoomScale" `
                        -NewValue $GForceBoostZoomScaleTextBox.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "GForceHeadBobScale" `
                        -NewValue $GForceHeadBobScaleTextBox.Text

    # Headtracking advanced options
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HeadtrackingEnableRollFPS" `
                        -NewValue ($HeadtrackingEnableRollFPSComboBox.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HeadtrackingDisableDuringWalking" `
                        -NewValue ($HeadtrackingDuringFPSComboBox.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HeadtrackingThirdPersonCameraToggle" `
                        -NewValue ($HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex)

    # Experimental VR – all textboxes (store the string values)
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdUIDistance" `
                        -NewValue $textboxExpCategory_EscMenuSettings_EscMenuDistance.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdUIHeight" `
                        -NewValue $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdUIScale" `
                        -NewValue $textboxExpCategory_EscMenuSettings_EscMenuScale.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdVisorDistance" `
                        -NewValue $textboxExpCategory_HelmetVisorLensDepth.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdVisorAspectModifier" `
                        -NewValue $textboxExpCategory_HelmetVisorLens_AspectModifier.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdVisorHeight" `
                        -NewValue $textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdVisorScale" `
                        -NewValue $textboxExpCategory_HelmetVisorLens_HmdVisorScale.Text

    # Mirror mode (store index)
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdTheaterMode" `
                        -NewValue ($ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdTheaterModeScale" `
                        -NewValue $textboxExpCategory_TheatreMode_Scale.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdTheaterModeCurvature" `
                        -NewValue $textboxExpCategory_TheatreMode_Curvature.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdTheaterModeDistance" `
                        -NewValue $textboxExpCategory_TheatreMode_Distance.Text

    # User Settings – IPD scale, Cursor size
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdIPDScale" `
                        -NewValue $textboxExpCategory_UserSettings_StereoStrength.Text

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdCursorSize" `
                        -NewValue $textboxExpCategory_ConsoleSettings_StereoCursorScale.Text

    # HMD dynamic mode
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdAutomaticSwitching" `
                        -NewValue ($ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex)

    # Actor control and dominant eye
    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdActorControlMode" `
                        -NewValue ($ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex)

    Update-XMLAttribute -XmlPath $script:attributesXmlPath `
                        -AttrName "HmdfpsAdsDominantEye" `
                        -NewValue ($ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex)

    # After all writes – refresh the UI
    Open-XMLViewer $script:attributesXmlPath

    if ($debug) { Write-Host "Applied changes to XML." }
})
# Initially disable the import and save buttons
$applySaveButton.Enabled = $false
#$tabVRSettings_LegacySettings.Controls.Add($applySaveButton)
$form.Controls.Add($applySaveButton)

$saveAndCloseButton = New-Object System.Windows.Forms.Button
$saveAndCloseButton.Name = "SaveAndCloseButton"
$saveAndCloseButton.Text = "Save and Close"
$saveAndCloseButton.Width = (150 * $script:ScaleMultiplier)
$saveAndCloseButton.Font = New-Object System.Drawing.Font($saveAndCloseButton.Font.FontFamily, [math]::Round($saveAndCloseButton.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Bold)
$saveAndCloseButton.Height = (30 * $script:ScaleMultiplier)
$saveAndCloseButton.Top = (385 * $script:ScaleMultiplier)
$saveAndCloseButton.Left = (420 * $script:ScaleMultiplier)
$saveAndCloseButton.TabIndex = 23
$saveAndCloseButton.Enabled = $false  # Initially disabled
<#$saveAndCloseButton.Add_Click({
    Save-SettingsToGame
    $form.Close()
})#>
# --- Save & Close -------------------------------------------------
$saveAndCloseButton.Add_Click({
    # Re‑use the Apply logic – we’ll call it then close.
    $applySaveButton.PerformClick()

    # Close the form after saving
    $form.Close()
})
#$tabVRSettings_LegacySettings.Controls.Add($saveAndCloseButton)
$form.Controls.Add($saveAndCloseButton)





# Experimental VR Settings -------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------
# needed a quick way to contain the new stuff so tucked it into its own group panel, accessed via button off $form


#"Experimental VR Settings"

#Group
$groupExp_UISettings = New-Object System.Windows.Forms.GroupBox
$groupExp_UISettings.Text = "UI Settings"
$groupExp_UISettings.Width = (250 * $script:ScaleMultiplier)
$groupExp_UISettings.Height = (100 * $script:ScaleMultiplier)
$groupExp_UISettings.Top = (20 * $script:ScaleMultiplier)         ## Adjusted the Top property to move the group box up
$groupExp_UISettings.Left = (5 * $script:ScaleMultiplier)
$groupExp_UISettings.Visible = $true
$tabVRSettings_Experimental.Controls.Add($groupExp_UISettings)


#r_StereoUILayerZPos = 3.1               ; the escape menu distance
$labelExpCategory_EscMenuSettings_EscMenuDistance = New-Object System.Windows.Forms.Label           #r_StereoUILayerZPos        HmdUIDistance
$labelExpCategory_EscMenuSettings_EscMenuDistance.Text = "Escape Menu Distance"
$labelExpCategory_EscMenuSettings_EscMenuDistance.Top = (20 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuDistance.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuDistance.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuDistance.Width = (149 * $script:ScaleMultiplier)
$groupExp_UISettings.Controls.Add($labelExpCategory_EscMenuSettings_EscMenuDistance)

$textboxExpCategory_EscMenuSettings_EscMenuDistance = New-Object System.Windows.Forms.TextBox           #HmdUIDistance
$textboxExpCategory_EscMenuSettings_EscMenuDistance.Name = "HmdUIDistance"
$textboxExpCategory_EscMenuSettings_EscMenuDistance.Top = (20 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuDistance.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuDistance.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuDistance.TextAlign = 'Left'
$textboxExpCategory_EscMenuSettings_EscMenuDistance.AcceptsTab = $true
$textboxExpCategory_EscMenuSettings_EscMenuDistance.TabIndex = 6                                            # remember to fix/set tab indexes for this new stuff.
$groupExp_UISettings.Controls.Add($textboxExpCategory_EscMenuSettings_EscMenuDistance)

#r_StereoUILayerYPos = 0.5               ; the escape menu height
$labelExpCategory_EscMenuSettings_EscMenuYPos = New-Object System.Windows.Forms.Label           #r_StereoUILayerYPos        HmdUIHeight
$labelExpCategory_EscMenuSettings_EscMenuYPos.Text = "Escape Menu Height"
$labelExpCategory_EscMenuSettings_EscMenuYPos.Top = (45 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuYPos.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuYPos.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuYPos.Width = (149 * $script:ScaleMultiplier)
$groupExp_UISettings.Controls.Add($labelExpCategory_EscMenuSettings_EscMenuYPos)

$textboxExpCategory_EscMenuSettings_EscMenuYPos = New-Object System.Windows.Forms.TextBox                                   #HmdUIHeight
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Name = "HmdUIHeight"
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Top = (45 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuYPos.TextAlign = 'Left'
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Text = "0.5"
$textboxExpCategory_EscMenuSettings_EscMenuYPos.AcceptsTab = $true
$textboxExpCategory_EscMenuSettings_EscMenuYPos.TabIndex = 6

$groupExp_UISettings.Controls.Add($textboxExpCategory_EscMenuSettings_EscMenuYPos)

#r_StereoUILayerScale = 4                ; how big the menu is in 3d space
$labelExpCategory_EscMenuSettings_EscMenuScale = New-Object System.Windows.Forms.Label           #r_StereoUILayerScale              HmdUIScale
$labelExpCategory_EscMenuSettings_EscMenuScale.Text = "Escape Menu Scale"
$labelExpCategory_EscMenuSettings_EscMenuScale.Top = (70 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuScale.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuScale.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_EscMenuScale.Width = (149 * $script:ScaleMultiplier)
$groupExp_UISettings.Controls.Add($labelExpCategory_EscMenuSettings_EscMenuScale)

$textboxExpCategory_EscMenuSettings_EscMenuScale = New-Object System.Windows.Forms.TextBox                                 # HmdUIScale
$textboxExpCategory_EscMenuSettings_EscMenuScale.Name = "HmdUIScale"
$textboxExpCategory_EscMenuSettings_EscMenuScale.Top = (70 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuScale.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuScale.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_EscMenuSettings_EscMenuScale.TextAlign = 'Left'
$textboxExpCategory_EscMenuSettings_EscMenuScale.AcceptsTab = $true
$textboxExpCategory_EscMenuSettings_EscMenuScale.TabIndex = 6
$groupExp_UISettings.Controls.Add($textboxExpCategory_EscMenuSettings_EscMenuScale)


#Group
$groupTheatremode = New-Object System.Windows.Forms.GroupBox
$groupTheatremode.Text = "Theatre Mode Settings"
$groupTheatremode.Width = (250 * $script:ScaleMultiplier)
$groupTheatremode.Height = (125 * $script:ScaleMultiplier)
$groupTheatremode.Top = (117 * $script:ScaleMultiplier)         ## Adjusted the Top property to move the group box up
$groupTheatremode.Left = (5 * $script:ScaleMultiplier)
$groupTheatremode.Visible = $true
$tabVRSettings_Experimental.Controls.Add($groupTheatremode)

#theatre mode (spelt properly)
<#
; -- Theatre Mode --
;r_StereoTheaterMode = 0                 ; force flat theater mode
r_StereoTheaterModeScale = 2            ; how big the theater window is in 3d space
r_StereoTheaterModeYPos = 0.1           ; how high in the air is it
r_StereoTheaterModeZPos = 2             ; how far away is it
#>
$labelExpCategory_TheatreMode_TheatreMode = New-Object System.Windows.Forms.Label
$labelExpCategory_TheatreMode_TheatreMode.Text = "Start in Theater Mode"
$labelExpCategory_TheatreMode_TheatreMode.Top = (20 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_TheatreMode.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_TheatreMode.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_TheatreMode.Width = (149 * $script:ScaleMultiplier)
$groupTheatremode.Controls.Add($labelExpCategory_TheatreMode_TheatreMode)

$ComboboxExpCategory_TheatreMode_TheatreMode = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_TheatreMode_TheatreMode.Name = "TheaterMode"
$ComboboxExpCategory_TheatreMode_TheatreMode.Top = (20 * $script:ScaleMultiplier)
$ComboboxExpCategory_TheatreMode_TheatreMode.Left = (160 * $script:ScaleMultiplier)
$ComboboxExpCategory_TheatreMode_TheatreMode.Width = (80 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_TheatreMode_TheatreMode.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_TheatreMode_TheatreMode.Items.AddRange(@(0, 1))
$ComboboxExpCategory_TheatreMode_TheatreMode.items.Add("Disabled")
$ComboboxExpCategory_TheatreMode_TheatreMode.items.Add("Enabled")
$ComboboxExpCategory_TheatreMode_TheatreMode.TabIndex = 9
$ComboboxExpCategory_TheatreMode_TheatreMode.SelectedIndex = 0
$groupTheatremode.Controls.Add($ComboboxExpCategory_TheatreMode_TheatreMode)


$labelExpCategory_TheatreMode_Scale = New-Object System.Windows.Forms.Label
$labelExpCategory_TheatreMode_Scale.Text = "Theater Mode Scale"
$labelExpCategory_TheatreMode_Scale.Top = (45 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Scale.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Scale.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Scale.Width = (149 * $script:ScaleMultiplier)
$groupTheatremode.Controls.Add($labelExpCategory_TheatreMode_Scale)

$textboxExpCategory_TheatreMode_Scale = New-Object System.Windows.Forms.TextBox
$textboxExpCategory_TheatreMode_Scale.Name = "Theater Mode Scale"
$textboxExpCategory_TheatreMode_Scale.Top = (45 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Scale.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Scale.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Scale.TextAlign = 'Left'
$textboxExpCategory_TheatreMode_Scale.AcceptsTab = $true
$textboxExpCategory_TheatreMode_Scale.TabIndex = 6
$groupTheatremode.Controls.Add($textboxExpCategory_TheatreMode_Scale)

$labelExpCategory_TheatreMode_Curvature = New-Object System.Windows.Forms.Label
$labelExpCategory_TheatreMode_Curvature.Text = "TheaterMode Curvature"
$labelExpCategory_TheatreMode_Curvature.Top = (70 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Curvature.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Curvature.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Curvature.Width = (149 * $script:ScaleMultiplier)
$groupTheatremode.Controls.Add($labelExpCategory_TheatreMode_Curvature)

$textboxExpCategory_TheatreMode_Curvature = New-Object System.Windows.Forms.TextBox            #HmdTheaterModeCurvature
$textboxExpCategory_TheatreMode_Curvature.Name = "HmdTheaterModeCurvature"
$textboxExpCategory_TheatreMode_Curvature.Top = (70 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Curvature.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Curvature.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Curvature.TextAlign = 'Left'
$textboxExpCategory_TheatreMode_Curvature.AcceptsTab = $true
$textboxExpCategory_TheatreMode_Curvature.TabIndex = 6
$groupTheatremode.Controls.Add($textboxExpCategory_TheatreMode_Curvature)

$labelExpCategory_TheatreMode_Distance = New-Object System.Windows.Forms.Label
$labelExpCategory_TheatreMode_Distance.Text = "Theater Mode Distance"
$labelExpCategory_TheatreMode_Distance.Top = (95 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Distance.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Distance.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_TheatreMode_Distance.Width = (149 * $script:ScaleMultiplier)
$groupTheatremode.Controls.Add($labelExpCategory_TheatreMode_Distance)

$textboxExpCategory_TheatreMode_Distance = New-Object System.Windows.Forms.TextBox          #HmdTheaterModeDistance
$textboxExpCategory_TheatreMode_Distance.Name = "TheaterModeDistance"
$textboxExpCategory_TheatreMode_Distance.Top = (95 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Distance.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Distance.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_TheatreMode_Distance.TextAlign = 'Left'
$textboxExpCategory_TheatreMode_Distance.AcceptsTab = $true
$textboxExpCategory_TheatreMode_Distance.TabIndex = 6
$groupTheatremode.Controls.Add($textboxExpCategory_TheatreMode_Distance)


#Group
$groupMirrorMode = New-Object System.Windows.Forms.GroupBox
$groupMirrorMode.Text = "Mirror Mode Settings"
$groupMirrorMode.Width = (250 * $script:ScaleMultiplier)
$groupMirrorMode.Height = (85 * $script:ScaleMultiplier)
$groupMirrorMode.Top = (240 * $script:ScaleMultiplier)         ## Adjusted the Top property to move the group box up
$groupMirrorMode.Left = (5 * $script:ScaleMultiplier)
$groupMirrorMode.Visible = $true
$tabVRSettings_Experimental.Controls.Add($groupMirrorMode)


#; -- Mirror Mode --                     ; r_StereoScreenOutput renamed to r_StereoMirrorMode in a4.6
                                        #;r_StereoScreenOutput = 0               ; display the VR output on monitor:  0 expanded view, 1 one eye only, 2 both eyes
                                        #;r_StereoMirrorMode = 0                ; 0 Left eye, , 1 Right Eye, 2 Aspect Ratio Left eye, 3 Aspect Ratio Left eye, 4 both eye, 10 checkerboard
$labelExpCategory_MirrorMode_StereoMirrorMode = New-Object System.Windows.Forms.Label
$labelExpCategory_MirrorMode_StereoMirrorMode.Text = "Mirror Mode"
$labelExpCategory_MirrorMode_StereoMirrorMode.Top = (25 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_StereoMirrorMode.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_StereoMirrorMode.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_StereoMirrorMode.Width = (90 * $script:ScaleMultiplier)
$groupMirrorMode.Controls.Add($labelExpCategory_MirrorMode_StereoMirrorMode)

$ComboboxExpCategory_MirrorMode_StereoMirrorMode = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Name = "MirrorMode"
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Top = (25 * $script:ScaleMultiplier)
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Left = (120 * $script:ScaleMultiplier)
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Width = (120 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Items.AddRange(@(0, 1))
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Left Eye")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Right Eye")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Left Eye A/Ratio")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Right Eye A/Ratio")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Both Eyes")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.items.Add("Checkerbox")
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.TabIndex = 9
$ComboboxExpCategory_MirrorMode_StereoMirrorMode.SelectedIndex = 0
$groupMirrorMode.Controls.Add($ComboboxExpCategory_MirrorMode_StereoMirrorMode)

#HmdMonitorMirrorModeSmoothing
$labelExpCategory_MirrorMode_Smoothing = New-Object System.Windows.Forms.Label          #HmdMonitorMirrorModeSmoothing r_StereoMirrorModeSmoothing
$labelExpCategory_MirrorMode_Smoothing.Text = "MirrorMode Smoothing"
$labelExpCategory_MirrorMode_Smoothing.Top = (55 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_Smoothing.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_Smoothing.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_MirrorMode_Smoothing.Width = (149 * $script:ScaleMultiplier)
$groupMirrorMode.Controls.Add($labelExpCategory_MirrorMode_Smoothing)

$ComboboxExpCategory_MirrorMode_Smoothing = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_MirrorMode_Smoothing.Name = "HmdMonitorMirrorModeSmoothing"
$ComboboxExpCategory_MirrorMode_Smoothing.Top = (55 * $script:ScaleMultiplier)
$ComboboxExpCategory_MirrorMode_Smoothing.Left = (160 * $script:ScaleMultiplier)
$ComboboxExpCategory_MirrorMode_Smoothing.Width = (80 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_MirrorMode_Smoothing.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_MirrorMode_Smoothing.Items.AddRange(@(0, 1))
$ComboboxExpCategory_MirrorMode_Smoothing.items.Add("Disabled")
$ComboboxExpCategory_MirrorMode_Smoothing.items.Add("Enabled")
$ComboboxExpCategory_MirrorMode_Smoothing.TabIndex = 9
$ComboboxExpCategory_MirrorMode_Smoothing.SelectedIndex = 0
$groupMirrorMode.Controls.Add($ComboboxExpCategory_MirrorMode_Smoothing)

# TODO Swap out $ComboboxExpCategory_MirrorMode_Smoothing for a 10 step slider from 0.0 to 1.0




#-- User specific settings --
#r_StereoScaleformDepth = 1.0            ; convergence distance of marker icons etc - varies between headsets and users
#r_StereoStrength    = 1.0               ; Hmd IPD Scale (floating value from 0.0 - 1.5 [ie 150%], default 100% ie. 1.0) - varies between users

# StereoScaleformDepth 
<#$labelExpCategory_UserSettings_StereoScaleformDepth = New-Object System.Windows.Forms.Label           #r_StereoScaleformDepth HmdUIDistance
$labelExpCategory_UserSettings_StereoScaleformDepth.Text = "Stereo Scaleform Depth"
$labelExpCategory_UserSettings_StereoScaleformDepth.Top = (40 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoScaleformDepth.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoScaleformDepth.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoScaleformDepth.Width = (149 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_UserSettings_StereoScaleformDepth)

$textboxExpCategory_UserSettings_StereoScaleformDepth = New-Object System.Windows.Forms.TextBox         #HmdUIDistance
$textboxExpCategory_UserSettings_StereoScaleformDepth.Name = "HmdUIDistance"
$textboxExpCategory_UserSettings_StereoScaleformDepth.Top = (40 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoScaleformDepth.Left = (450 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoScaleformDepth.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoScaleformDepth.TextAlign = 'Left'
$textboxExpCategory_UserSettings_StereoScaleformDepth.AcceptsTab = $true
$textboxExpCategory_UserSettings_StereoScaleformDepth.TabIndex = 6                                            # remember to fix/set tab indexes for this new stuff.
$tabVRSettings_Experimental.Controls.Add($textboxExpCategory_UserSettings_StereoScaleformDepth)#>


#Group
$groupExp_HelmetVisorSettings = New-Object System.Windows.Forms.GroupBox
$groupExp_HelmetVisorSettings.Text = "Helmet Visor Settings"
$groupExp_HelmetVisorSettings.Width = (250 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Height = (130 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Top = (20 * $script:ScaleMultiplier)         ## Adjusted the Top property to move the group box up
$groupExp_HelmetVisorSettings.Left = (295 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Visible = $true
$tabVRSettings_Experimental.Controls.Add($groupExp_HelmetVisorSettings)


#r_StereoUILensDepth = 3                 ; helmet vr lens / markers convergence distance
$labelExpCategory_HelmetVisorLensDepth = New-Object System.Windows.Forms.Label           #r_StereoUILensDepth  (not actually menu specific)
$labelExpCategory_HelmetVisorLensDepth.Text = "Visor Depth"
$labelExpCategory_HelmetVisorLensDepth.Top = (20 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLensDepth.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLensDepth.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLensDepth.Width = (140 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Controls.Add($labelExpCategory_HelmetVisorLensDepth)

$textboxExpCategory_HelmetVisorLensDepth = New-Object System.Windows.Forms.TextBox      #HmdVisorDistance
$textboxExpCategory_HelmetVisorLensDepth.Name = "HmdVisorDistance"
$textboxExpCategory_HelmetVisorLensDepth.Top = (20 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLensDepth.Left = (155 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLensDepth.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLensDepth.TextAlign = 'Left'
$textboxExpCategory_HelmetVisorLensDepth.AcceptsTab = $true
$textboxExpCategory_HelmetVisorLensDepth.TabIndex = 6
$groupExp_HelmetVisorSettings.Controls.Add($textboxExpCategory_HelmetVisorLensDepth)


#pl_lensdisplay.hmd_aspectModifier value="0.1"        ; helmet vr lens / aspect ratio stretch
$labelExpCategory_HelmetVisorLens_AspectModifier = New-Object System.Windows.Forms.Label           #pl_lensdisplay.hmd_aspectModifier
$labelExpCategory_HelmetVisorLens_AspectModifier.Text = "Visor Aspect Modifier"
$labelExpCategory_HelmetVisorLens_AspectModifier.Top = (45 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_AspectModifier.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_AspectModifier.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_AspectModifier.Width = (140 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Controls.Add($labelExpCategory_HelmetVisorLens_AspectModifier)

$textboxExpCategory_HelmetVisorLens_AspectModifier = New-Object System.Windows.Forms.TextBox      #HmdVisorAspectModifier
$textboxExpCategory_HelmetVisorLens_AspectModifier.Name = "HmdVisorAspectModifier"
$textboxExpCategory_HelmetVisorLens_AspectModifier.Top = (45 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_AspectModifier.Left = (155 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_AspectModifier.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_AspectModifier.TextAlign = 'Left'
$textboxExpCategory_HelmetVisorLens_AspectModifier.AcceptsTab = $true
$textboxExpCategory_HelmetVisorLens_AspectModifier.TabIndex = 6
$groupExp_HelmetVisorSettings.Controls.Add($textboxExpCategory_HelmetVisorLens_AspectModifier)


#pl_lensdisplay.hmd_position_offset_z value="0.5"        ; helmet vr lens / Offset Z
$labelExpCategory_HelmetVisorLens_HmdVisorHeight = New-Object System.Windows.Forms.Label           #pl_lensdisplay.hmd_position_offset_z
$labelExpCategory_HelmetVisorLens_HmdVisorHeight.Text = "Visor Vertical Offset"
$labelExpCategory_HelmetVisorLens_HmdVisorHeight.Top = (70 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorHeight.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorHeight.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorHeight.Width = (140 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Controls.Add($labelExpCategory_HelmetVisorLens_HmdVisorHeight)

$textboxExpCategory_HelmetVisorLens_HmdVisorHeight = New-Object System.Windows.Forms.TextBox      #HmdVisorHeight
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Name = "HmdVisorHeight"
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Top = (70 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Left = (155 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.TextAlign = 'Left'
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.AcceptsTab = $true
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.TabIndex = 6
$groupExp_HelmetVisorSettings.Controls.Add($textboxExpCategory_HelmetVisorLens_HmdVisorHeight)


#pl_lensdisplay.hmd_position_offset_z value="0.5"        ; helmet vr lens / Scale
$labelExpCategory_HelmetVisorLens_HmdVisorScale = New-Object System.Windows.Forms.Label           #pl_lensdisplay.hmd_position_offset_z
$labelExpCategory_HelmetVisorLens_HmdVisorScale.Text = "Visor Scale"
$labelExpCategory_HelmetVisorLens_HmdVisorScale.Top = (95 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorScale.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorScale.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_HelmetVisorLens_HmdVisorScale.Width = (140 * $script:ScaleMultiplier)
$groupExp_HelmetVisorSettings.Controls.Add($labelExpCategory_HelmetVisorLens_HmdVisorScale)

$textboxExpCategory_HelmetVisorLens_HmdVisorScale = New-Object System.Windows.Forms.TextBox      #HmdVisorScale
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.Name = "HmdVisorScale"
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.Top = (95 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.Left = (155 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.TextAlign = 'Left'
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.AcceptsTab = $true
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.TabIndex = 6
$groupExp_HelmetVisorSettings.Controls.Add($textboxExpCategory_HelmetVisorLens_HmdVisorScale)



#r_StereoStrength
$labelExpCategory_UserSettings_StereoStrength = New-Object System.Windows.Forms.Label           #r_StereoStrength           HmdIPDScale
$labelExpCategory_UserSettings_StereoStrength.Text = "IPD Scale Modifier"
$labelExpCategory_UserSettings_StereoStrength.Top = (165 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoStrength.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoStrength.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_UserSettings_StereoStrength.Width = (149 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_UserSettings_StereoStrength)

$textboxExpCategory_UserSettings_StereoStrength = New-Object System.Windows.Forms.TextBox                               #HmdIPDScale
$textboxExpCategory_UserSettings_StereoStrength.Name = "HmdIPDScale"
$textboxExpCategory_UserSettings_StereoStrength.Top = (165 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoStrength.Left = (450 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoStrength.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_UserSettings_StereoStrength.TextAlign = 'Left'
$textboxExpCategory_UserSettings_StereoStrength.AcceptsTab = $true
$textboxExpCategory_UserSettings_StereoStrength.TabIndex = 6                                            # remember to fix/set tab indexes for this new stuff.
$tabVRSettings_Experimental.Controls.Add($textboxExpCategory_UserSettings_StereoStrength)
$textboxExpCategory_UserSettings_StereoStrength.Text = "1.0"
#$textboxExpCategory_UserSettings_StereoStrength.DefaultValue = 1.0

#-- HMD specific settings --
#r_StereoDynamicModeSwitch
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch = New-Object System.Windows.Forms.Label           #r_StereoDynamicModeSwitch    HmdAutomaticSwitching
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch.Text = "HMD Removal Switch"
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch.Top = (190 * $script:ScaleMultiplier)
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_HMDSettings_StereoDynamicModeSwitch.Width = (149 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_HMDSettings_StereoDynamicModeSwitch)

$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Name = "HmdAutomaticSwitching"
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Top = (190 * $script:ScaleMultiplier)
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Left = (450 * $script:ScaleMultiplier)
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Width = (80 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Items.AddRange(@(0, 1))
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.items.Add("Disabled")
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.items.Add("Enabled")
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.SelectedIndex = 0
$tabVRSettings_Experimental.Controls.Add($ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch)

#r_StereoDebugDrawing                                                                                       # ; Draws the ` Console in 3d space or not. (0: flat, 1: in stereo space)
$labelExpCategory_ConsoleSettings_StereoCursorToggle = New-Object System.Windows.Forms.Label           #r_StereoDebugDrawing
$labelExpCategory_ConsoleSettings_StereoCursorToggle.Text = "Display Stereo Console"
$labelExpCategory_ConsoleSettings_StereoCursorToggle.Top = (215 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorToggle.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorToggle.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorToggle.Width = (149 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_ConsoleSettings_StereoCursorToggle)

$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.Name = "r_StereoDebugDrawing"
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.Top = (215 * $script:ScaleMultiplier)
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.Left = (450 * $script:ScaleMultiplier)
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.Width = (80 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.Items.AddRange(@(0, 1))
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.items.Add("Disabled")
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.items.Add("Enabled")
$ComboboxExpCategory_ConsoleSettings_StereoCursorToggle.SelectedIndex = 0
$tabVRSettings_Experimental.Controls.Add($ComboboxExpCategory_ConsoleSettings_StereoCursorToggle)

# -- Console --
#r_StereoCursorScale
$labelExpCategory_ConsoleSettings_StereoCursorScale = New-Object System.Windows.Forms.Label           #r_StereoCursorScale  <Attr name="HmdCursorSize" cvar="g_headtracking_hmd_cursorSize" value="1.0" />
$labelExpCategory_ConsoleSettings_StereoCursorScale.Text = "Stereo Cursor Scale"
$labelExpCategory_ConsoleSettings_StereoCursorScale.Top = (240 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorScale.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorScale.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_ConsoleSettings_StereoCursorScale.Width = (140 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_ConsoleSettings_StereoCursorScale)

$textboxExpCategory_ConsoleSettings_StereoCursorScale = New-Object System.Windows.Forms.TextBox         #   HmdCursorSize
$textboxExpCategory_ConsoleSettings_StereoCursorScale.Name = "HmdCursorSize"
$textboxExpCategory_ConsoleSettings_StereoCursorScale.Top = (240 * $script:ScaleMultiplier)
$textboxExpCategory_ConsoleSettings_StereoCursorScale.Left = (450 * $script:ScaleMultiplier)
$textboxExpCategory_ConsoleSettings_StereoCursorScale.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_ConsoleSettings_StereoCursorScale.TextAlign = 'Left'
$textboxExpCategory_ConsoleSettings_StereoCursorScale.AcceptsTab = $true
$textboxExpCategory_ConsoleSettings_StereoCursorScale.TabIndex = 6                                            # remember to fix/set tab indexes for this new stuff.
$tabVRSettings_Experimental.Controls.Add($textboxExpCategory_ConsoleSettings_StereoCursorScale)

#;g_headtracking_hmd_fpsMovementMode            ; HmdActorControlMode (default: value="1")  
$labelExpCategory_EscMenuSettings_HmdActorControlMode = New-Object System.Windows.Forms.Label           #HmdActorControlMode
$labelExpCategory_EscMenuSettings_HmdActorControlMode.Text = "FPS Control Mode"
$labelExpCategory_EscMenuSettings_HmdActorControlMode.Top = (265 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_HmdActorControlMode.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_HmdActorControlMode.Width = (130 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_EscMenuSettings_HmdActorControlMode)

$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Name = "HmdActorControlMode"
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Top = (265 * $script:ScaleMultiplier)
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Left = (430 * $script:ScaleMultiplier)
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Width = (100 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Items.AddRange(@(0, 1))
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.items.Add("Direct Offset")
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.items.Add("Grounded Look")
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.SelectedIndex = 0
$tabVRSettings_Experimental.Controls.Add($ComboboxExpCategory_EscMenuSettings_HmdActorControlMode)


#;g_headtracking_hmd_fpsAdsDominantEye            ; HmdFpsAdsDominantEye (default: value="1")
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye = New-Object System.Windows.Forms.Label           #HmdFpsAdsDominantEye
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Text = "Dominant Eye"
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Top = (295 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Left = (300 * $script:ScaleMultiplier)
$labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Width = (150 * $script:ScaleMultiplier)
$tabVRSettings_Experimental.Controls.Add($labelExpCategory_EscMenuSettings_HmdfpsAdsDominantEye)

$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye = New-Object System.Windows.Forms.ComboBox
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Name = "HmdFpsAdsDominantEye"
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Top = (295 * $script:ScaleMultiplier)
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Left = (450 * $script:ScaleMultiplier)
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Width = (80 * $script:ScaleMultiplier)  # Adjusted width to fit the combo box
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Items.AddRange(@(0, 1))
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.items.Add("Left")
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.items.Add("Right")
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.SelectedIndex = 1
$tabVRSettings_Experimental.Controls.Add($ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye)


# Experimental VR Settings -------------------------------------------------------------------------------------------------
# END-----------------------------------------------------------------------------------------------------------------------


# Function to enable Apply/Save buttons when any field changes
function Enable-SaveButtons {
    $applySaveButton.Enabled = $true
    $saveAndCloseButton.Enabled = $true
}

# Attach event handlers to all relevant controls
$fovTextBox.Add_TextChanged({ Enable-SaveButtons })
$widthTextBox.Add_TextChanged({ Enable-SaveButtons })
$heightTextBox.Add_TextChanged({ Enable-SaveButtons })
$chromaticAberrationTextBox.Add_TextChanged({ Enable-SaveButtons })
$ShakeScaleTextBox.Add_TextChanged({ Enable-SaveButtons })
$CameraSpringMovementTextBox.Add_TextChanged({ Enable-SaveButtons })
$GForceBoostZoomScaleTextBox.Add_TextChanged({ Enable-SaveButtons })
$GForceHeadBobScaleTextBox.Add_TextChanged({ Enable-SaveButtons })

$headtrackerEnabledComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$HeadtrackingSourceComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$AutoZoomComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$MotionBlurComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$FilmGrainComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$HeadtrackingEnableRollFPSComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$HeadtrackingDisableDuringWalkingComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })
$HeadtrackingThirdPersonCameraToggleComboBox.Add_SelectedIndexChanged({ Enable-SaveButtons })

# new Experimental VR Settings
$textboxExpCategory_EscMenuSettings_EscMenuDistance.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_EscMenuSettings_EscMenuYPos.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_EscMenuSettings_EscMenuScale.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_HelmetVisorLensDepth.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_HelmetVisorLens_AspectModifier.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_TheatreMode_Scale.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_TheatreMode_Curvature.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_TheatreMode_Distance.Add_TextChanged({ Enable-SaveButtons })
#$textboxExpCategory_UserSettings_StereoScaleformDepth.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_UserSettings_StereoStrength.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_ConsoleSettings_StereoCursorScale.Add_TextChanged({ Enable-SaveButtons })

$ComboboxExpCategory_MirrorMode_StereoMirrorMode.Add_SelectedIndexChanged({ Enable-SaveButtons })
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.Add_SelectedIndexChanged({ Enable-SaveButtons })
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.Add_SelectedIndexChanged({ Enable-SaveButtons })
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.Add_SelectedIndexChanged({ Enable-SaveButtons })

$fovTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$widthTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$heightTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$headtrackerEnabledComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$HeadtrackingSourceComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$chromaticAberrationTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
#$AutoZoomTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$AutoZoomComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
#$MotionBlurTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$MotionBlurComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$ShakeScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$CameraSpringMovementTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
#$FilmGrainTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$FilmGrainComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$GForceBoostZoomScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$GForceHeadBobScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$HeadtrackingEnableRollFPSComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$HeadtrackingDisableDuringWalkingComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$HeadtrackingThirdPersonCameraToggleComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$applySaveButton.add_MouseHover({ $ShowHelp.Invoke($_) })
#$buttonOpenExpVRSettings.add_MouseHover({ $ShowHelp.Invoke($_) })
$loadFromProfileButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$importButton.add_MouseHover({ $ShowHelp.Invoke($_) })

$textboxExpCategory_EscMenuSettings_EscMenuDistance.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_EscMenuSettings_EscMenuYPos.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_EscMenuSettings_EscMenuScale.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_HelmetVisorLensDepth.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_HelmetVisorLens_AspectModifier.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_HelmetVisorLens_HmdVisorHeight.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_HelmetVisorLens_HmdVisorScale.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_TheatreMode_Scale.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_TheatreMode_Curvature.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_TheatreMode_Distance.add_MouseHover({ $ShowHelp.Invoke($_) })
#$textboxExpCategory_UserSettings_StereoScaleformDepth.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_UserSettings_StereoStrength.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_ConsoleSettings_StereoCursorScale.add_MouseHover({ $ShowHelp.Invoke($_) })

$ComboboxExpCategory_MirrorMode_StereoMirrorMode.add_MouseHover({ $ShowHelp.Invoke($_) })
$ComboboxExpCategory_HMDSettings_StereoDynamicModeSwitch.add_MouseHover({ $ShowHelp.Invoke($_) })
$ComboboxExpCategory_EscMenuSettings_HmdActorControlMode.add_MouseHover({ $ShowHelp.Invoke($_) })
$ComboboxExpCategory_EscMenuSettings_HmdfpsAdsDominantEye.add_MouseHover({ $ShowHelp.Invoke($_) })


$toolTips = New-Object System.Windows.Forms.ToolTip
$ShowHelp={
    if ($null -eq $this) {
        Write-Host "Error: Control is null in MouseHover event." -ForegroundColor Red
        return
    }else {
        if ($debug){Write-Host "MouseOver Control Name: $($this.Name)" -ForegroundColor Green}
    }
    #display popup help
    #each value is the name of a control on the form.
    #param ($sender)
     Switch ($this.Name) {
        "fovTextBox"  {$tip = "Vertical Field of View"}
        "widthTextBox" {$tip = "Width of the screen in pixels"}
        "heightTextBox" {$tip = "Height of the screen in pixels"}
        "headtrackerEnabledComboBox" {$tip = "Enable or disable head tracking"}
        "HeadtrackingSourceComboBox" {$tip = "Select the head tracking source"}
        "chromaticAberrationTextBox" {$tip = "Chromatic Aberration value 0.00/1.00. Recommended value 0.00"}
        #"AutoZoomTextBox" {$tip = "Auto Zoom on selected target 0/1"}
        "AutoZoomComboBox" {$tip = "Auto Zoom on selected target. Recommended Disabled"}
        "MotionBlurTextBox" {$tip = "Motion Blur. Recommended Disabled"}
        "ShakeScaleTextBox" {$tip = "Shake Scale value. Recommended value 0"}
        "CameraSpringMovementTextBox" {$tip = "Camera Spring Movement value. Recommended value 0"}
        "FilmGrainTextBox" {$tip = "Film Grain. Recommended Disabled"}
        "GForceBoostZoomScaleTextBox" {$tip = "G-Force Boost Zoom Scale value. valid value 0.0 to 1.0. Recommended value 0."}
        "GForceHeadBobScaleTextBox" {$tip = "G-Force Head Bob Scale value. valid value 0.0 to 1.0. Recommended value 0."}
        "HeadtrackingEnableRollFPSComboBox" {$tip = "Sets whether head-tilt to left/right is enabled in FPS mode.May also apply in vehicles"}
        "HeadtrackingDisableDuringWalkingComboBox" {$tip = "Disable Headtracking during walking On/Off"}
        "HeadtrackingThirdPersonCameraToggleComboBox" {$tip = "Enable Headtracking in Third Person On/Off"}
        "saveButton" {$tip = "Save this configuration to the game"}
        "saveProfileButton" {$tip = "Save these settings to a config file for later use"}
        "loadFromProfileButton" {$tip = "Load settings from the VRSE-AE profile"}
        "importButton" {$tip = "Import settings from the game"}
        #"deleteEACTempFilesButton" {$tip = "Delete EAC TempFiles"}
        #"hostsFileAddButton" {$tip = "Update hosts file for EAC Bypass"}

        "HmdUIDistance" {$tip = "How Far away the Escape Menu is."}
        "HmdUIHeight" {$tip = "Vertical Offset of Menu."}
        "HmdUIScale" {$tip = "How large the Escape Menu is in 3d space."}
        "HmdVisorDistance" {$tip = "Helmet overlay focus distance."}
        "HmdVisorAspectModifier" {$tip = "Helmet overlay width."}
        "HmdVisorHeight" {$tip = "Helmet overlay focus distance."}
        "HmdVisorScale" {$tip = "Vertical Offset of Helmet overlay."}
        "HmdTheaterModeScale" {$tip = "How large is the Theater Mode Window."}
        "HmdTheaterModeCurvature" {$tip = "[META QUEST Only] How much curve the Theater Mode Window has."}
        "HmdTheaterModeDistance" {$tip = "Focus depth of the Theater Window."}
        "HmdIPDScale" {$tip = "Interpupillary Distance Modifier."}
        "HmdCursorSize" {$tip = "VR Mouse Cursor Size."}
        "HmdTheaterMode" {$tip = "Toggle Theater Mode on Startup."}
        "HmdAutomaticSwitching" {$tip = "If your HMD Supports headset removal detection."}
        "HmdActorControlMode" {$tip = "VR FPS Actor Player Comfort setting."}
        "HmdfpsAdsDominantEye" {$tip = "Mostly for Aim Down Sights (ADS)"}

        Default { $tip = "No tooltip available for this control." }
      }
     $toolTips.SetToolTip($this, $tip)
}

# Create a status bar
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "Ready"
$statusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
$statusBar.Height = (20 * $script:ScaleMultiplier)
$statusBar.Font = New-Object System.Drawing.Font($statusBar.Font.FontFamily, [math]::Round($statusBar.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$statusBar.Name = "StatusBar"
$form.Controls.Add($statusBar)


if (($null -ne $AutoDetectSCPath) -and (Test-Path -Path $AutoDetectSCPath)) {
    $script:liveFolderPath = Join-Path -Path $AutoDetectSCPath -ChildPath $branch
    $script:xmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "user\client\0\Profiles\default\attributes.xml"
    Set-ProfileArray
    #$script:profileArray.Add([PSCustomObject]@{ AttributesXmlPath = $script:xmlPath }) | Out-Null
    if ($debug) {Write-Host "debug:xmlPath $script:xmlPath" -BackgroundColor White -ForegroundColor Black}
    if (Test-Path -Path $AutoDetectSCPath) {
        $importButton.Enabled = $true
        $statusBar.Text = "Star Citizen found at: $script:liveFolderPath"
        Import-SettingsFromGame
    } else {
        $statusBar.Text = "attributes.xml file not found in the 'default' profile folder."
        #[System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")
    }
} else {
    $statusBar.Text = "Star Citizen not found."
    [System.Windows.Forms.MessageBox]::Show("Star Citizen not found. Please Open the Game Library folder through the Menu")
}

$keybindSearchField = New-Object System.Windows.Forms.TextBox
$keybindSearchField.Name = "KeybindSearchField"
$keybindSearchField.Top = (8 * $script:ScaleMultiplier)
$keybindSearchField.Left = (305 * $script:ScaleMultiplier)
#$keybindSearchField.Right = $keybindSearchField.Width
$keybindSearchField.Font = New-Object System.Drawing.Font($keybindSearchField.Font.FontFamily, [math]::Round($keybindSearchField.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$keybindSearchField.ForeColor = [System.Drawing.Color]::Gray
$keybindSearchField.BackColor = [System.Drawing.Color]::White
$keybindSearchField.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$keybindSearchField.Multiline = $false
$keybindSearchField.ScrollBars = [System.Windows.Forms.ScrollBars]::None
$keybindSearchField.TextAlign = 'Left'
$keybindSearchField.TabIndex = 26
$keybindSearchField.Text = "Search Keybinds"
$keybindSearchField.Width = (160 * $script:ScaleMultiplier)
$keybindSearchField.Size = New-Object Drawing.Size((160 * $script:ScaleMultiplier), (30 * $script:ScaleMultiplier))
#$keybindSearchField.Anchor = "Top, Right"
$keybindSearchField.Add_Enter({
    $keybindSearchField.Text = ""
    $keybindSearchField.ForeColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
})
$keybindSearchField.Add_Leave({
    if ([string]::IsNullOrWhiteSpace($keybindSearchField.Text)) {
        $keybindSearchField.Text = "Search Keybinds"
        $keybindSearchField.ForeColor = [System.Drawing.Color]::Gray
    }
})
$tabVRSettings_Keybinds.Controls.Add($keybindSearchField)

# Add a dropdown (ComboBox) under the keybindSearchField for device selection
$keybindDeviceComboBox = New-Object System.Windows.Forms.ComboBox
$keybindDeviceComboBox.Name = "KeybindDeviceComboBox"
$keybindDeviceComboBox.Top = (9 * $script:ScaleMultiplier) #($keybindSearchField.Top + $keybindSearchField.Height + 10)
#$keybindDeviceComboBox.Anchor = "Top, Left"
$keybindDeviceComboBox.Left = (240 * $script:ScaleMultiplier)
#$keybindDeviceComboBox.Size = (60 * $script:ScaleMultiplier)
$keybindDeviceComboBox.Width = (60 * $script:ScaleMultiplier)
$keybindDeviceComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$keybindDeviceComboBox.Items.AddRange(@("kb1", "mouse", "gamepad", "js1", "js2", "js3", "js4"))
$keybindDeviceComboBox.SelectedIndex = 0
$tabVRSettings_Keybinds.Controls.Add($keybindDeviceComboBox)

# Handler function for device dropdown selection
function On-KeybindDeviceComboBox-Changed {
    param($sender, $eventArgs)
    $selectedDevice = $keybindDeviceComboBox.SelectedItem
    # Filter ActionMaps tree to only show actions with rebind/input starting with the selected device prefix
    $treeKeybinds_ActionMaps.BeginUpdate()
    $treeKeybinds_ActionMaps.Nodes.Clear()
    $profileNode = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
        $amNode = $profileNode.Nodes.Add("ActionMap: $($actionmap.name)")
        foreach ($action in $actionmap.action) {
            # Check if any rebind/input starts with the selected device prefix
            $matchingRebinds = @($action.rebind | Where-Object { $_.input -like "$selectedDevice*" })
            if ($matchingRebinds.Count -gt 0) {
                $aNode = $amNode.Nodes.Add("Action: $($action.name)")
                foreach ($rebind in $matchingRebinds) {
                    $aNode.Nodes.Add("Rebound: $($rebind.input)") | Out-Null
                }
            }
        }
    }
    $treeKeybinds_ActionMaps.EndUpdate()
    # Example: Write-Host "Selected device: $selectedDevice"
}

# Wire up the event
$keybindDeviceComboBox.Add_SelectedIndexChanged({ On-KeybindDeviceComboBox-Changed $this $args })

# Helper: Add column
function Add-Column($listView, $columns) {
    $listView.Columns.Clear()
    foreach ($col in $columns) {
        $listView.Columns.Add($col,$keybind_column_width)
    }
}

# Create TabControl
$tabControl_Keybinds = New-Object System.Windows.Forms.TabControl
#$tabControl_Keybinds.Location = '10,60'
$tabControl_Keybinds.Top = (10 * $script:ScaleMultiplier)
$tabControl_Keybinds.Left = (0 * $script:ScaleMultiplier)
$tabControl_Keybinds.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$tabControl_Keybinds.Size = New-Object Drawing.Size((620 * $script:ScaleMultiplier),(470 * $script:ScaleMultiplier))
$tabControl_Keybinds.Anchor = "Top, Left, Right, Bottom"
$tabControl_Keybinds.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)



# --- Tab 1: ActionMaps ---
$tabKeybinds_ActionMaps = New-Object System.Windows.Forms.TabPage
$tabKeybinds_ActionMaps.Text = "KeyBinds"
$tabKeybinds_ActionMaps.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$tabKeybinds_ActionMaps.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)

$treeKeybinds_ActionMaps = New-Object Windows.Forms.TreeView
#$treeKeybinds_ActionMaps.Location = (10 * $script:ScaleMultiplier),(10 * $script:ScaleMultiplier)
#$treeKeybinds_ActionMaps.Location = "10,10"
$treeKeybinds_ActionMaps.Top = (10 * $script:ScaleMultiplier)
$treeKeybinds_ActionMaps.Left = (10 * $script:ScaleMultiplier)
#$treeKeybinds_ActionMaps.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$treeKeybinds_ActionMaps.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$treeKeybinds_ActionMaps.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$treeKeybinds_ActionMaps.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$treeKeybinds_ActionMaps.Size = New-Object Drawing.Size((350 * $script:ScaleMultiplier),(300 * $script:ScaleMultiplier))
$treeKeybinds_ActionMaps.HideSelection = $false

$listKeybinds_ActionMaps = New-Object Windows.Forms.ListView
#$listKeybinds_ActionMaps.Location = "370,10"
$listKeybinds_ActionMaps.Top = (10 * $script:ScaleMultiplier)
$listKeybinds_ActionMaps.Left = (370 * $script:ScaleMultiplier)

$listKeybinds_ActionMaps.Size = New-Object Drawing.Size((220 * $script:ScaleMultiplier),(200 * $script:ScaleMultiplier))
$listKeybinds_ActionMaps.View = 'Details'
$listKeybinds_ActionMaps.FullRowSelect = $true
$listKeybinds_ActionMaps.GridLines = $false
$listKeybinds_ActionMaps.BorderStyle = [System.Windows.Forms.BorderStyle]::None
#$listKeybinds_ActionMaps.ColumnWidths = 90


$listKeybinds_Defaults = New-Object Windows.Forms.ListView
#$listKeybinds_Defaults.Location = "370,220"
$listKeybinds_Defaults.Top = (220 * $script:ScaleMultiplier)
$listKeybinds_Defaults.Left = (370 * $script:ScaleMultiplier)
#$listKeybinds_Defaults.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$listKeybinds_Defaults.Size = New-Object Drawing.Size((220 * $script:ScaleMultiplier),(180 * $script:ScaleMultiplier))
$listKeybinds_Defaults.View = 'Details'
$listKeybinds_Defaults.FullRowSelect = $true
$listKeybinds_Defaults.GridLines = $true
$listKeybinds_Defaults.Visible = $false

# --- Tab 2: Device ---
$tabKeybinds_Device = New-Object System.Windows.Forms.TabPage
$tabKeybinds_Device.Text = "Device"

$treeKeybinds_Device = New-Object Windows.Forms.TreeView
#$treeKeybinds_Device.Location = "10,10"
$treeKeybinds_Device.Top = (10 * $script:ScaleMultiplier)
$treeKeybinds_Device.Left = (10 * $script:ScaleMultiplier)
$treeKeybinds_Device.Size = New-Object Drawing.Size((350 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$treeKeybinds_Device.HideSelection = $false

$listKeybinds_Device = New-Object Windows.Forms.ListView
#$listKeybinds_Device.Location = "370,10"
$listKeybinds_Device.Top = (10 * $script:ScaleMultiplier)
$listKeybinds_Device.Left = (370 * $script:ScaleMultiplier)
$listKeybinds_Device.Size = New-Object Drawing.Size((220 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$listKeybinds_Device.View = 'Details'
$listKeybinds_Device.FullRowSelect = $true
$listKeybinds_Device.GridLines = $true

# --- Tab 3: Options ---
$tabKeybinds_Options = New-Object System.Windows.Forms.TabPage
$tabKeybinds_Options.Text = "Options"

$treeKeybinds_Options = New-Object Windows.Forms.TreeView
#$treeKeybinds_Options.Location = "10,10"
$treeKeybinds_Options.Top = (10 * $script:ScaleMultiplier)
$treeKeybinds_Options.Left = (10 * $script:ScaleMultiplier)
$treeKeybinds_Options.Size = New-Object Drawing.Size((350 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$treeKeybinds_Options.HideSelection = $false

$listKeybinds_Options = New-Object Windows.Forms.ListView
#$listKeybinds_Options.Location = "370,10"
$listKeybinds_Options.Top = (10 * $script:ScaleMultiplier)
$listKeybinds_Options.Left = (370 * $script:ScaleMultiplier)
$listKeybinds_Options.Size = New-Object Drawing.Size((220 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$listKeybinds_Options.View = 'Details'
$listKeybinds_Options.FullRowSelect = $true
$listKeybinds_Options.GridLines = $true
$listKeybinds_Options.Scrollbars =  = [System.Windows.Forms.ScrollBars]::Both

# Add tabs to TabControl
$tabControl_Keybinds.TabPages.Add($tabKeybinds_ActionMaps)
$tabControl_Keybinds.TabPages.Add($tabKeybinds_Device)
$tabControl_Keybinds.TabPages.Add($tabKeybinds_Options)
$tabVRSettings_Keybinds.Controls.Add($tabControl_Keybinds)

# Load default action maps XML
$ActionMapDefaults = $null
if (![string]::IsNullOrEmpty($PSScriptRoot)) {
    $ActionMapDefaults = Join-Path $PSScriptRoot"/builds" -ChildPath $scbuild"/actionmaps.xml"
} else {
    $ActionMapDefaults = "./builds/4.6/actionmaps.xml"
}

# Populate and wire up controls only after XML is loaded

function Populate-KeyBindsViewer {
    # Clear all nodes and items
    $treeKeybinds_ActionMaps.Nodes.Clear()
    $listKeybinds_ActionMaps.Items.Clear()
    $treeKeybinds_Device.Nodes.Clear()
    $listKeybinds_Device.Items.Clear()
    $treeKeybinds_Options.Nodes.Clear()
    $listKeybinds_Options.Items.Clear()

    if (-not $script:keyBindsProfiles) { return }
    $defaultsXml = [xml](Get-Content $ActionMapDefaults) #$defaultActionMapsXml)
    # --- ActionMaps ---
    $actionProfileNode = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
        $amNode = $actionProfileNode.Nodes.Add("ActionMap: $($actionmap.name)")
        foreach ($action in $actionmap.action) {
            $aNode = $amNode.Nodes.Add("Action: $($action.name)")
            foreach ($rebind in $action.rebind) {
                $aNode.Nodes.Add("Rebound: $($rebind.input)") | Out-Null
            }
        }
        foreach ($action in $defaultsXml.actionmap) {
            if ($actionmap.name -eq $actionmap.name) {
                $aNode = $amNode.Nodes.Add("Default Action: $($action.name)")
                foreach ($default in $action.default) {
                    $aNode.Nodes.Add("Default: $($default.input)") | Out-Null
                }
            }
        }
    }
    $treeKeybinds_ActionMaps.Add_AfterSelect({
        $listKeybinds_ActionMaps.Items.Clear()
        $node = $treeKeybinds_ActionMaps.SelectedNode
        if ($null -eq $node) { return }
        if ($node.Text -like "Action: *") {
            $actionName = $node.Text.Substring(8)
            $action = $script:keyBindsProfiles.actionmap.action | Where-Object { $_.name -eq $actionName }
            if ($action) {
                Add-Column $listKeybinds_ActionMaps @("Rebound Input", "MultiTap")
                #defaults 
                foreach ($default in $action.default) {
                    if ($default.input) {
                        $item = $listKeybinds_ActionMaps.Items.Add($default.input)
                        if ($null -ne $item) {
                            $multiTapValue = if ($default.multiTap) { $default.multiTap } else { "" }
                            $item.SubItems.Add($multiTapValue)| Out-Null
                        }
                    }
                }
                foreach ($rebind in $action.rebind) {
                    if ($rebind.input) {
                        $item = $listKeybinds_ActionMaps.Items.Add($rebind.input)
                        if ($null -ne $item) {
                            $multiTapValue = if ($rebind.multiTap) { $rebind.multiTap } else { "" }
                            $item.SubItems.Add($multiTapValue)| Out-Null
                        }
                    }
                }
            }
        }

        # Populate $listKeybinds_Defaults with the relevant actionmap from defaultactionmaps.xml
        if ($node.Text -like "Action: *") {
            $actionName = $node.Text.Substring(8)
            # Load defaultactionmaps.xml if not already loaded
            if (-not $script:defaultActionMapsXml) {
                #$defaultActionMapsPath = Join-Path $PSScriptRoot "defaultactionmaps.xml"
                $defaultActionMapsPath = Join-Path $PSScriptRoot $ActionMapDefaults

                if (Test-Path $defaultActionMapsPath) {
                    $script:defaultActionMapsXml = [xml](Get-Content $defaultActionMapsPath)
                    if ($debug) {Write-Host "debug:defaultActionMapsPath: $defaultActionMapsPath" -BackgroundColor White -ForegroundColor Black}
                }
            }
            if ($script:defaultActionMapsXml) {
                $listKeybinds_Defaults.Items.Clear()
                $listKeybinds_Defaults.Columns.Clear()
                #$listKeybinds_Defaults.Columns.Add("Rebind Input",120)
                #$listKeybinds_Defaults.Columns.Add("MultiTap",120)
                Add-Column $listKeybinds_Defaults @("Default Input", "MultiTap")
                # Find the action in defaultactionmaps.xml
                foreach ($actionmap in $script:defaultActionMapsXml.actionmap) {
                    foreach ($action in $actionmap.action) {
                        if ($action.name -eq $actionName) {
                            foreach ($rebind in $action.rebind) {
                                $item = $listKeybinds_Defaults.Items.Add($rebind.input)
                                $multiTapValue = if ($rebind.multiTap) { $rebind.multiTap } else { "" }
                                $item.SubItems.Add($multiTapValue) | Out-Null
                            }
                        }
                    }
                }
            }
        }
    })



    $tabKeybinds_ActionMaps.Controls.Clear()
    $tabKeybinds_ActionMaps.Controls.Add($treeKeybinds_ActionMaps)
    $tabKeybinds_ActionMaps.Controls.Add($listKeybinds_ActionMaps)
    $tabKeybinds_ActionMaps.Controls.Add($listKeybinds_Defaults)

    # --- Device ---
    $deviceProfileNode = $treeKeybinds_Device.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    foreach ($devopt in $script:keyBindsProfiles.deviceoptions) {
        $devNode = $deviceProfileNode.Nodes.Add("Device: $($devopt.name)")
        foreach ($opt in $devopt.option) {
            $devNode.Nodes.Add("Option: $($opt.input) = $($opt.saturation)$($opt.deadzone)")
        }
    }
    $treeKeybinds_Device.Add_AfterSelect({
        $listKeybinds_Device.Items.Clear()
        $node = $treeKeybinds_Device.SelectedNode
        if ($null -eq $node) { return }
        if ($node.Text -like "Device: *") {
            $devName = $node.Text.Substring(8)
            $dev = $script:keyBindsProfiles.deviceoptions | Where-Object { $_.name -eq $devName }
            if ($dev) {
                Add-Column $listKeybinds_Device @("Input", "Saturation", "Deadzone")
                foreach ($opt in $dev.option) {
                    if ($opt.input) {
                        $item = $listKeybinds_Device.Items.Add($opt.input)
                        if ($null -ne $item -or $item -eq 0) {
                            try {
                                $item.SubItems.Add($opt.saturation) | Out-Null
                            } catch {
                                if ($debug) {Write-Host "Error adding Saturation: $($_.Exception.Message)" -ForegroundColor Red}
                            }
                            try {
                                $item.SubItems.Add($opt.deadzone) | Out-Null
                            } catch {
                                if ($debug) {Write-Host "Error adding Deadzone: $($_.Exception.Message)" -ForegroundColor Red}
                            }
                        }
                    }
                }
            }
        }
    })
    $tabKeybinds_Device.Controls.Clear()
    $tabKeybinds_Device.Controls.Add($treeKeybinds_Device)
    $tabKeybinds_Device.Controls.Add($listKeybinds_Device)

    # --- Options ---
    $optionsProfileNode = $treeKeybinds_Options.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    foreach ($opt in $script:keyBindsProfiles.options) {
        $optNode = $optionsProfileNode.Nodes.Add("Options: $($opt.type) $($opt.Product)")
        foreach ($child in $opt.ChildNodes) {
            $optNode.Nodes.Add("$($child.Name): $($child.OuterXml)") | Out-Null
        }
    }
    $treeKeybinds_Options.Add_AfterSelect({
        $listKeybinds_Options.Items.Clear()
        $node = $treeKeybinds_Options.SelectedNode
        if ($null -eq $node) { return }
        if ($node.Text -like "Options: *") {
            $optType = $node.Text.Split(" ")[1]
            $opt = $script:keyBindsProfiles.options | Where-Object { $_.type -eq $optType }
            if ($opt) {
                Add-Column $listKeybinds_Options @("Property", "Value")
                foreach ($attr in $opt.Attributes) {
                    if ($attr.Name) {
                        $item = $listKeybinds_Options.Items.Add($attr.Name)
                        if ($null -ne $item) {
                            $item.SubItems.Add($attr.Value)| Out-Null
                        }
                    }
                }
                foreach ($child in $opt.ChildNodes) {
                    if ($child.Name) {
                        $item = $listKeybinds_Options.Items.Add($child.Name)
                        if ($null -ne $item) {
                            $item.SubItems.Add($child.OuterXml)| Out-Null
                        }
                    }
                }
            }
        }
    })
    $tabKeybinds_Options.Controls.Clear()
    $tabKeybinds_Options.Controls.Add($treeKeybinds_Options)
    $tabKeybinds_Options.Controls.Add($listKeybinds_Options)
}

# Search logic: filter all tabs' treeviews
$keybindSearchField.Add_TextChanged({
    $searchText = $keybindSearchField.Text
    foreach ($tree in @($treeKeybinds_ActionMaps, $treeKeybinds_Device, $treeKeybinds_Options)) {
        $tree.BeginUpdate()
        $tree.Nodes.Clear()
    }
    if (![string]::IsNullOrWhiteSpace($searchText) -and $searchText -ne "Search Keybinds") {
        # ActionMaps
        $node = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
            $amNode = $node.Nodes.Add("ActionMap: $($actionmap.name)")
            foreach ($action in $actionmap.action) {
                if ($action.name -like "*$searchText*") {
                    $aNode = $amNode.Nodes.Add("Action: $($action.name)")
                    foreach ($rebind in $action.rebind) {
                        $aNode.Nodes.Add("Rebind: $($rebind.input)") | Out-Null
                    }
                }
            }
        }
        # Device
        $dnode = $treeKeybinds_Device.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($devopt in $script:keyBindsProfiles.deviceoptions) {
            if ($devopt.name -like "*$searchText*") {
                $devNode = $dnode.Nodes.Add("Device: $($devopt.name)")
                foreach ($opt in $devopt.option) {
                    $devNode.Nodes.Add("Option: $($opt.input) = $($opt.saturation)$($opt.deadzone)")
                }
            }
        }
        # Options
        $onode = $treeKeybinds_Options.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($opt in $script:keyBindsProfiles.options) {
            if ($opt.type -like "*$searchText*" -or $opt.Product -like "*$searchText*") {
                $optNode = $onode.Nodes.Add("Options: $($opt.type) $($opt.Product)")
                foreach ($child in $opt.ChildNodes) {
                    $optNode.Nodes.Add("$($child.Name): $($child.OuterXml)") | Out-Null
                }
            }
        }
    } else {
        # Show all
        # ActionMaps
        $node = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
            $amNode = $node.Nodes.Add("ActionMap: $($actionmap.name)")
            foreach ($action in $actionmap.action) {
                $aNode = $amNode.Nodes.Add("Action: $($action.name)")
                foreach ($rebind in $action.rebind) {
                    $aNode.Nodes.Add("KeyBind: $($rebind.input)") | Out-Null
                }
            }
        }
        # Device
        $dnode = $treeKeybinds_Device.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($devopt in $script:keyBindsProfiles.deviceoptions) {
            $devNode = $dnode.Nodes.Add("Device: $($devopt.name)")
            foreach ($opt in $devopt.option) {
                $devNode.Nodes.Add("Option: $($opt.input) = $($opt.saturation)$($opt.deadzone)")
            }
        }
        # Options
        $onode = $treeKeybinds_Options.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
        foreach ($opt in $script:keyBindsProfiles.options) {
            $optNode = $onode.Nodes.Add("Options: $($opt.type) $($opt.Product)")
            foreach ($child in $opt.ChildNodes) {
                $optNode.Nodes.Add("$($child.Name): $($child.OuterXml)") | Out-Null
            }
        }
    }
    foreach ($tree in @($treeKeybinds_ActionMaps, $treeKeybinds_Device, $treeKeybinds_Options)) {
        $tree.EndUpdate()
    }
})

# Show KeyBinds Viewer and hide main form when menu item is clicked

function Initialise_KeyBindTab {
    $script:ActionMapsxmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "user\client\0\Profiles\default\ActionMaps.xml"
    if (-not (Test-Path $script:ActionMapsxmlPath)) {
        Write-Host "XML file not found at $script:ActionMapsxmlPath"
        exit
    }
    $script:BindsXML = [xml](Get-Content $script:ActionMapsxmlPath)
    $script:keyBindsProfiles = $script:BindsXML.ActionMaps.ActionProfiles

    Populate-KeyBindsViewer
}
Initialise_KeyBindTab

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