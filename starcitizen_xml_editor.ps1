<#▄█    █▄     ▄████████    ▄████████    ▄████████         ▄████████    ▄████████
 ███    ███   ███    ███   ███    ███   ███    ███        ███    ███   ███    ███
 ███    ███   ███    ███   ███    █▀    ███    █▀         ███    ███   ███    █▀
 ███    ███  ▄███▄▄▄▄██▀   ███         ▄███▄▄▄            ███    ███  ▄███▄▄▄
 ███    ███ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀          ▀███████████ ▀▀███▀▀▀
 ███    ███ ▀███████████          ███   ███    █▄         ███    ███   ███    █▄
 ███    ███   ███    ███    ▄█    ███   ███    ███        ███    ███   ███    ███
  ▀██████▀    ███    ███  ▄████████▀    ██████████        ███    █▀    ██████████
              ███    ███  The VRse Attribute Editor  Author: @troubleshooternz
#>

$scriptVersion = "0.2.3.1"                        # Toggle VR Button. makes some assumptions about the user's setup, but should work for most people.
$BackupFolderName = "VRSE AE Backup"
$profileContent = @()
$script:profileArray = [System.Collections.ArrayList]@()
$loadedProfile = $false

$debug = $false

$script:xmlPath = $null
$script:xmlContent = @()
$script:dataTable = New-Object System.Data.DataTable
$script:xmlArray = @()
$script:dataGridView = @()



$script:liveFolderPath = $null
$script:attributesXmlPath = $null
$fovTextBox = $null
$heightTextBox = $null
$widthTextBox = $null
$headtrackerEnabledComboBox = $null
$HeadtrackingSourceComboBox = $null
$dataTableGroupBox = $null
$editGroupBox = $null
$darkModeMenuItem = $null

# Set default font for all controls on the form
#$defaultFont = New-Object System.Drawing.Font("segoia", 12) #segoia UI, 12pt, style=Regular
#$defaultFontBold = New-Object System.Drawing.Font("segoia", 12, [System.Drawing.FontStyle]::Bold) #segoia UI, 12pt, style=Bold


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
# [void] [DPIAware]::SetProcessDPIAware()                    # this seems to scale everything badly, so commented out for now until i get more time to test it

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
}#>
$scriptIcon = $null

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

$form = New-Object System.Windows.Forms.Form

$form.Text = "VRse-AE (Attribute Editor "+$scriptVersion+")"
$form.Width = 620
$form.Height = 655
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(600,655)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Add_Shown({
    $form.Activate()
    $form.TopMost = $true
    $form.TopMost = $false
})
$form.Icon = $scriptIcon

# Update the taskbar icon to match the form icon
if ($scriptIcon -ne $null) {
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = $scriptIcon
    $notifyIcon.Visible = $true
    $form.Add_FormClosed({
        $notifyIcon.Dispose()
    })
}

$ActionsGroupBox = New-Object System.Windows.Forms.GroupBox
$ActionsGroupBox.Text = "Actions"
$ActionsGroupBox.Width = 550
$ActionsGroupBox.Height = 100
$ActionsGroupBox.Top = 20
$ActionsGroupBox.Left = 20

# add a menu toolbar with one option called "File"
$mainMenu = New-Object System.Windows.Forms.MainMenu

$fileMenuItem = New-Object System.Windows.Forms.MenuItem
$fileMenuItem.Text = "&File"    # The & character indicates the shortcut key
$mainMenu.MenuItems.Add($fileMenuItem)  # Add the File menu item to the main menu

function Update-ButtonState {                           # used to grey out buttons when no XML file is loaded
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Button State Update", "Update the state of import and save buttons")) {
        if ($null -ne $script:xmlContent) {
            $importButton.Enabled = $true
            $saveButton.Enabled = $true
            $saveProfileButton.Enabled = $true
            if ($loadedProfile -eq $true) {
                $loadFromProfileButton.Enabled = $true
            } else {
                $loadFromProfileButton.Enabled = $false
            }
        } else {
            $importButton.Enabled = $false
            $saveButton.Enabled = $false
            $loadFromProfileButton.Enabled = $false
            $saveProfileButton.Enabled = $false
        }
    }
}

