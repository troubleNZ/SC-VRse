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

$scriptVersion = "0.1.16"                        # enhancement: tool tips!
$BackupFolderName = "VRSE AE Backup"
$profileContent = @()
$script:profileArray = [System.Collections.ArrayList]@()

$debug = $false

$script:xmlPath = $null
$script:xmlContent = @()
$script:dataTable = $null
$script:xmlArray = @()
$script:dataGridView = @()

$niceDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

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

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
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
$ActionsGroupBox = New-Object System.Windows.Forms.GroupBox
$ActionsGroupBox.Text = "Actions"
$ActionsGroupBox.Width = 550
$ActionsGroupBox.Height = 150
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
            if ($script:profileArray.Count -gt 0) {
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
    <#param (
        [System.Windows.Forms.DataGridView]$script:dataGridView
    )#>
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
            AttributesXmlPath = $script:attributesXmlPath;
            DarkMode = if ($darkModeMenuItem.Text -eq "Disable Dark Mode") { $true } else { $false };
            FOV = $fovTextBox.Text;
            Height = $heightTextBox.Text;
            Width = $widthTextBox.Text;
            Headtracking = $headtrackerEnabledComboBox.SelectedIndex;
            HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex;
            ChromaticAberration = $chromaticAberrationTextBox.Text;
            AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text;
            MotionBlur = $MotionBlurTextBox.Text;
            ShakeScale = $ShakeScaleTextBox.Text;
            CameraSpringMovement = $CameraSpringMovementTextBox.Text;
            FilmGrain = $FilmGrainTextBox.Text;
            GForceBoostZoomScale = $GForceBoostZoomScaleTextBox.Text;
            GForceHeadBobScale = $GForceHeadBobScaleTextBox.Text;

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

                $gridGroup.Controls.Add($script:dataGridView)

                # Show the dataTableGroupBox and set its text to the XML path
                $dataTableGroupBox.Text = $Path
                $dataTableGroupBox.Visible = $true
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
                    $AutoZoomTextBox.Text = $script:profileArray.AutoZoomOnSelectedTarget
                } else {
                    $AutoZoomTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                }
                if ($null -ne $script:profileArray.MotionBlur) {
                    $MotionBlurTextBox.Text = $script:profileArray.MotionBlur
                } else {
                    $MotionBlurTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
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
                    $FilmGrainTextBox.Text = $script:profileArray.FilmGrain
                } else {
                    $FilmGrainTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
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
                $script:profileArray[0].AttributesXmlPath = $script:attributesXmlPath
                $script:profileArray[0].DarkMode = if ($darkModeMenuItem.Text -eq "Disable Dark Mode") { $true } else { $false }
                $script:profileArray[0].FOV = $fovTextBox.Text
                $script:profileArray[0].Height = $heightTextBox.Text
                $script:profileArray[0].Width = $widthTextBox.Text
                $script:profileArray[0].Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString()
                $script:profileArray[0].HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString()
                $script:profileArray[0].ChromaticAberration = $chromaticAberrationTextBox.Text
                $script:profileArray[0].AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text
                $script:profileArray[0].MotionBlur = $MotionBlurTextBox.Text
                $script:profileArray[0].ShakeScale = $ShakeScaleTextBox.Text
                $script:profileArray[0].CameraSpringMovement = $CameraSpringMovementTextBox.Text
                $script:profileArray[0].FilmGrain = $FilmGrainTextBox.Text
                $script:profileArray[0].GForceBoostZoomScale = $GForceBoostZoomScaleTextBox.Text
                $script:profileArray[0].GForceHeadBobScale = $GForceHeadBobScaleTextBox.Text

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
                        $script:liveFolderPath = $script:profileArray.SCPath
                        $script:attributesXmlPath = $script:profileArray.AttributesXmlPath
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

# Add an item to the menu called "Open XML"
$actionsMenuItem = New-Object System.Windows.Forms.MenuItem
$actionsMenuItem.Text = "&Actions"
$mainMenu.MenuItems.Add($actionsMenuItem)

$openXmlMenuItem = New-Object System.Windows.Forms.MenuItem
$openXmlMenuItem.Text = "&Open XML"

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
                        $AutoZoomTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "AutoZoomOnSelectedTarget" } | Select-Object -ExpandProperty value
                        $MotionBlurTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" } | Select-Object -ExpandProperty value
                        $ShakeScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "ShakeScale" } | Select-Object -ExpandProperty value
                        $CameraSpringMovementTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "CameraSpringMovement" } | Select-Object -ExpandProperty value
                        $FilmGrainTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FilmGrain" } | Select-Object -ExpandProperty value
                        $GForceBoostZoomScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceBoostZoomScale" } | Select-Object -ExpandProperty value
                        $GForceHeadBobScaleTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceHeadBobScale" } | Select-Object -ExpandProperty value

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

