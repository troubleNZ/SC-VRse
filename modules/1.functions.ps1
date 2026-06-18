[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
[Reflection.Assembly]::LoadWithPartialName('System.Data')          | Out-Null
[Reflection.Assembly]::LoadWithPartialName('System.Drawing')       | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:xmlPath = $null
$script:xmlContent = @()
$script:dataTable = New-Object System.Data.DataTable
$script:xmlArray = @()

$script:liveFolderPath = $null
$script:attributesXmlPath = $null
$fovTextBox = $null
$heightTextBox = $null
$widthTextBox = $null
$headtrackerEnabledComboBox = $null
$HeadtrackingSourceComboBox = $null

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

function New-RoundedRegion {
    param(
        [int]$width,
        [int]$height,
        [int]$radius = 5
    )

    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2

    # Top-left arc
    $gp.AddArc(0, 0, $diameter, $diameter, 180, 90)
    # Top edge
    $gp.AddLine($radius, 0, $width - $radius, 0)
    # Top-right arc
    $gp.AddArc($width - $diameter, 0, $diameter, $diameter, 270, 90)
    # Right edge
    $gp.AddLine($width, $radius, $width, $height - $radius)
    # Bottom-right arc
    $gp.AddArc($width - $diameter, $height - $diameter, $diameter, $diameter, 0, 90)
    # Bottom edge
    $gp.AddLine($width - $radius, $height, $radius, $height)
    # Bottom-left arc
    $gp.AddArc(0, $height - $diameter, $diameter, $diameter, 90, 90)
    # Left edge
    $gp.AddLine(0, $height - $radius, 0, $radius)

    $gp.CloseFigure()
    return New-Object System.Drawing.Region($gp)
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
$tabControl_VRSettings.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$tabControl_VRSettings.Size = New-Object Drawing.Size((580 * $script:ScaleMultiplier),(470 * $script:ScaleMultiplier))
#$tabControl_VRSettings.Anchor = "Top, Left, Right"
$tabControl_VRSettings.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$radius = 5
$tabControl_VRSettings.Region = New-RoundedRegion -width $tabControl_VRSettings.Width -height $tabControl_VRSettings.Height -radius $radius
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

            if ($script:loadedProfile -eq $true) {
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

        $textboxExpCategory_UIResolution_Horizontal.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)
        $textboxExpCategory_UIResolution_Vertical.BackColor = [System.Drawing.Color]::FromArgb(26, 66, 116)

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
    } else {
        Set-DarkMode -control $form
        Set-DarkMode -control $formHIDLookup
        #Set-DarkMode -control $keyBindsForm
        $darkModeMenuItem.Text = "Disable Dark Mode"
        $script:profileArray.Add([PSCustomObject]@{ DarkMode = $true }) | Out-Null
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
                        $script:loadedProfile = $true
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
    if ($null -ne $AutoDetectSCPath -and (Test-Path -Path $AutoDetectSCPath)) {
        $folderBrowserDialog.SelectedPath = $AutoDetectSCPath
    }
    $statusBar.Text = "Opening SC Folder..."
    $folderBrowserDialog.Description = "Select the 'Star Citizen' folder containing 'Live'"
    if ($script:profileArray -and ($null -ne $script:profileArray.SCPath)) {
        if ($null -ne $folderBrowserDialog) {
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
            $defaultProfilePath = Join-Path -Path $script:liveFolderPath -ChildPath $commonChildPath
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
    [OutputType([System.Windows.Forms.DialogResult])]
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
                $HmdUIHeightNode.SetAttribute("value", $textboxExpCategory_EscMenuSettings_EscMenuYPos.Text)  # HmdUIHeight
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