function Set-DarkMode {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Windows.Forms.Control]$control
    )
    if ($PSCmdlet.ShouldProcess("Control", "Set dark mode")) {
        $control.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $control.ForeColor = [System.Drawing.Color]::White
        foreach ($child in $control.Controls) {
            Set-DarkMode -control $child
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
    if ($form.BackColor -eq [System.Drawing.Color]::FromArgb(45, 45, 48)) {
        Set-LightMode -control $form
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

            $script:dataGridView = New-Object System.Windows.Forms.DataGridView
            $script:dataGridView.Width = 550
            $script:dataGridView.Height = 200
            $script:dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
            $script:dataGridView.Visible = $false       # grid hidden now. maybe put on another panel later

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
                $script:dataGridView.DataSource = $script:dataTable

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

                if ($debug) {Write-Host "debug: try to Populate the input boxes with the profile array values" -BackgroundColor White -ForegroundColor Black}
                Set-ProfileArray

                # Show the edit group box
                $editGroupBox.Visible = $true

            } else {
                [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file?")
            }
        } catch {
            #if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")}
            if ($debug) { Write-Host "An error occurred while loading the XML file: $_"}
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

<#       We'll use the screen dimensions below for suggesting a max window size                   #>
function Get-MaxScreenResolution {
    Add-Type -AssemblyName System.Windows.Forms
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    return "$screenWidth x $screenHeight"
}
if ($debug) {Get-MaxScreenResolution}
function Get-DesktopResolutionScale {
    Add-Type -AssemblyName System.Windows.Forms
    $graphics = [System.Drawing.Graphics]::FromHwnd([System.IntPtr]::Zero)
    $desktopDpiX = $graphics.DpiX
    $scaleFactor = $desktopDpiX / 96  # 96 DPI is the default scale (100%)
    switch ($scaleFactor) {
        1 { return "100%" }
        1.25 { return "125%" }
        1.5 { return "150%" }
        1.75 { return "175%" }
        2 { return "200%" }
        default { return "$([math]::Round($scaleFactor * 100))%" }
    }
}
if ($debug) {Get-DesktopResolutionScale}


#converted from csharp to powershell
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

$AutoDetectSCPath = Get-GameRootDirFromRegistry

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

$helpMenuItem = New-Object System.Windows.Forms.MenuItem
$helpMenuItem.Text = "&Help"
$mainMenu.MenuItems.Add($helpMenuItem)

$loadsettingsfromGameMenuItem = New-Object System.Windows.Forms.MenuItem
$loadsettingsfromGameMenuItem.Text = "&Load Settings from Game"
$loadsettingsfromGameMenuItem.Add_Click({
    Import-SettingsFromGame
})
$actionsMenuItem.MenuItems.Add($loadsettingsfromGameMenuItem)  # Add the Load Settings from Game menu item to the Actions menu

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

                $script:dataGridView = New-Object System.Windows.Forms.DataGridView
                $script:dataGridView.Width = 550
                $script:dataGridView.Height = 200
                $script:dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

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
                    $script:dataGridView.DataSource = $script:dataTable

                    $gridGroup.Controls.Add($script:dataGridView)

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

                        if ($debug) {Write-Host "debug: try to Populate the input boxes with the xml data" -BackgroundColor White -ForegroundColor Black}


                        Set-ProfileArray

                    }

                    # Show the edit group box
                    $editGroupBox.Visible = $true

                    # Update button state
                    Update-ButtonState
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                }
            } catch {
                #[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
                $statusBar.Text = "An error occurred while loading the XML file"
            }
        } else {
            $statusBar.Text = "XML file not found."
            [System.Windows.Forms.MessageBox]::Show("XML file not found.")
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
        $url = "https://raw.githubusercontent.com/troubleNZ/SC-VRse/main/starcitizen_xml_editor.ps1"
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
$actionsMenuItem.MenuItems.Add($CheckForUpdatesMenuItem)  # Add the GitHub menu item to the main menu

$GithubMenuItem = New-Object System.Windows.Forms.MenuItem
$GithubMenuItem.Text = "Open &GitHub in your Browser"
$GithubMenuItem.Add_Click({
    Start-Process "https://github.com/troubleNZ/SC-VRse"
})
$actionsMenuItem.MenuItems.Add($GithubMenuItem)  # Add the GitHub menu item to the main menu


$creditsMenuItem = New-Object System.Windows.Forms.MenuItem
$creditsMenuItem.Text = "&Credits"
$creditsMenuItem.Add_Click({
    $creditsForm = New-Object System.Windows.Forms.Form
    $creditsForm.Text = "Credits"
    $creditsForm.Width = 400
    $creditsForm.Height = 300
    $creditsForm.StartPosition = 'CenterScreen'
    $creditsForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $creditsForm.MaximizeBox = $false
    $creditsForm.MinimizeBox = $false

    $creditsPanel = New-Object System.Windows.Forms.Panel
    $creditsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $creditsPanel.AutoScroll = $false
    $creditsForm.Controls.Add($creditsPanel)

    $creditsLabel = New-Object System.Windows.Forms.Label
    $creditsLabel.Text = "VRCitizen FOV Editor (AKA SC-Patcher) Credits:" +
        "`n`n" +
        "Very Special thanks to RifleJock for getting all the VR Headset data in one place and for the suggestions and for being an idea soundboard. Special thanks to SilvanVR at CIG and Chachi Sanchez for getting VRCitizen going. Find them both on YouTube and Twitch. See you in the 'VRse  o7 " +
        "`n`n" +
        "This tool is not affiliated with CIG or Star Citizen. Use at your own risk." +
        "`n`n" +
        "This tool is open source and available on GitHub:" +
        "`n" +
        "https://github.com/star-citizen-vr/scvr-patcher"

    $creditsLabel.AutoSize = $false
    $creditsLabel.Top = 10
    $creditsLabel.Left = 10
    $creditsLabel.Width = 380
    $creditsLabel.Height = 250
    $creditsLabel.TextAlign = 'MiddleCenter'
    $creditsLabel.BackColor = [System.Drawing.Color]::Transparent
    $creditsLabel.Font = New-Object System.Drawing.Font("Arial", 10)
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

# Create the Find Live Folder button
<#$findLiveFolderButton = New-Object System.Windows.Forms.Button
$findLiveFolderButton.Name = "FindLiveFolderButton"
$findLiveFolderButton.Text = "Open SC Folder"
$findLiveFolderButton.Width = 120
$findLiveFolderButton.Height = 30
$findLiveFolderButton.Top = 30
$findLiveFolderButton.Left = 20
$findLiveFolderButton.TabIndex = 0
$findLiveFolderButton.Add_Click({
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
        $script:liveFolderPath = Join-Path -Path $selectedPath -ChildPath "Live"
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
                        $backupDir = Join-Path -Path $PSScriptRoot -ChildPath $BackupFolderName
                        if (-not (Test-Path -Path $backupDir)) {
                            New-Item -ItemType Directory -Path $backupDir | Out-Null
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
})
$ActionsGroupBox.Controls.Add($findLiveFolderButton)
#>

$openProfileButton = New-Object System.Windows.Forms.Button
$openProfileButton.Name = "OpenProfileButton"
$openProfileButton.Text = "Open Profile"
$openProfileButton.Width = 120
$openProfileButton.Height = 30
$openProfileButton.Top = 65
$openProfileButton.Left = 20
$openProfileButton.TabIndex = 1

$openProfileButton.Add_Click({
    Open-Profile
})
$ActionsGroupBox.Controls.Add($openProfileButton)
$openProfileButton.Visible = $false
$openProfileButton.Enabled = $false
$openProfileButton.TabStop = $false


<# unused
$navigateButton = New-Object System.Windows.Forms.Button
$navigateButton.Text = "Navigate to File"
$navigateButton.Width = 120
$navigateButton.Height = 30
$navigateButton.Top = 90
$navigateButton.Left = 20
$navigateButton.TabIndex = 0
$navigateButton.Visible = $false

$navigateButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "XML Files (attributes.xml)|attributes.xml"
    $openFileDialog.Title = "Select the attributes.xml file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:xmlPath = $openFileDialog.FileName
        Open-XMLViewer($script:xmlPath)
    }
})
$ActionsGroupBox.Controls.Add($navigateButton)#>

# Create the EAC Bypass group box
$eacGroupBox = New-Object System.Windows.Forms.GroupBox
$eacGroupBox.Text = "EAC Bypass"
$eacGroupBox.Width = 380
$eacGroupBox.Height = 100
$eacGroupBox.Top = 20
$eacGroupBox.Left = 160  # Position it to the right of the actions group box
$eacGroupBox.Visible = $false


# Create the Hosts File Add button
$hostsFileAddButton = New-Object System.Windows.Forms.Button
$hostsFileAddButton.Name = "hostsFileAddButton"
$hostsFileAddButton.Text = "Add Bypass to Hosts File"
$hostsFileAddButton.Width = 160
$hostsFileAddButton.Height = 30
$hostsFileAddButton.Top = 20
$hostsFileAddButton.Left = 20
$hostsFileAddButton.TabIndex = 2
$hostsFileAddButton.Add_Click({
    $hostsFilePath = Join-Path -Path $env:SystemRoot -ChildPath "System32\drivers\etc\hosts"
    if (-not (Test-Path -Path $hostsFilePath)) {
        [System.Windows.Forms.MessageBox]::Show("Hosts file not found. Operation aborted.")
        return
    }

    $userConfirmation = [System.Windows.Forms.MessageBox]::Show("This will modify the hosts file. Do you want to proceed?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($userConfirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }else {
        #$cmd = "Start-Process cmd -ArgumentList '/c cd %systemroot%\System32\drivers\etc && echo #SC Bypass >> hosts && echo 127.0.0.1    modules-cdn.eac-prod.on.epicgames.com >> hosts && echo ::1    modules-cdn.eac-prod.on.epicgames.com >> hosts' -Verb RunAs"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd %systemroot%\System32\drivers\etc && echo 127.0.0.1    modules-cdn.eac-prod.on.epicgames.com >> hosts && echo ::1    modules-cdn.eac-prod.on.epicgames.com >> hosts" -Verb RunAs
        $statusBar.Text = "Hosts file updated successfully!"
        [System.Windows.Forms.MessageBox]::Show("Hosts file updated successfully!")
    }
})
$ActionsGroupBox.Controls.Add($hostsFileAddButton)


function RemoveFromHostsFile {
    param([string]$Hostname = "modules-cdn.eac-prod.on.epicgames.com")
        # Remove entry from hosts file. Removes all entries that match the hostname (i.e. both IPv4 and IPv6).
        # Requires -RunAsAdministrator
        $hostsFile = Get-Content $hostsFilePath
        #Write-Host "About to remove $Hostname from hosts file" -ForegroundColor Gray
        $escapedHostname = [Regex]::Escape($Hostname)
        if (($hostsFile) -match ".*\s+$escapedHostname.*")  {
            $statusBar.Text = "Removing $Hostname from hosts file..."
            $hostsFile | Where-Object { -not ($_ -match ".*\s+$escapedHostname.*") } | Out-File $hostsFilePath -Encoding UTF8
            $statusBar.Text = "Hosts file updated successfully!"
            [System.Windows.Forms.MessageBox]::Show("Hosts file updated successfully!")
        } else {
            $statusBar.Text = "Hosts file not updated!"
            [System.Windows.Forms.MessageBox]::Show("$Hostname - not in hosts file (perhaps already removed); nothing to do")
        }
}


# Create the Hosts File Removal button
$hostsFileRemoveButton = New-Object System.Windows.Forms.Button
$hostsFileRemoveButton.Name = "hostsFileAddButton"
$hostsFileRemoveButton.Text = "Remove Hosts File entry"
$hostsFileRemoveButton.Width = 160
$hostsFileRemoveButton.Height = 30
$hostsFileRemoveButton.Top = 60
$hostsFileRemoveButton.Left = 20
$hostsFileRemoveButton.TabIndex = 2
$hostsFileRemoveButton.Add_Click({
    $hostsFilePath = Join-Path -Path $env:SystemRoot -ChildPath "System32\drivers\etc\hosts"
    if (-not (Test-Path -Path $hostsFilePath)) {
        [System.Windows.Forms.MessageBox]::Show("Hosts file not found. Operation aborted.")
        return
    }
    try {
        $userConfirmation = [System.Windows.Forms.MessageBox]::Show("This will modify the hosts file. Do you want to proceed?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($userConfirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }else {
            RemoveFromHostsFile
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Permission denied. Please run the script as an administrator.")
    }
    
})
$ActionsGroupBox.Controls.Add($hostsFileRemoveButton)


# Create the Delete AppData EAC TempFiles button
$deleteEACTempFilesButton = New-Object System.Windows.Forms.Button
$deleteEACTempFilesButton.Name = "DeleteEACTempFilesButton"
$deleteEACTempFilesButton.Text = "Delete EAC TempFiles"
$deleteEACTempFilesButton.Width = 160
$deleteEACTempFilesButton.Height = 30
$deleteEACTempFilesButton.Top = 20
$deleteEACTempFilesButton.Left = 190  # Position it to the right of the Hosts File Update button
$deleteEACTempFilesButton.TabIndex = 3
$deleteEACTempFilesButton.Add_Click({
    $eacTempPath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\EasyAntiCheat"
    if (Test-Path -Path $eacTempPath -PathType Container) {
        if ($eacTempPath -match "EasyAntiCheat") {
            $userConfirmation = [System.Windows.Forms.MessageBox]::Show(
                "This action will zip the files to the parent directory of '$eacTempPath' and then delete the loose files. Do you want to proceed?",
                "Confirmation",
                [System.Windows.Forms.MessageBoxButtons]::OKCancel,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            if ($userConfirmation -eq [System.Windows.Forms.DialogResult]::OK) {
                try {
                    $niceDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
                    $zipFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\EAC_TempFiles_Backup_$niceDate.zip"
                    if (Test-Path -Path $zipFilePath) {
                        Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue
                    }
                    Add-Type -AssemblyName System.IO.Compression.FileSystem
                    [System.IO.Compression.ZipFile]::CreateFromDirectory($eacTempPath, $zipFilePath)
                    Get-ChildItem -Path $eacTempPath | ForEach-Object {
                        Remove-Item -Path $_.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                    }
                    $statusBar.Text = "EAC TempFiles deleted successfully!"
                    #[System.Windows.Forms.MessageBox]::Show("EAC TempFiles deleted successfully!")
                    $deleteEACTempFilesButton.Enabled = $false
                    $deleteEACTempFilesButton.Text = "TempFiles removed!"
                    
                } catch {
                    $statusBar.Text = "An error occurred while deleting EAC TempFiles: "
                    [System.Windows.Forms.MessageBox]::Show("An error occurred while deleting EAC TempFiles")
                }
            } else {
                $statusBar.Text = "Operation canceled."
                [System.Windows.Forms.MessageBox]::Show("Operation canceled by the user.")
            }
        } else {
            $statusBar.Text = "The specified path does not contain or is not the parent of 'EasyAntiCheat'. Operation aborted."
            [System.Windows.Forms.MessageBox]::Show("The specified path does not contain or is not the parent of 'EasyAntiCheat'. Operation aborted.")
        }
    } else {
        $statusBar.Text = "EasyAntiCheat directory not found."
        [System.Windows.Forms.MessageBox]::Show("EasyAntiCheat directory not found.")
    }
})
$ActionsGroupBox.Controls.Add($deleteEACTempFilesButton)

$ActionsGroupBox.Controls.Add($eacGroupBox)

$xmlPathLabel = New-Object System.Windows.Forms.Label
$xmlPathLabel.Text = "XML found at: $xmlPath"
$xmlPathLabel.Top = $eacGroupBox.Top + $eacGroupBox.Height + 10
$xmlPathLabel.Left = $eacGroupBox.Left
$xmlPathLabel.Width = 400
$xmlPathLabel.Visible = $false
$form.Controls.Add($xmlPathLabel)

$form.Controls.Add($ActionsGroupBox)

$gridGroup = New-Object System.Windows.Forms.Panel
$gridGroup.Width = 550
$gridGroup.Height = 300
$gridGroup.Top = 200  # Adjusted the Top property to move the panel up
$gridGroup.Left = 20
#$gridGroup.Visible = $false

#$form.Controls.Add($gridGroup)

# Add a group box for the DataTable
$dataTableGroupBox = New-Object System.Windows.Forms.GroupBox
$dataTableGroupBox.Top = 180  # Position it above the DataTable
$dataTableGroupBox.Left = 20
$dataTableGroupBox.Width = 550
$dataTableGroupBox.Height = 220  # Adjust height to fit the DataTable
$dataTableGroupBox.Visible = $false  # Initially hide the group box

#$form.Controls.Add($dataTableGroupBox)

<#              unused for now
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = "File:"
$fileLabel.Top = $ActionsGroupBox.Top + $ActionsGroupBox.Height + 10
$fileLabel.Left = 20
$fileLabel.Width = 30
$form.Controls.Add($fileLabel)

$fileTextBox = New-Object System.Windows.Forms.TextBox
$fileTextBox.Top = $ActionsGroupBox.Top + $ActionsGroupBox.Height + 10
$fileTextBox.Left = 60
$fileTextBox.Width = 500
$fileTextBox.ReadOnly = $true
$fileTextBox.Visible = $true
$fileTextBox.Text = $xmlPath
$form.Controls.Add($fileTextBox)    #>

$editGroupBox = New-Object System.Windows.Forms.GroupBox
$editGroupBox.Text = "VR Centric Settings"
$editGroupBox.Width = 550
$editGroupBox.Height = 350
$editGroupBox.Top = 150         ## Adjusted the Top property to move the group box up
$editGroupBox.Left = 20
$editGroupBox.Visible = $true


$loadFromProfileButton = New-Object System.Windows.Forms.Button
$loadFromProfileButton.Name = "LoadFromProfileButton"
$loadFromProfileButton.Text = "Import settings from profile"
$loadFromProfileButton.Width = 200
$loadFromProfileButton.Height = 30
$loadFromProfileButton.Top = 30
$loadFromProfileButton.Left = 20
$loadFromProfileButton.TabIndex = 4
$loadFromProfileButton.Enabled = $loadedProfile                 #$false  # Initially disabled
$editGroupBox.Controls.Add($loadFromProfileButton)

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

# Helper function to safely extract attribute values
function Get-AttributeValue {
    param (
        [string]$attributeName
    )
    if ($script:xmlContent.Attributes.Attr) {
        $attribute = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq $attributeName }
        if ($attribute) {
            return $attribute.value
        } else {
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
        $comboBox.SelectedIndex = $defaultValue
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

                if ($debug) {[System.Windows.Forms.MessageBox]::Show("Debug: XML looks good.")}
                Update-ButtonState
                Set-ProfileArray
                if ($debug) {Write-Host "importButton lets see Paul Allens ProfileArray : " $script:profileArray -BackgroundColor White -ForegroundColor Black}
            } else {
                $statusBar.Text = "No attributes found in the XML file."
                #if ($debug) {[System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")}
            }
        }
    } catch {
        $statusBar.Text = "An error occurred while loading the XML file"
        if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $($_.Exception.Message)")
        Set-ProfileArray
        }
    }
}