#add an item - Exit, which will close the application
$exitMenuItem = New-Object System.Windows.Forms.MenuItem
$exitMenuItem.Text = "E&xit"
$exitMenuItem.Add_Click({
    $form.Close()
})
$fileMenuItem.MenuItems.Add($exitMenuItem)  # Add the Exit menu item to the File menu

$form.Menu = $mainMenu  # Set the main menu of the form to the created menu

# Create the Find Live Folder button
$findLiveFolderButton = New-Object System.Windows.Forms.Button
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
$openProfileButton.Visible = $true
$openProfileButton.Enabled = $true


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

# Create the Hosts File Update button
$hostsFileUpdateButton = New-Object System.Windows.Forms.Button
$hostsFileUpdateButton.Name = "HostsFileUpdateButton"
$hostsFileUpdateButton.Text = "Hosts File Update"
$hostsFileUpdateButton.Width = 160
$hostsFileUpdateButton.Height = 30
$hostsFileUpdateButton.Top = 30
$hostsFileUpdateButton.Left = 20
$hostsFileUpdateButton.TabIndex = 2
$hostsFileUpdateButton.Add_Click({
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
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd %systemroot%\System32\drivers\etc && echo #SC Bypass >> hosts && echo 127.0.0.1    modules-cdn.eac-prod.on.epicgames.com >> hosts && echo ::1    modules-cdn.eac-prod.on.epicgames.com >> hosts" -Verb RunAs
        $statusBar.Text = "Hosts file updated successfully!"
        [System.Windows.Forms.MessageBox]::Show("Hosts file updated successfully!")
    }
})
$eacGroupBox.Controls.Add($hostsFileUpdateButton)

# Create the Delete AppData EAC TempFiles button
$deleteEACTempFilesButton = New-Object System.Windows.Forms.Button
$deleteEACTempFilesButton.Name = "DeleteEACTempFilesButton"
$deleteEACTempFilesButton.Text = "Delete EAC TempFiles"
$deleteEACTempFilesButton.Width = 160
$deleteEACTempFilesButton.Height = 30
$deleteEACTempFilesButton.Top = 30
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
                    [System.Windows.Forms.MessageBox]::Show("EAC TempFiles deleted successfully!")
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
$eacGroupBox.Controls.Add($deleteEACTempFilesButton)

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
$editGroupBox.Top = 220         ## Adjusted the Top property to move the group box up
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
$loadFromProfileButton.Enabled = $false  # Initially disabled
$editGroupBox.Controls.Add($loadFromProfileButton)

$loadFromProfileButton.Add_Click({
    $script:xmlPath = $script:profileArray.AttributesXmlPath
    if (Test-Path -Path $script:profileArray.AttributesXmlPath) {
        Open-XMLViewer($script:profileArray.AttributesXmlPath)
    } else {
        $statusBar.Text = "Profile JSON doesn't contain attributes path."
        [System.Windows.Forms.MessageBox]::Show("profile json doesnt contain attributes path?")
    }
})