$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import settings from Game"
$importButton.Name = "ImportButton"
$importButton.Width = 200
$importButton.Height = 30
$importButton.Top = 30
$importButton.Left = 260
$importButton.TabIndex = 5
$importButton.TabStop = $false
$importButton.Visible = $false  # Initially hidden
$importButton.Enabled = $false  # Initially disabled


$importButton.Add_Click({
    Import-SettingsFromGame
})

# Initially disable the import and save buttons
$importButton.Enabled = $false
$editGroupBox.Controls.Add($importButton)

$fovLabel = New-Object System.Windows.Forms.Label
$fovLabel.Text = "FOV"
$fovLabel.Top = 70
$fovLabel.Left = 150
$fovLabel.Width = 30
$editGroupBox.Controls.Add($fovLabel)

$fovTextBox = New-Object System.Windows.Forms.TextBox
$fovTextBox.Name = "FOVTextBox"
$fovTextBox.Top = 70
$fovTextBox.Left = 185
$fovTextBox.Width = 25
$fovTextBox.TextAlign = 'Left'
$fovTextBox.AcceptsTab = $true
$fovTextBox.TabIndex = 6
$editGroupBox.Controls.Add($fovTextBox)

$widthLabel = New-Object System.Windows.Forms.Label
$widthLabel.Text = "Width"
$widthLabel.Top = 70
$widthLabel.Left = 215
$widthLabel.Width = 50
$widthLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($widthLabel)

$widthTextBox = New-Object System.Windows.Forms.TextBox
$widthTextBox.Name = "WidthTextBox"
$widthTextBox.Top = 70
$widthTextBox.Left = 280
$widthTextBox.Width = 40
$widthTextBox.TextAlign = 'Left'
$widthTextBox.TabIndex = 7
$editGroupBox.Controls.Add($widthTextBox)

$heightLabel = New-Object System.Windows.Forms.Label
$heightLabel.Text = "Height"
$heightLabel.Top = 70
$heightLabel.Left = 330
$heightLabel.Width = 50
$heightLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($heightLabel)

$heightTextBox = New-Object System.Windows.Forms.TextBox
$heightTextBox.Name = "HeightTextBox"
$heightTextBox.Top = 70
$heightTextBox.Left = 390
$heightTextBox.Width = 40
$heightTextBox.TextAlign = 'Left'
$heightTextBox.TabIndex = 8
$editGroupBox.Controls.Add($heightTextBox)

$HeadtrackingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingLabel.Text = "Headtracking Toggle"
$HeadtrackingLabel.Top = 110
$HeadtrackingLabel.Left = 30
$HeadtrackingLabel.Width = 110
$editGroupBox.Controls.Add($HeadtrackingLabel)

$headtrackerEnabledComboBox = New-Object System.Windows.Forms.ComboBox
$headtrackerEnabledComboBox.Name = "headtrackerEnabledComboBox"
$headtrackerEnabledComboBox.Top = 110
$headtrackerEnabledComboBox.Left = 140
$headtrackerEnabledComboBox.Width = 100  # Adjusted width to fit the combo box
$headtrackerEnabledComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$headtrackerEnabledComboBox.Items.AddRange(@(0, 1))
$headtrackerEnabledComboBox.items.Add("Disabled")
$headtrackerEnabledComboBox.items.Add("Enabled")
$headtrackerEnabledComboBox.TabIndex = 9
$headtrackerEnabledComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($headtrackerEnabledComboBox)