$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import settings from Game"
$importButton.Name = "ImportButton"
$importButton.Width = 200
$importButton.Height = 30
$importButton.Top = 30
$importButton.Left = 260
$importButton.TabIndex = 5

$importButton.Add_Click({
    try {
        $script:xmlContent = [xml](Get-Content $script:xmlPath)
        if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {

            if ($script:xmlContent.Attributes -and $script:xmlContent.Attributes.Attr) {

                # Helper function to safely extract attribute values
                function Get-AttributeValue {
                    param (
                        [string]$attributeName
                    )
                    return $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq $attributeName } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                }

                $fovTextBox.Text = Get-AttributeValue "FOV"
                $widthTextBox.Text = Get-AttributeValue "Width"
                $heightTextBox.Text = Get-AttributeValue "Height"
                $headtrackingValue = Get-AttributeValue "HeadtrackingToggle"
                $headtrackingSourceValue = Get-AttributeValue "HeadtrackingSource"

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
                        $statusBar.Text = "Invalid value for $($comboBox.Name). Setting to default ($defaultValue)."
                        $comboBox.SelectedIndex = $defaultValue
                    }
                }

                SetComboBoxValue -comboBox $headtrackerEnabledComboBox -value $headtrackingValue
                SetComboBoxValue -comboBox $HeadtrackingSourceComboBox -value $headtrackingSourceValue

                if ($debug) {[System.Windows.Forms.MessageBox]::Show("Debug: XML looks good.")}
                $statusBar.Text = "XML looks good."
                Start-Sleep -Milliseconds 500
                $statusBar.Text = "Ready"
            } else {
                if ($debug) {[System.Windows.Forms.MessageBox]::Show("FOV attribute is missing in the XML file.")}
                $fovTextBox.Text = ""
                $heightTextBox.Text = ""
                $widthTextBox.Text = ""
            }
        }
    } catch {
        $statusBar.Text = "An error occurred while loading the XML file"
        #if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $($_.Exception.Message)")}
    }
})

# Initially disable the import and save buttons
$importButton.Enabled = $false
$editGroupBox.Controls.Add($importButton)

$fovLabel = New-Object System.Windows.Forms.Label
$fovLabel.Text = "FOV"
$fovLabel.Top = 70
$fovLabel.Left = 40
$fovLabel.Width = 30
$editGroupBox.Controls.Add($fovLabel)

$fovTextBox = New-Object System.Windows.Forms.TextBox
$fovTextBox.Name = "FOVTextBox"
$fovTextBox.Top = 70
$fovTextBox.Left = 90
$fovTextBox.Width = 50  # Half the original width
$fovTextBox.TextAlign = 'Left'
$fovTextBox.AcceptsTab = $true
$fovTextBox.TabIndex = 6
$editGroupBox.Controls.Add($fovTextBox)

$widthLabel = New-Object System.Windows.Forms.Label
$widthLabel.Text = "Width"
$widthLabel.Top = 70
$widthLabel.Left = 180
$widthLabel.Width = 50
$widthLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($widthLabel)

$widthTextBox = New-Object System.Windows.Forms.TextBox
$widthTextBox.Name = "WidthTextBox"
$widthTextBox.Top = 70
$widthTextBox.Left = 250
$widthTextBox.Width = 50  # Half the original width
$widthTextBox.TextAlign = 'Left'
$widthTextBox.TabIndex = 7
$editGroupBox.Controls.Add($widthTextBox)

$heightLabel = New-Object System.Windows.Forms.Label
$heightLabel.Text = "Height"
$heightLabel.Top = 70
$heightLabel.Left = 320
$heightLabel.Width = 50
$heightLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($heightLabel)