$HeadtrackingSourceLabel = New-Object System.Windows.Forms.Label
$HeadtrackingSourceLabel.Text = "Headtracking Source"
$HeadtrackingSourceLabel.Top = 110
$HeadtrackingSourceLabel.Left = 260
$HeadtrackingSourceLabel.Width = 120
$editGroupBox.Controls.Add($HeadtrackingSourceLabel)

$HeadtrackingSourceComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingSourceComboBox.Name = "HeadtrackingSourceComboBox"
$HeadtrackingSourceComboBox.Top = 110
$HeadtrackingSourceComboBox.Left = 380
$HeadtrackingSourceComboBox.Width = 100  # Adjusted width to fit the combo box
$HeadtrackingSourceComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingSourceComboBox.Items.Add("None")
$HeadtrackingSourceComboBox.Items.Add("TrackIR")
$HeadtrackingSourceComboBox.Items.Add("Faceware")
$HeadtrackingSourceComboBox.Items.Add("Tobii")
$HeadtrackingSourceComboBox.TabIndex = 10
$HeadtrackingSourceComboBox.SelectedItem = $HeadtrackingSourceComboBox.Items[0]  # Set the default selected item to the first one
$editGroupBox.Controls.Add($HeadtrackingSourceComboBox)

$chromaticAberrationLabel = New-Object System.Windows.Forms.Label
$chromaticAberrationLabel.Text = "Chromatic Aberration"
$chromaticAberrationLabel.Top = 140
$chromaticAberrationLabel.Left = 30
$chromaticAberrationLabel.Width = 120
$editGroupBox.Controls.Add($chromaticAberrationLabel)

$chromaticAberrationTextBox = New-Object System.Windows.Forms.TextBox
$chromaticAberrationTextBox.Name = "ChromaticAberrationTextBox"
$chromaticAberrationTextBox.Top = 140
$chromaticAberrationTextBox.Left = 190
$chromaticAberrationTextBox.Width = 50
$chromaticAberrationTextBox.TextAlign = 'Left'
$chromaticAberrationTextBox.TabIndex = 11
$editGroupBox.Controls.Add($chromaticAberrationTextBox)

$AutoZoomLabel = New-Object System.Windows.Forms.Label
$AutoZoomLabel.Text = "Auto Zoom"
$AutoZoomLabel.Top = 140
$AutoZoomLabel.Left = 300
$AutoZoomLabel.Width = 100
$editGroupBox.Controls.Add($AutoZoomLabel)

<#$AutoZoomTextBox = New-Object System.Windows.Forms.TextBox
$AutoZoomTextBox.Name = "AutoZoomTextBox"
$AutoZoomTextBox.Top = 140
$AutoZoomTextBox.Left = 410
$AutoZoomTextBox.Width = 50
$AutoZoomTextBox.TextAlign = 'Left'
$AutoZoomTextBox.TabIndex = 12
$editGroupBox.Controls.Add($AutoZoomTextBox)#>

$AutoZoomComboBox = New-Object System.Windows.Forms.ComboBox
$AutoZoomComboBox.Name = "AutoZoomComboBox"
$AutoZoomComboBox.Top = 140
$AutoZoomComboBox.Left = 410
$AutoZoomComboBox.Width = 75
$AutoZoomComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$AutoZoomComboBox.Items.Add("Disabled")
$AutoZoomComboBox.Items.Add("Enabled")
$AutoZoomComboBox.TabIndex = 12
$AutoZoomComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($AutoZoomComboBox)

$MotionBlurLabel = New-Object System.Windows.Forms.Label
$MotionBlurLabel.Text = "Motion Blur"
$MotionBlurLabel.Top = 170
$MotionBlurLabel.Left = 70
$MotionBlurLabel.Width = 100
$editGroupBox.Controls.Add($MotionBlurLabel)

#$MotionBlurTextBox = New-Object System.Windows.Forms.TextBox
#$MotionBlurTextBox.Name = "MotionBlurTextBox"
#$MotionBlurTextBox.Top = 170
#$MotionBlurTextBox.Left = 190
#$MotionBlurTextBox.Width = 50
#$MotionBlurTextBox.TextAlign = 'Left'
#$MotionBlurTextBox.TabIndex = 13
#$editGroupBox.Controls.Add($MotionBlurTextBox)

$MotionBlurComboBox = New-Object System.Windows.Forms.ComboBox
$MotionBlurComboBox.Name = "MotionBlurComboBox"
$MotionBlurComboBox.Top = 170
$MotionBlurComboBox.Left = 190
$MotionBlurComboBox.Width = 75
$MotionBlurComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$MotionBlurComboBox.Items.Add("Disabled")
$MotionBlurComboBox.Items.Add("Enabled")
$MotionBlurComboBox.Items.Add("Ship Only")
$MotionBlurComboBox.Items.Add("Debug Mode")
$MotionBlurComboBox.TabIndex = 13
$MotionBlurComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($MotionBlurComboBox)

$ShakeScaleLabel = New-Object System.Windows.Forms.Label
$ShakeScaleLabel.Text = "Shake Scale"
$ShakeScaleLabel.Top = 170
$ShakeScaleLabel.Left = 300
$ShakeScaleLabel.Width = 100
$editGroupBox.Controls.Add($ShakeScaleLabel)

$ShakeScaleTextBox = New-Object System.Windows.Forms.TextBox
$ShakeScaleTextBox.Name = "ShakeScaleTextBox"
$ShakeScaleTextBox.Top = 170
$ShakeScaleTextBox.Left = 410
$ShakeScaleTextBox.Width = 50
$ShakeScaleTextBox.TextAlign = 'Left'
$ShakeScaleTextBox.TabIndex = 14
$editGroupBox.Controls.Add($ShakeScaleTextBox)

$CameraSpringMovementLabel = New-Object System.Windows.Forms.Label
$CameraSpringMovementLabel.Text = "Camera Spring Movement"
$CameraSpringMovementLabel.Top = 200
$CameraSpringMovementLabel.Left = 30
$CameraSpringMovementLabel.Width = 150
$editGroupBox.Controls.Add($CameraSpringMovementLabel)

$CameraSpringMovementTextBox = New-Object System.Windows.Forms.TextBox
$CameraSpringMovementTextBox.Name = "CameraSpringMovementTextBox"
$CameraSpringMovementTextBox.Top = 200
$CameraSpringMovementTextBox.Left = 190
$CameraSpringMovementTextBox.Width = 50
$CameraSpringMovementTextBox.TextAlign = 'Left'
$CameraSpringMovementTextBox.TabIndex = 15
$editGroupBox.Controls.Add($CameraSpringMovementTextBox)