$heightTextBox = New-Object System.Windows.Forms.TextBox
$heightTextBox.Name = "HeightTextBox"
$heightTextBox.Top = 70
$heightTextBox.Left = 400
$heightTextBox.Width = 50  # Half the original width
$heightTextBox.TextAlign = 'Left'
$heightTextBox.TabIndex = 8
$editGroupBox.Controls.Add($heightTextBox)

$HeadtrackingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingLabel.Text = "Headtracking Enabled"
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
$HeadtrackingSourceLabel.Text = "HeadtrackingSource"
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
$chromaticAberrationLabel.Top = 160
$chromaticAberrationLabel.Left = 30
$chromaticAberrationLabel.Width = 120
$editGroupBox.Controls.Add($chromaticAberrationLabel)

$chromaticAberrationTextBox = New-Object System.Windows.Forms.TextBox
$chromaticAberrationTextBox.Name = "ChromaticAberrationTextBox"
$chromaticAberrationTextBox.Top = 160
$chromaticAberrationTextBox.Left = 190
$chromaticAberrationTextBox.Width = 50  # Half the original width
$chromaticAberrationTextBox.TextAlign = 'Left'
$chromaticAberrationTextBox.TabIndex = 11
$editGroupBox.Controls.Add($chromaticAberrationTextBox)

$AutoZoomLabel = New-Object System.Windows.Forms.Label
$AutoZoomLabel.Text = "Auto Zoom"
$AutoZoomLabel.Top = 160
$AutoZoomLabel.Left = 300
$AutoZoomLabel.Width = 100
$editGroupBox.Controls.Add($AutoZoomLabel)

$AutoZoomTextBox = New-Object System.Windows.Forms.TextBox
$AutoZoomTextBox.Name = "AutoZoomTextBox"
$AutoZoomTextBox.Top = 160
$AutoZoomTextBox.Left = 410
$AutoZoomTextBox.Width = 50  # Half the original width
$AutoZoomTextBox.TextAlign = 'Left'
$AutoZoomTextBox.TabIndex = 12
$editGroupBox.Controls.Add($AutoZoomTextBox)

$MotionBlurLabel = New-Object System.Windows.Forms.Label
$MotionBlurLabel.Text = "Motion Blur"
$MotionBlurLabel.Top = 190
$MotionBlurLabel.Left = 70
$MotionBlurLabel.Width = 100
$editGroupBox.Controls.Add($MotionBlurLabel)

$MotionBlurTextBox = New-Object System.Windows.Forms.TextBox
$MotionBlurTextBox.Name = "MotionBlurTextBox"
$MotionBlurTextBox.Top = 190
$MotionBlurTextBox.Left = 190
$MotionBlurTextBox.Width = 50  # Half the original width
$MotionBlurTextBox.TextAlign = 'Left'
$MotionBlurTextBox.TabIndex = 13
$editGroupBox.Controls.Add($MotionBlurTextBox)

$ShakeScaleLabel = New-Object System.Windows.Forms.Label
$ShakeScaleLabel.Text = "Shake Scale"
$ShakeScaleLabel.Top = 190
$ShakeScaleLabel.Left = 300
$ShakeScaleLabel.Width = 100
$editGroupBox.Controls.Add($ShakeScaleLabel)

$ShakeScaleTextBox = New-Object System.Windows.Forms.TextBox
$ShakeScaleTextBox.Name = "ShakeScaleTextBox"
$ShakeScaleTextBox.Top = 190
$ShakeScaleTextBox.Left = 410
$ShakeScaleTextBox.Width = 50  # Half the original width
$ShakeScaleTextBox.TextAlign = 'Left'
$ShakeScaleTextBox.TabIndex = 14
$editGroupBox.Controls.Add($ShakeScaleTextBox)

$CameraSpringMovementLabel = New-Object System.Windows.Forms.Label
$CameraSpringMovementLabel.Text = "Camera Spring Movement"
$CameraSpringMovementLabel.Top = 220
$CameraSpringMovementLabel.Left = 30
$CameraSpringMovementLabel.Width = 150
$editGroupBox.Controls.Add($CameraSpringMovementLabel)