$FilmGrainLabel = New-Object System.Windows.Forms.Label
$FilmGrainLabel.Text = "Film Grain"
$FilmGrainLabel.Top = 200
$FilmGrainLabel.Left = 300
$FilmGrainLabel.Width = 100
$editGroupBox.Controls.Add($FilmGrainLabel)

#$FilmGrainTextBox = New-Object System.Windows.Forms.TextBox
#$FilmGrainTextBox.Name = "FilmGrainTextBox"
#$FilmGrainTextBox.Top = 200
#$FilmGrainTextBox.Left = 410
#$FilmGrainTextBox.Width = 50
#$FilmGrainTextBox.TextAlign = 'Left'
#$FilmGrainTextBox.TabIndex = 16
#$editGroupBox.Controls.Add($FilmGrainTextBox)
$FilmGrainComboBox = New-Object System.Windows.Forms.ComboBox
$FilmGrainComboBox.Name = "FilmGrainComboBox"
$FilmGrainComboBox.Top = 200
$FilmGrainComboBox.Left = 410
$FilmGrainComboBox.Width = 75
$FilmGrainComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$FilmGrainComboBox.Items.Add("Disabled")
$FilmGrainComboBox.Items.Add("Enabled")
$FilmGrainComboBox.TabIndex = 16
$FilmGrainComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($FilmGrainComboBox)

$GForceBoostZoomScaleLabel = New-Object System.Windows.Forms.Label
$GForceBoostZoomScaleLabel.Text = "G-Force Boost Zoom Scale"
$GForceBoostZoomScaleLabel.Top = 230
$GForceBoostZoomScaleLabel.Left = 30
$GForceBoostZoomScaleLabel.Width = 150
$editGroupBox.Controls.Add($GForceBoostZoomScaleLabel)

$GForceBoostZoomScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceBoostZoomScaleTextBox.Name = "GForceBoostZoomScaleTextBox"
$GForceBoostZoomScaleTextBox.Top = 230
$GForceBoostZoomScaleTextBox.Left = 190
$GForceBoostZoomScaleTextBox.Width = 50
$GForceBoostZoomScaleTextBox.TextAlign = 'Left'
$GForceBoostZoomScaleTextBox.TabIndex = 17
$editGroupBox.Controls.Add($GForceBoostZoomScaleTextBox)

$GForceHeadBobScaleLabel = New-Object System.Windows.Forms.Label
$GForceHeadBobScaleLabel.Text = "G-Force Head Bob Scale"
$GForceHeadBobScaleLabel.Top = 230
$GForceHeadBobScaleLabel.Left = 260
$GForceHeadBobScaleLabel.Width = 150
$editGroupBox.Controls.Add($GForceHeadBobScaleLabel)

$GForceHeadBobScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceHeadBobScaleTextBox.Name = "GForceHeadBobScaleTextBox"
$GForceHeadBobScaleTextBox.Top = 230
$GForceHeadBobScaleTextBox.Left = 410
$GForceHeadBobScaleTextBox.Width = 50
$GForceHeadBobScaleTextBox.TextAlign = 'Left'
$GForceHeadBobScaleTextBox.TabIndex = 18
$editGroupBox.Controls.Add($GForceHeadBobScaleTextBox)

$HeadtrackingEnableRollFPSLabel = New-Object System.Windows.Forms.Label
$HeadtrackingEnableRollFPSLabel.Text = "Headtracking FPS Head Roll"
$HeadtrackingEnableRollFPSLabel.Top = 260
$HeadtrackingEnableRollFPSLabel.Left = 30
$HeadtrackingEnableRollFPSLabel.Width = 150
$editGroupBox.Controls.Add($HeadtrackingEnableRollFPSLabel)

$HeadtrackingEnableRollFPSComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingEnableRollFPSComboBox.Name = "HeadtrackingEnableRollFPSComboBox"
$HeadtrackingEnableRollFPSComboBox.Top = 260
$HeadtrackingEnableRollFPSComboBox.Left = 190
$HeadtrackingEnableRollFPSComboBox.Width = 75
$HeadtrackingEnableRollFPSComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingEnableRollFPSComboBox.Items.Add("Disabled")
$HeadtrackingEnableRollFPSComboBox.Items.Add("Enabled")
$HeadtrackingEnableRollFPSComboBox.TabIndex = 19
$HeadtrackingEnableRollFPSComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($HeadtrackingEnableRollFPSComboBox)

$HeadtrackingDisableDuringWalkingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingDisableDuringWalkingLabel.Text = "Headtracking in FPS"
$HeadtrackingDisableDuringWalkingLabel.Top = 260
$HeadtrackingDisableDuringWalkingLabel.Left = 270
$HeadtrackingDisableDuringWalkingLabel.Width = 120
$editGroupBox.Controls.Add($HeadtrackingDisableDuringWalkingLabel)

$HeadtrackingDisableDuringWalkingComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingDisableDuringWalkingComboBox.Name = "HeadtrackingDisableDuringWalkingComboBox"
$HeadtrackingDisableDuringWalkingComboBox.Top = 260
$HeadtrackingDisableDuringWalkingComboBox.Left = 410
$HeadtrackingDisableDuringWalkingComboBox.Width = 75
$HeadtrackingDisableDuringWalkingComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingDisableDuringWalkingComboBox.Items.Add("On")
$HeadtrackingDisableDuringWalkingComboBox.Items.Add("Off")
$HeadtrackingDisableDuringWalkingComboBox.TabIndex = 20
$HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($HeadtrackingDisableDuringWalkingComboBox)

$HeadtrackingThirdPersonCameraToggleLabel = New-Object System.Windows.Forms.Label
$HeadtrackingThirdPersonCameraToggleLabel.Text = "Headtracking in Third Person"
$HeadtrackingThirdPersonCameraToggleLabel.Top = 290
$HeadtrackingThirdPersonCameraToggleLabel.Left = 30
$HeadtrackingThirdPersonCameraToggleLabel.Width = 160
$editGroupBox.Controls.Add($HeadtrackingThirdPersonCameraToggleLabel)

$HeadtrackingThirdPersonCameraToggleComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingThirdPersonCameraToggleComboBox.Name = "HeadtrackingThirdPersonCameraToggleComboBox"
$HeadtrackingThirdPersonCameraToggleComboBox.Top = 290
$HeadtrackingThirdPersonCameraToggleComboBox.Left = 190
$HeadtrackingThirdPersonCameraToggleComboBox.Width = 75
$HeadtrackingThirdPersonCameraToggleComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HeadtrackingThirdPersonCameraToggleComboBox.Items.Add("Off")
$HeadtrackingThirdPersonCameraToggleComboBox.Items.Add("On")
$HeadtrackingThirdPersonCameraToggleComboBox.TabIndex = 21
$HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($HeadtrackingThirdPersonCameraToggleComboBox)

# Update the state of the buttons after loading the XML content

$saveProfileButton = New-Object System.Windows.Forms.Button
$saveProfileButton.Name = "SaveProfileButton"
$saveProfileButton.Text = "Save Profile"
$saveProfileButton.Width = 120
$saveProfileButton.Height = 30
$saveProfileButton.Top = 315
$saveProfileButton.Left = 130
$saveProfileButton.TabIndex = 21
$saveProfileButton.Enabled = $false  # Initially disabled
$saveProfileButton.Add_Click({
    Save-Profile
})
$editGroupBox.Controls.Add($saveProfileButton)

$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Name = "SaveButton"
$saveButton.Text = "Save to Game"
$saveButton.Width = 120
$saveButton.Height = 30
$saveButton.Top = 315
$saveButton.Left = 330
$saveButton.TabIndex = 22
$saveButton.Add_Click({
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
        # Save the XML content to the specified path
        # Check if VorpX task is running

        $vorpxRunning = Get-Process -Name "vorpControl" -ErrorAction SilentlyContinue
        if ($vorpxRunning) {
            #$statusBar.Text = "VorpX is running."
            $vorpxindicatorText = "VorpX is running."
        } else {
            #$statusBar.Text = "VorpX is NOT running."
            $vorpxindicatorText = "VorpX is NOT running."
        }

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

        # Show the edit group box
        $editGroupBox.Visible = $true

        # Update button state
        Update-ButtonState
    } else {
        [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
    }

})
# Initially disable the import and save buttons
$saveButton.Enabled = $false
$editGroupBox.Controls.Add($saveButton)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Width = 120
$closeButton.Height = 30
$closeButton.Top = 115

$closeButton.Left = 300
$closeButton.TabIndex = 23
$closeButton.Add_Click({
    $form.Close()
})

<#$saveAcknowledgeLabel = New-Object System.Windows.Forms.Label
$saveAcknowledgeLabel.Text = "Saved. You may now close this window. Remember to start VorpX Control Panel and the Watcher before launching Star Citizen!" + "`n`n" + $vorpxindicatorText
$saveAcknowledgeLabel.Font = New-Object System.Drawing.Font($saveAcknowledgeLabel.Font.FontFamily, $saveAcknowledgeLabel.Font.Size, [System.Drawing.FontStyle]::Bold)
$saveAcknowledgeLabel.ForeColor = [System.Drawing.Color]::Red
$saveAcknowledgeLabel.Top = 530
$saveAcknowledgeLabel.Left = 30
$saveAcknowledgeLabel.Width = 500
$saveAcknowledgeLabel.Height = 50
$saveAcknowledgeLabel.Visible = $false
$form.Controls.Add($saveAcknowledgeLabel)#>


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
$saveButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$saveProfileButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$loadFromProfileButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$importButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$deleteEACTempFilesButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$hostsFileAddButton.add_MouseHover({ $ShowHelp.Invoke($_) })

#connect the ShowHelp scriptblock with the _MouseHover event for this control

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
        "deleteEACTempFilesButton" {$tip = "Delete EAC TempFiles"}
        "hostsFileAddButton" {$tip = "Update hosts file for EAC Bypass"}
        Default { $tip = "No tooltip available for this control." }
      }
     $toolTips.SetToolTip($this, $tip)
}

# Create a status bar
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "Ready"
$statusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($statusBar)


if (($null -ne $AutoDetectSCPath) -and (Test-Path -Path $AutoDetectSCPath)) {
    $script:liveFolderPath = Join-Path -Path $AutoDetectSCPath -ChildPath "LIVE"
    $script:xmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "user\client\0\Profiles\default\attributes.xml"
    Set-ProfileArray
    #$script:profileArray.Add([PSCustomObject]@{ AttributesXmlPath = $script:xmlPath }) | Out-Null
    if ($debug) {Write-Host "debug: $script:xmlPath" -BackgroundColor White -ForegroundColor Black}
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
    [System.Windows.Forms.MessageBox]::Show("Star Citizen not found.")
}