$CameraSpringMovementTextBox = New-Object System.Windows.Forms.TextBox
$CameraSpringMovementTextBox.Name = "CameraSpringMovementTextBox"
$CameraSpringMovementTextBox.Top = 220
$CameraSpringMovementTextBox.Left = 190
$CameraSpringMovementTextBox.Width = 50  # Half the original width
$CameraSpringMovementTextBox.TextAlign = 'Left'
$CameraSpringMovementTextBox.TabIndex = 15
$editGroupBox.Controls.Add($CameraSpringMovementTextBox)

$FilmGrainLabel = New-Object System.Windows.Forms.Label
$FilmGrainLabel.Text = "Film Grain"
$FilmGrainLabel.Top = 220
$FilmGrainLabel.Left = 300
$FilmGrainLabel.Width = 100
$editGroupBox.Controls.Add($FilmGrainLabel)

$FilmGrainTextBox = New-Object System.Windows.Forms.TextBox
$FilmGrainTextBox.Name = "FilmGrainTextBox"
$FilmGrainTextBox.Top = 220
$FilmGrainTextBox.Left = 410
$FilmGrainTextBox.Width = 50  # Half the original width
$FilmGrainTextBox.TextAlign = 'Left'
$FilmGrainTextBox.TabIndex = 16
$editGroupBox.Controls.Add($FilmGrainTextBox)

$GForceBoostZoomScaleLabel = New-Object System.Windows.Forms.Label
$GForceBoostZoomScaleLabel.Text = "G-Force Boost Zoom Scale"
$GForceBoostZoomScaleLabel.Top = 250
$GForceBoostZoomScaleLabel.Left = 30
$GForceBoostZoomScaleLabel.Width = 150
$editGroupBox.Controls.Add($GForceBoostZoomScaleLabel)

$GForceBoostZoomScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceBoostZoomScaleTextBox.Name = "GForceBoostZoomScaleTextBox"
$GForceBoostZoomScaleTextBox.Top = 250
$GForceBoostZoomScaleTextBox.Left = 190
$GForceBoostZoomScaleTextBox.Width = 50  # Half the original width
$GForceBoostZoomScaleTextBox.TextAlign = 'Left'
$GForceBoostZoomScaleTextBox.TabIndex = 17
$editGroupBox.Controls.Add($GForceBoostZoomScaleTextBox)

$GForceHeadBobScaleLabel = New-Object System.Windows.Forms.Label
$GForceHeadBobScaleLabel.Text = "G-Force Head Bob Scale"
$GForceHeadBobScaleLabel.Top = 250
$GForceHeadBobScaleLabel.Left = 260
$GForceHeadBobScaleLabel.Width = 150
$editGroupBox.Controls.Add($GForceHeadBobScaleLabel)

$GForceHeadBobScaleTextBox = New-Object System.Windows.Forms.TextBox
$GForceHeadBobScaleTextBox.Name = "GForceHeadBobScaleTextBox"
$GForceHeadBobScaleTextBox.Top = 250
$GForceHeadBobScaleTextBox.Left = 410
$GForceHeadBobScaleTextBox.Width = 50  # Half the original width
$GForceHeadBobScaleTextBox.TextAlign = 'Left'
$GForceHeadBobScaleTextBox.TabIndex = 18
$editGroupBox.Controls.Add($GForceHeadBobScaleTextBox)

# Update the state of the buttons after loading the XML content

$saveProfileButton = New-Object System.Windows.Forms.Button
$saveProfileButton.Name = "SaveProfileButton"
$saveProfileButton.Text = "Save Profile"
$saveProfileButton.Width = 120
$saveProfileButton.Height = 30
$saveProfileButton.Top = 295
$saveProfileButton.Left = 20
$saveProfileButton.TabIndex = 19
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
$saveButton.Top = 295
$saveButton.Left = 330
$saveButton.TabIndex = 20
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
            $AutoZoomNode.SetAttribute("value", $AutoZoomTextBox.Text)  # AUTOZOOM
        }
        $MotionBlurNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "MotionBlur" }
        if ($null -ne $MotionBlurNode) {
            $MotionBlurNode.SetAttribute("value", $MotionBlurTextBox.Text)  # MOTIONBLUR
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
            $FilmGrainNode.SetAttribute("value", $FilmGrainTextBox.Text)  # FILM GRAIN
        }
        $GForceBoostZoomScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceBoostZoomScale" }
        if ($null -ne $GForceBoostZoomScaleNode) {
            $GForceBoostZoomScaleNode.SetAttribute("value", $GForceBoostZoomScaleTextBox.Text)  # GFORCEBOOSTZOOMSCALE
        }
        $GForceHeadBobScaleNode = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "GForceHeadBobScale" }
        if ($null -ne $GForceHeadBobScaleNode) {
            $GForceHeadBobScaleNode.SetAttribute("value", $GForceHeadBobScaleTextBox.Text)  # GFORCEHEADBOBSCALE
        }
        try {
            $script:xmlContent.Save($script:xmlPath)
            [System.Windows.Forms.MessageBox]::Show("Values saved successfully!")
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
        $script:xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
            #$script:dataTable.Columns.Add($_.Name) | Out-Null                              #investigate why this says column already exists
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
        #$fileTextBox.Text = $xmlPath
        #$fileTextBox.Visible = $true
        Update-ButtonState

        # Populate the input boxes with the first row values
        $script:xmlContent = [xml](Get-Content $script:xmlPath)
        if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {


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
$closeButton.TabIndex = 21
$closeButton.Add_Click({
    $form.Close()
})


$fovTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$widthTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$heightTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$headtrackerEnabledComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$HeadtrackingSourceComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$chromaticAberrationTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$AutoZoomTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$MotionBlurTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$ShakeScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$CameraSpringMovementTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$FilmGrainTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$GForceBoostZoomScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$GForceHeadBobScaleTextBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$saveButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$saveProfileButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$loadFromProfileButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$importButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$deleteEACTempFilesButton.add_MouseHover({ $ShowHelp.Invoke($_) })
$hostsFileUpdateButton.add_MouseHover({ $ShowHelp.Invoke($_) })

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
        "chromaticAberrationTextBox" {$tip = "Chromatic Aberration value"}
        "AutoZoomTextBox" {$tip = "Auto Zoom on selected target 0/1"}
        "MotionBlurTextBox" {$tip = "Motion Blur value"}
        "ShakeScaleTextBox" {$tip = "Shake Scale value"}
        "CameraSpringMovementTextBox" {$tip = "Camera Spring Movement value"}
        "FilmGrainTextBox" {$tip = "Film Grain value"}
        "GForceBoostZoomScaleTextBox" {$tip = "G-Force Boost Zoom Scale value"}
        "GForceHeadBobScaleTextBox" {$tip = "G-Force Head Bob Scale value"}
        "saveButton" {$tip = "Save settings to the game"}
        "saveProfileButton" {$tip = "Save settings to the profile"}
        "loadFromProfileButton" {$tip = "Load settings from the VRSE-AE profile"}
        "importButton" {$tip = "Import settings from the game"}
        "deleteEACTempFilesButton" {$tip = "Delete EAC TempFiles"}
        "hostsFileUpdateButton" {$tip = "Update hosts file for EAC Bypass"}
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
    } else {
        $statusBar.Text = "attributes.xml file not found in the 'default' profile folder."
        #[System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")
    }
} else {
    $statusBar.Text = "Star Citizen not found."
    [System.Windows.Forms.MessageBox]::Show("Star Citizen not found.")
}

$form.Controls.Add($editGroupBox)

$form.ShowDialog()