function Open-FovWizard {
    # Open the FOV wizard form
    # Define the path to the Python script
    $pythonScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "fovwizard.py"

    # Check if the Python script exists
    if (-not (Test-Path -Path $pythonScriptPath)) {
        [System.Windows.Forms.MessageBox]::Show("FOV Wizard script not found at: $pythonScriptPath")
        return
    }
    # Launch the Python script GUI inside a form
    try {
        $pythonProcess = New-Object System.Diagnostics.Process
        $pythonProcess.StartInfo.FileName = "python"
        $pythonProcess.StartInfo.Arguments = "`"$pythonScriptPath`""
        $pythonProcess.StartInfo.UseShellExecute = $false
        $pythonProcess.StartInfo.RedirectStandardOutput = $true
        $pythonProcess.StartInfo.RedirectStandardError = $false
        $pythonProcess.StartInfo.CreateNoWindow = $true

        #we are using the clipboard to pass data between the python script and this script.
        [System.Windows.Forms.Clipboard]::Clear()

        # Start the Python process
        $pythonProcess.Start() | Out-Null

        # Wait for the Python process to write to the clipboard
        Add-Type -AssemblyName System.Windows.Forms
        $clipboardContent = $null
        while ($pythonProcess.HasExited -eq $false) {
            try {
            $clipboardContent = [System.Windows.Forms.Clipboard]::GetText()
            if (-not [string]::IsNullOrWhiteSpace($clipboardContent)) {
                break
            }
            } catch {
            Start-Sleep -Milliseconds 100
            }
        }

        # Wait for the Python process to exit
        $pythonProcess.WaitForExit()

        if ($pythonProcess.ExitCode -ne 0) {
            [System.Windows.Forms.MessageBox]::Show("Error running FOV Wizard script. Exit code: $($pythonProcess.ExitCode)")
        } else {
            #[System.Windows.Forms.MessageBox]::Show("FOV Wizard completed. Clipboard content: $clipboardContent. Populating input boxes...")
            
            #[System.Windows.Forms.MessageBox]::Show("Populating input boxes: $clipboardContent")
            # Populate the input boxes with the values from the clipboard
            if ($clipboardContent -match 'FOV:\s*(\d+\.?\d*)') {
                $fovTextBox.Text = $matches[1]
            }
            if ($clipboardContent -match 'Width:\s*(\d+\.?\d*)') {
                $widthTextBox.Text = $matches[1]
            }
            if ($clipboardContent -match 'Height:\s*(\d+\.?\d*)') {
                $heightTextBox.Text = $matches[1]

                    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
                    if ([int]$matches[1] -gt $screenHeight) {
                        [System.Windows.Forms.MessageBox]::Show("Warning: The specified height ($($matches[1])) exceeds your screen's vertical resolution ($screenHeight).")
                        $statusBar.Text = "Warning: Height exceeds screen resolution."
                    }
            }

        }
        #[System.Windows.Forms.MessageBox]::Show("FOV Wizard launched successfully!")
    } catch {
        # [System.Windows.Forms.MessageBox]::Show("An error occurred while launching the FOV Wizard: $($_.Exception.Message)")
        [System.Windows.Forms.MessageBox]::Show("Could not launch FOV Wizard. Please ensure Python is installed and the script is accessible.")
    }

    #$pythonOutput = & python $pythonScriptPath 2>&1
    #if ($LASTEXITCODE -ne 0) {
    #    [System.Windows.Forms.MessageBox]::Show("Error running FOV Wizard script: $pythonOutput")
    #    return
    #}

}

# LETS ADD A NEW BUTTON TO THE FORM BELOW THE OPEN PROFILE BUTTON THAT IS CALLED CHOOSE FOV WIZARD
$chooseFovWizardButton = New-Object System.Windows.Forms.Button
$chooseFovWizardButton.Name = "ChooseFovWizardButton"
$chooseFovWizardButton.Text = "FOV Wizard"
$chooseFovWizardButton.Font = New-Object System.Drawing.Font($chooseFovWizardButton.Font.FontFamily, $chooseFovWizardButton.Font.Size, [System.Drawing.FontStyle]::Bold)
$chooseFovWizardButton.Width = 80
$chooseFovWizardButton.Height = 30
$chooseFovWizardButton.Top = 65
$chooseFovWizardButton.Left = 30
$chooseFovWizardButton.TabIndex = 24
$chooseFovWizardButton.Add_Click({
    # Call the function to open the FOV wizard
    Open-FovWizard
})
$chooseFovWizardButton.Visible = $true
$chooseFovWizardButton.Enabled = $true
$chooseFovWizardButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$editGroupBox.Controls.Add($chooseFovWizardButton)

$form.Controls.Add($editGroupBox)


# Create the Toggle VR button
$toggleVRButton = New-Object System.Windows.Forms.Button
$toggleVRButton.Name = "ToggleVRButton"
#$toggleVRButton.Text = "Toggle VR On"
if ($headtrackerEnabledComboBox.SelectedIndex -eq 0) {
    $toggleVRButton.Text = "Toggle VR On"
}
elseif ($headtrackerEnabledComboBox.SelectedIndex -gt 0) {
    $toggleVRButton.Text = "Toggle VR Off"
}
$toggleVRButton.Width = 160
$toggleVRButton.Height = 60  # Twice as tall as nearby buttons
$toggleVRButton.Top = 20
#$toggleVRButton.Left = $ActionsGroupBox.Width - $toggleVRButton.Width - 20  # Align to the right-hand side
$toggleVRButton.Left = 360  # Position it to the right of the Hosts File Update button
$toggleVRButton.TabIndex = 25
$toggleVRButton.Visible = $true
$toggleVRButton.Enabled = $true
$toggleVRButton.Add_Click({
    if ($toggleVRButton.Text -eq "Toggle VR On") {
        # Set VR mode values
        #$fovTextBox.Text = "110"  # Example FOV for VR
        #$widthTextBox.Text = "1920"  # Example width for VR
        #$heightTextBox.Text = "1080"  # Example height for VR
        $headtrackerEnabledComboBox.SelectedIndex = 1  # Enable head tracking
        $HeadtrackingSourceComboBox.SelectedIndex = 1  # Set to TrackIR
        $chromaticAberrationTextBox.Text = "0.00"  # Recommended value for VR
        $AutoZoomComboBox.SelectedIndex = 0  # Disable auto zoom
        $MotionBlurComboBox.SelectedIndex = 0  # Disable motion blur
        $ShakeScaleTextBox.Text = "0"  # Disable shake scale
        $CameraSpringMovementTextBox.Text = "0"  # Disable camera spring movement
        $FilmGrainComboBox.SelectedIndex = 0  # Disable film grain
        $GForceBoostZoomScaleTextBox.Text = "0.0"  # Recommended value for VR
        $GForceHeadBobScaleTextBox.Text = "0.0"  # Recommended value for VR
        $HeadtrackingEnableRollFPSComboBox.SelectedIndex = 1  # Enable head roll in FPS
        $HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 0  # Enable head tracking during walking
        $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 1  # Enable head tracking in third person

        # Launch the FOV Wizard
        #Open-FovWizard

        # Confirm settings with the user
        #$confirmation = [System.Windows.Forms.MessageBox]::Show(
        #    "VR settings have been applied. Please review the settings and confirm to save them to the game.",
        #    "Confirm VR Settings",
        #    [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        #    [System.Windows.Forms.MessageBoxIcon]::Information
        #)

        #if ($confirmation -eq [System.Windows.Forms.DialogResult]::OK) {
            # Save settings to the game
            $saveButton.PerformClick()
            $statusBar.Text = "Saved. You may now close this window. Remember to start VorpX and the listener before launching Star Citizen!"
            $toggleVRButton.Text = "Toggle VR Off"
        #}
    } else {
        # Reset to default or non-VR mode (optional)
        $headtrackerEnabledComboBox.SelectedIndex = 0  # Enable head tracking
        $HeadtrackingSourceComboBox.SelectedIndex = 0  # Set to TrackIR
        #$chromaticAberrationTextBox.Text = "0.00"  # Recommended value for VR
        $AutoZoomComboBox.SelectedIndex = 1  # Disable auto zoom
        #$MotionBlurComboBox.SelectedIndex = 0  # Disable motion blur
        $ShakeScaleTextBox.Text = "0"  # Disable shake scale
        $CameraSpringMovementTextBox.Text = "1"  # camera spring movement
        #$FilmGrainComboBox.SelectedIndex = 0  # film grain
        $GForceBoostZoomScaleTextBox.Text = "1.0"
        $GForceHeadBobScaleTextBox.Text = "1.0"
        $HeadtrackingEnableRollFPSComboBox.SelectedIndex = 0  # Enable head roll in FPS
        $HeadtrackingDisableDuringWalkingComboBox.SelectedIndex = 1  # Enable head tracking during walking (disabled is on state)
        $HeadtrackingThirdPersonCameraToggleComboBox.SelectedIndex = 0  # Enable head tracking in third person
        # [System.Windows.Forms.MessageBox]::Show("VR settings have been disabled.")
        $statusBar.Text = "Settings have been Saved. Remember to stop VorpX or Pause the Watcher before launching Star Citizen!"
        $saveButton.PerformClick()
        $toggleVRButton.Text = "Toggle VR On"
    }
})
$ActionsGroupBox.Controls.Add($toggleVRButton)


$form.ShowDialog()

<#      extra to add to the form eventually.
<Attr name="Upscaling" value="1"/>
<Attr name="UpscalingTechnique" value="2"/> #DLSS
#>

