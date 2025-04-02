<#▄█    █▄     ▄████████    ▄████████    ▄████████         ▄████████    ▄████████
 ███    ███   ███    ███   ███    ███   ███    ███        ███    ███   ███    ███
 ███    ███   ███    ███   ███    █▀    ███    █▀         ███    ███   ███    █▀
 ███    ███  ▄███▄▄▄▄██▀   ███         ▄███▄▄▄            ███    ███  ▄███▄▄▄
 ███    ███ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀          ▀███████████ ▀▀███▀▀▀
 ███    ███ ▀███████████          ███   ███    █▄         ███    ███   ███    █▄
 ███    ███   ███    ███    ▄█    ███   ███    ███        ███    ███   ███    ███
  ▀██████▀    ███    ███  ▄████████▀    ██████████        ███    █▀    ██████████
              ███    ███  The VRse Attribute Editor  Author: @troubleshooternz

current issues:

profile.json file is not being created correctly; 
values are not being saved or read back from the file on load.
#>

$scriptVersion = "0.1.8.1"                        # fixed headtracking toggle and source saving to xml
$currentLocation = (Get-Location).Path
$BackupFolderName = "VRSE AE Backup"
$ProfileJsonName = "profile.json"
$profileContent = @()
$script:profileArray = [System.Collections.ArrayList]@()

$debug = $false

$script:xmlPath = $null
$script:xmlContent = @()
$script:dataTable = $null
$script:xmlArray = @()
$script:dataGridView = @()

$niceDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$liveFolderPath = $null
$attributesXmlPath = $null
$fovTextBox = $null
$heightTextBox = $null
$widthTextBox = $null
$headtrackerEnabledComboBox = $null
$HeadtrackingSourceComboBox = $null
$dataTableGroupBox = $null
$editGroupBox = $null
$darkModeMenuItem = $null

# XML Nodes
$fovNode                = @()
$heightNode             = @()
$widthNode              = @()
$headtrackingNode       = @()
$headtrackingSourceNode = @()
[float]$chromaticAberrationNode = 0.0       # ChromaticAberration
$AutoZoomNode = @()                         # AutoZoomOnSelectedTarget
$MotionBlurNode = @()                      # MotionBlur
$ShakeScaleNode = @()                      # ShakeScale


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "VRse-AE (Attribute Editor "+$scriptVersion+")"
$form.Width = 620
$form.Height = 820
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(600,820)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false

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

function Import-ProfileJson {

    if (-not [string]::IsNullOrWhiteSpace($currentLocation)) {
        $profileJsonPath = Join-Path -Path ($currentLocation) -ChildPath $ProfileJsonName
    } else {
        throw "Error: Current location is invalid or not set."
    }

    if (Test-Path -Path $profileJsonPath) {
        try {
            $profileContent = Get-Content -Path $profileJsonPath -Raw -ErrorAction Stop
            if ($debug) { Write-Host "profileJsonPath: $profileJsonPath" -BackgroundColor White -ForegroundColor Black }
            $parsedJson = $profileContent | ConvertFrom-Json -ErrorAction Stop
            if ($parsedJson -is [System.Collections.ArrayList]) {
                $script:profileArray = [System.Collections.ArrayList]$parsedJson
                if ($debug) { Write-Host "Parsed JSON successfully loaded into profileArray." -BackgroundColor White -ForegroundColor Black }
            } elseif ($parsedJson -is [PSCustomObject]) {
                $script:profileArray = [System.Collections.ArrayList]@($parsedJson)
                if ($debug) { Write-Host "Parsed JSON object converted to ArrayList." -BackgroundColor White -ForegroundColor Black }
                $script:xmlPath = $script:profileArray.AttributesXmlPath
                Open-XMLViewer($script:xmlPath)

            } else {
                throw "Invalid JSON structure. Expected an array or object."
            }
        } catch {
            Write-Host "Error parsing JSON: $_" -ForegroundColor Red
            $script:profileArray = [System.Collections.ArrayList]@()
        }
    } else {
        Write-Host "profile.json file not found. Starting with an empty profile array." -ForegroundColor Yellow
        $script:profileArray = [System.Collections.ArrayList]@()
    }
}

function Update-ButtonState {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Button State Update", "Update the state of import and save buttons")) {
        if ($null -ne $script:xmlContent) {
            $importButton.Enabled = $true
            $saveButton.Enabled = $true
        } else {
            $importButton.Enabled = $false
            $saveButton.Enabled = $false
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
    param (
        [System.Windows.Forms.DataGridView]$script:dataGridView
    )
    if ($form.BackColor -eq [System.Drawing.Color]::FromArgb(45, 45, 48)) {
        Set-LightMode -control $form
        $darkModeMenuItem.Text = "Enable Dark Mode"
        $script:profileArray.Add([PSCustomObject]@{ DarkMode = $false }) | Out-Null
        # Set light mode for the dataTable
        $script:dataGridView.BackgroundColor = [System.Drawing.Color]::White
        $script:dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::White
        $script:dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
        $script:dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::White
        $script:dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
    } else {
        Set-DarkMode -control $form
        $darkModeMenuItem.Text = "Disable Dark Mode"
        $script:profileArray.Add([PSCustomObject]@{ DarkMode = $true }) | Out-Null
        # Set dark mode for the dataTable
        $script:dataGridView.BackgroundColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $script:dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $script:dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
        $script:dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $script:dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    }
}

function Set-ProfileArray {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    if ($PSCmdlet.ShouldProcess("Profile Array", "Set the profile array")) {
    #if (-not [string]::IsNullOrWhiteSpace($liveFolderPath) -and
    #    -not [string]::IsNullOrWhiteSpace($attributesXmlPath) -and
    #    -not [string]::IsNullOrWhiteSpace($fovTextBox.Text) -and
    #    -not [string]::IsNullOrWhiteSpace($heightTextBox.Text) -and
    #    -not [string]::IsNullOrWhiteSpace($widthTextBox.Text) -and
    #    $headtrackerEnabledComboBox.SelectedIndex -ne -1 -and
    #    $HeadtrackingSourceComboBox.SelectedIndex -ne -1) {

        $script:profileArray.Clear()  # Clear the existing profile array

        $script:profileArray.Add([PSCustomObject]@{
            Path = $liveFolderPath;
            AttributesXmlPath = $attributesXmlPath;
            FOV = $fovTextBox.Text;
            Height = $heightTextBox.Text;
            Width = $widthTextBox.Text;
            Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString();
            HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString();
            ChromaticAberration = $chromaticAberrationTextBox.Text;
            AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text;
            MotionBlur = $MotionBlurTextBox.Text;
            ShakeScale = $ShakeScaleTextBox.Text;
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

                if ($debug) {Write-Host "debug: try to Populate the input boxes with the first row values" -BackgroundColor White -ForegroundColor Black}
                Set-ProfileArray

                # Show the edit group box
                $editGroupBox.Visible = $true

            } else {
                if ($debug) {[System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")}
            }
        } catch {
            if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")}
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("XML file not found.")
    }
}



#add an item Open Profile, which will load the profile.json file
$openProfileMenuItem = New-Object System.Windows.Forms.MenuItem
$openProfileMenuItem.Text = "&Open Profile"
$openProfileMenuItem.Add_Click({
    Import-ProfileJson
})
$fileMenuItem.MenuItems.Add($openProfileMenuItem)  # Add the Open Profile menu item to the File menu

#$AutoLoadprofile = @()

#add am item - Save Profile, which will save the profile.json file
$saveProfileMenuItem = New-Object System.Windows.Forms.MenuItem
$saveProfileMenuItem.Text = "&Save Profile"
$saveProfileMenuItem.Add_Click({
    $profileJsonPath = Join-Path -Path ($currentLocation) -ChildPath "profile.json"
    try {
        if (-not $script:profileArray) {
            if ($debug) {Write-Host "debug: No Profile Array" -BackgroundColor White -ForegroundColor Black}
            $script:profileArray = [System.Collections.ArrayList]@()
        }
        if ($script:profileArray.Count -eq 0) {
            if ($debug) {Write-Host "debug: Empty array - Populating blank profile array" -BackgroundColor White -ForegroundColor Black}
            if ($script:profileArray.Add([PSCustomObject]@{
                Path = ""
                AttributesXmlPath = ""
                FOV = ""
                Height = ""
                Width = ""
                Headtracking = 0
                HeadtrackingSource = 0
                ChromaticAberration = ""
                AutoZoomOnSelectedTarget = ""
                MotionBlur = ""
                ShakeScale = ""
            })) {
                if ($debug) {Write-Host "debug: Profile Array populated" -BackgroundColor White -ForegroundColor Black}
            } else {
                if ($debug) {Write-Host "debug: Profile Array not populated" -BackgroundColor White -ForegroundColor Black}
            }
        }
        if ($debug) {Write-Host "debug: copy values to profile array" -BackgroundColor White -ForegroundColor Black}
        if ($debug) {Write-Host "debug: Path added to Profile Array " -BackgroundColor White -ForegroundColor Black}
        $script:profileArray.Path = $liveFolderPath.ToString()
        $script:profileArray.AttributesXmlPath = $attributesXmlPath.ToString()
        #$script:profileArray.Item("AttributesXmlPath") = $attributesXmlPath.ToString()
        $script:profileArray.FOV = $fovTextBox.Text
        $script:profileArray.Height = $heightTextBox.Text
        $script:profileArray.Width = $widthTextBox.Text
        $script:profileArray.Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString()
        $script:profileArray.HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString()
        $script:profileArray.ChromaticAberration = $chromaticAberrationTextBox.Text
        $script:profileArray.AutoZoomOnSelectedTarget = $AutoZoomTextBox.Text
        $script:profileArray.MotionBlur = $MotionBlurTextBox.Text
        $script:profileArray.ShakeScale = $ShakeScaleTextBox.Text

        $script:profileArray | ConvertTo-Json -Depth 10 | Out-File -FilePath $profileJsonPath -Force
        [System.Windows.Forms.MessageBox]::Show("Profile saved successfully to profile.json")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while saving the profile.json file: $_")
    }
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

                        if ($debug) {Write-Host "debug: try to Populate the input boxes with the first row values" -BackgroundColor White -ForegroundColor Black}


                        Set-ProfileArray

                    }

                    # Show the edit group box
                    $editGroupBox.Visible = $true

                    # Update button state
                    Update-ButtonState
                } else {
                    if ($debug) {[System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")}
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("XML file not found.")
        }
    }
})


$actionsMenuItem.MenuItems.Add($openXmlMenuItem)

$darkModeMenuItem = New-Object System.Windows.Forms.MenuItem
$darkModeMenuItem.Text = "Enable Dark Mode"
$darkModeMenuItem.Add_Click({
    Switch-DarkMode -dataGridView $script:dataGridView
})
$actionsMenuItem.MenuItems.Add($darkModeMenuItem)
$form.Menu = $mainMenu  # Set the main menu of the form to the created menu
#add an item - Exit, which will close the application
$exitMenuItem = New-Object System.Windows.Forms.MenuItem
$exitMenuItem.Text = "E&xit"
$exitMenuItem.Add_Click({
    $form.Close()
})
$fileMenuItem.MenuItems.Add($exitMenuItem)  # Add the Exit menu item to the File menu

# Create the Find Live Folder button
$findLiveFolderButton = New-Object System.Windows.Forms.Button
$findLiveFolderButton.Text = "Open SC Folder"
$findLiveFolderButton.Width = 120
$findLiveFolderButton.Height = 30
$findLiveFolderButton.Top = 30
$findLiveFolderButton.Left = 20
$findLiveFolderButton.TabIndex = 0
$findLiveFolderButton.Add_Click({
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog

    $folderBrowserDialog.Description = "Select the 'Star Citizen' folder containing 'Live'"
    if ($script:profileArray -and ($null -ne $script:profileArray.Path)) {
        $folderBrowserDialog.SelectedPath = [System.IO.Path]::GetDirectoryName($script:profileArray.Path)
    }
    if ($folderBrowserDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowserDialog.SelectedPath
        $liveFolderPath = Join-Path -Path $selectedPath -ChildPath "Live"
        if (Test-Path -Path $liveFolderPath -PathType Container) {
            #[System.Windows.Forms.MessageBox]::Show("Found 'Live' folder at: $liveFolderPath")
            $defaultProfilePath = Join-Path -Path $liveFolderPath -ChildPath "user\client\0\Profiles\default"
            if (Test-Path -Path $defaultProfilePath -PathType Container) {
                $attributesXmlPath = Join-Path -Path $defaultProfilePath -ChildPath "attributes.xml"
                if (Test-Path -Path $attributesXmlPath) {
                        $backupDir = Join-Path -Path $PSScriptRoot -ChildPath $BackupFolderName
                        if (-not (Test-Path -Path $backupDir)) {
                            New-Item -ItemType Directory -Path $backupDir | Out-Null
                        }
                    $destinationPath = Join-Path -Path $backupDir -ChildPath "attributes_backup_$niceDate.xml"
                    Copy-Item -Path $attributesXmlPath -Destination $destinationPath -Force
                    $script:xmlPath = $attributesXmlPath
                    Open-XMLViewer($script:xmlPath)
                } else {
                    if ($debug) {[System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")}
                }
            } else {
                if ($debug) {[System.Windows.Forms.MessageBox]::Show("'default' profile folder not found.")}
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("'Live' folder not found in the selected directory.")
        }
    }
})
$ActionsGroupBox.Controls.Add($findLiveFolderButton)

$littleLabel = New-Object System.Windows.Forms.Label
$littleLabel.Text = "Or"
$littleLabel.Top = 65
$littleLabel.Left = 70
$littleLabel.Width = 30
$littleLabel.Height = 20
$littleLabel.Visible = $false
$ActionsGroupBox.Controls.Add($littleLabel)

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
$ActionsGroupBox.Controls.Add($navigateButton)

# Create the EAC Bypass group box
$eacGroupBox = New-Object System.Windows.Forms.GroupBox
$eacGroupBox.Text = "EAC Bypass"
$eacGroupBox.Width = 380
$eacGroupBox.Height = 100
$eacGroupBox.Top = 20
$eacGroupBox.Left = 160  # Position it to the right of the navigate button

# Create the Hosts File Update button
$hostsFileUpdateButton = New-Object System.Windows.Forms.Button
$hostsFileUpdateButton.Text = "Hosts File Update"
$hostsFileUpdateButton.Width = 160
$hostsFileUpdateButton.Height = 30
$hostsFileUpdateButton.Top = 30
$hostsFileUpdateButton.Left = 20
$hostsFileUpdateButton.TabIndex = 1
$hostsFileUpdateButton.Add_Click({
    $hostsFilePath = Join-Path -Path $env:SystemRoot -ChildPath "System32\drivers\etc\hosts"
    if (-not (Test-Path -Path $hostsFilePath)) {
        [System.Windows.Forms.MessageBox]::Show("Hosts file not found. Operation aborted.")
        return
    }

    $userConfirmation = [System.Windows.Forms.MessageBox]::Show("This will modify the hosts file. Do you want to proceed?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($userConfirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    try {
        Remove-Item -Path $eacTempPath\* -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while updating the hosts file: $_")
    }
})
$eacGroupBox.Controls.Add($hostsFileUpdateButton)

# Create the Delete AppData EAC TempFiles button
$deleteEACTempFilesButton = New-Object System.Windows.Forms.Button
$deleteEACTempFilesButton.Text = "Delete EAC TempFiles"
$deleteEACTempFilesButton.Width = 160
$deleteEACTempFilesButton.Height = 30
$deleteEACTempFilesButton.Top = 30
$deleteEACTempFilesButton.Left = 190  # Position it to the right of the Hosts File Update button
$deleteEACTempFilesButton.TabIndex = 2
$deleteEACTempFilesButton.Add_Click({
    $eacTempPath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\EasyAntiCheat"
    if (Test-Path -Path $eacTempPath -PathType Container) {
        Get-ChildItem -Path $eacTempPath | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
        [System.Windows.Forms.MessageBox]::Show("EAC TempFiles deleted successfully!")
    } else {
        [System.Windows.Forms.MessageBox]::Show("EasyAntiCheat directory not found.")
    }
})
$eacGroupBox.Controls.Add($deleteEACTempFilesButton)

$ActionsGroupBox.Controls.Add($eacGroupBox)
$form.Controls.Add($ActionsGroupBox)

$gridGroup = New-Object System.Windows.Forms.Panel
$gridGroup.Width = 550
$gridGroup.Height = 300
$gridGroup.Top = 200  # Adjusted the Top property to move the panel up
$gridGroup.Left = 20
#$gridGroup.Visible = $false

$form.Controls.Add($gridGroup)

# Add a group box for the DataTable
$dataTableGroupBox = New-Object System.Windows.Forms.GroupBox
$dataTableGroupBox.Top = 180  # Position it above the DataTable
$dataTableGroupBox.Left = 20
$dataTableGroupBox.Width = 550
$dataTableGroupBox.Height = 220  # Adjust height to fit the DataTable
$dataTableGroupBox.Visible = $false  # Initially hide the group box

$form.Controls.Add($dataTableGroupBox)



$editGroupBox = New-Object System.Windows.Forms.GroupBox
$editGroupBox.Text = "Edit VR View"
$editGroupBox.Width = 550
$editGroupBox.Height = 250
$editGroupBox.Top = 500
$editGroupBox.Left = 20
$editGroupBox.Visible = $true

$fovLabel = New-Object System.Windows.Forms.Label
$fovLabel.Text = "FOV"
$fovLabel.Top = 30
$fovLabel.Left = 40
$fovLabel.Width = 30
$editGroupBox.Controls.Add($fovLabel)

$fovTextBox = New-Object System.Windows.Forms.TextBox
$fovTextBox.Top = 30
$fovTextBox.Left = 90
$fovTextBox.Width = 50  # Half the original width
$fovTextBox.TextAlign = 'Left'
$fovTextBox.AcceptsTab = $true
$fovTextBox.TabIndex = 3
$editGroupBox.Controls.Add($fovTextBox)

$widthLabel = New-Object System.Windows.Forms.Label
$widthLabel.Text = "Width"
$widthLabel.Top = 30
$widthLabel.Left = 180
$widthLabel.Width = 50
$widthLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($widthLabel)

$widthTextBox = New-Object System.Windows.Forms.TextBox
$widthTextBox.Top = 30
$widthTextBox.Left = 250
$widthTextBox.Width = 50  # Half the original width
$widthTextBox.TextAlign = 'Left'
$widthTextBox.TabIndex = 4
$editGroupBox.Controls.Add($widthTextBox)

$heightLabel = New-Object System.Windows.Forms.Label
$heightLabel.Text = "Height"
$heightLabel.Top = 30
$heightLabel.Left = 320
$heightLabel.Width = 50
$heightLabel.TextAlign = 'MiddleRight'
$editGroupBox.Controls.Add($heightLabel)

$heightTextBox = New-Object System.Windows.Forms.TextBox
$heightTextBox.Top = 30
$heightTextBox.Left = 400
$heightTextBox.Width = 50  # Half the original width
$heightTextBox.TextAlign = 'Left'
$heightTextBox.TabIndex = 5
$editGroupBox.Controls.Add($heightTextBox)

$HeadtrackingLabel = New-Object System.Windows.Forms.Label
$HeadtrackingLabel.Text = "Headtracking Enabled"
$HeadtrackingLabel.Top = 70
$HeadtrackingLabel.Left = 30
$HeadtrackingLabel.Width = 110
$editGroupBox.Controls.Add($HeadtrackingLabel)

$headtrackerEnabledComboBox = New-Object System.Windows.Forms.ComboBox
$headtrackerEnabledComboBox.Top = 70
$headtrackerEnabledComboBox.Left = 140
$headtrackerEnabledComboBox.Width = 100  # Adjusted width to fit the combo box
$headtrackerEnabledComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$headtrackerEnabledComboBox.Items.AddRange(@(0, 1))
$headtrackerEnabledComboBox.TabIndex = 6
$headtrackerEnabledComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($headtrackerEnabledComboBox)

$HeadtrackingSourceLabel = New-Object System.Windows.Forms.Label
$HeadtrackingSourceLabel.Text = "HeadtrackingSource"
$HeadtrackingSourceLabel.Top = 70
$HeadtrackingSourceLabel.Left = 260
$HeadtrackingSourceLabel.Width = 120
$editGroupBox.Controls.Add($HeadtrackingSourceLabel)

$HeadtrackingSourceComboBox = New-Object System.Windows.Forms.ComboBox
$HeadtrackingSourceComboBox.Top = 70
$HeadtrackingSourceComboBox.Left = 380
$HeadtrackingSourceComboBox.Width = 100  # Adjusted width to fit the combo box
$HeadtrackingSourceComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
#$HeadtrackingSourceComboBox.Items.AddRange(@(0, 1, 2, 3))

$HeadtrackingSourceComboBox.Items.Add("None")
$HeadtrackingSourceComboBox.Items.Add("TrackIR")
$HeadtrackingSourceComboBox.Items.Add("Faceware")
$HeadtrackingSourceComboBox.Items.Add("Tobii")

$HeadtrackingSourceComboBox.TabIndex = 7
$HeadtrackingSourceComboBox.SelectedItem = $HeadtrackingSourceComboBox.Items[0]  # Set the default selected item to the first one
$editGroupBox.Controls.Add($HeadtrackingSourceComboBox)






$chromaticAberrationLabel = New-Object System.Windows.Forms.Label
$chromaticAberrationLabel.Text = "Chromatic Aberration"
$chromaticAberrationLabel.Top = 120
$chromaticAberrationLabel.Left = 30
$chromaticAberrationLabel.Width = 120
$editGroupBox.Controls.Add($chromaticAberrationLabel)

$chromaticAberrationTextBox = New-Object System.Windows.Forms.TextBox
$chromaticAberrationTextBox.Top = 120
$chromaticAberrationTextBox.Left = 170
$chromaticAberrationTextBox.Width = 50  # Half the original width
$chromaticAberrationTextBox.TextAlign = 'Left'
$chromaticAberrationTextBox.TabIndex = 8
$editGroupBox.Controls.Add($chromaticAberrationTextBox)


$AutoZoomLabel = New-Object System.Windows.Forms.Label
$AutoZoomLabel.Text = "Auto Zoom"
$AutoZoomLabel.Top = 120
$AutoZoomLabel.Left = 260
$AutoZoomLabel.Width = 100
$editGroupBox.Controls.Add($AutoZoomLabel)

$AutoZoomTextBox = New-Object System.Windows.Forms.TextBox
$AutoZoomTextBox.Top = 120
$AutoZoomTextBox.Left = 360
$AutoZoomTextBox.Width = 50  # Half the original width
$AutoZoomTextBox.TextAlign = 'Left'
$AutoZoomTextBox.TabIndex = 9
$editGroupBox.Controls.Add($AutoZoomTextBox)

$MotionBlurLabel = New-Object System.Windows.Forms.Label
$MotionBlurLabel.Text = "Motion Blur"
$MotionBlurLabel.Top = 150
$MotionBlurLabel.Left = 70
$MotionBlurLabel.Width = 100
$editGroupBox.Controls.Add($MotionBlurLabel)

$MotionBlurTextBox = New-Object System.Windows.Forms.TextBox
$MotionBlurTextBox.Top = 150
$MotionBlurTextBox.Left = 170
$MotionBlurTextBox.Width = 50  # Half the original width
$MotionBlurTextBox.TextAlign = 'Left'
$MotionBlurTextBox.TabIndex = 10
$editGroupBox.Controls.Add($MotionBlurTextBox)

$ShakeScaleLabel = New-Object System.Windows.Forms.Label
$ShakeScaleLabel.Text = "Shake Scale"
$ShakeScaleLabel.Top = 150
$ShakeScaleLabel.Left = 260
$ShakeScaleLabel.Width = 100
$editGroupBox.Controls.Add($ShakeScaleLabel)

$ShakeScaleTextBox = New-Object System.Windows.Forms.TextBox
$ShakeScaleTextBox.Top = 150
$ShakeScaleTextBox.Left = 360
$ShakeScaleTextBox.Width = 50  # Half the original width
$ShakeScaleTextBox.TextAlign = 'Left'
$ShakeScaleTextBox.TabIndex = 11
$editGroupBox.Controls.Add($ShakeScaleTextBox)


$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import from XML"
$importButton.Width = 120
$importButton.Height = 30
$importButton.Top = 215
$importButton.Left = 60
$importButton.TabIndex = 13

$importButton.Add_Click({
    try {
        $script:xmlContent = [xml](Get-Content $script:xmlPath)
        if ($script:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {

            if ($script:xmlContent.Attributes -and $script:xmlContent.Attributes.Attr) {

                if ($debug) {[System.Windows.Forms.MessageBox]::Show("XML looks good.")}

                $fovTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $widthTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $heightTextBox.Text = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $headtrackingValue = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue


                if (-not $heightTextBox.Text) {
                    $heightTextBox.Text = ""
                }
                if (-not $widthTextBox.Text) {
                    $widthTextBox.Text = ""
                }

            } else {
                if ($debug) {[System.Windows.Forms.MessageBox]::Show("FOV attribute is missing in the XML file.")}
                $fovTextBox.Text = ""
                $heightTextBox.Text = ""
                $widthTextBox.Text = ""
            }
            if ([int]::TryParse($headtrackingValue, [ref]$null)) {
                $headtrackerEnabledComboBox.SelectedIndex = [int]$headtrackingValue
            } else {
                [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingEnabled. Setting to default (0).")
                $headtrackerEnabledComboBox.SelectedIndex = 0
            }

            if ($null -ne $script:xmlContent.Attributes.Attr) {
                try {
                    $headtrackerEnabledComboBox.SelectedIndex = ([int]::Parse($script:xmlContent.Attributes.Attr) | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value)
                } catch {
                $headtrackingValue = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                }
                if ([int]::TryParse($headtrackingValue, [ref]$null)) {
                    $headtrackerEnabledComboBox.SelectedIndex = [int]$headtrackingValue
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingEnabled. Setting to default (0).")
                    $headtrackerEnabledComboBox.SelectedIndex = 0
                }
                try {
                    $HeadtrackingSourceComboBox.SelectedIndex = ([int]::Parse($script:xmlContent.Attributes.Attr) | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value)
                } catch {
                $headtrackingSourceValue = $script:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
                    if ([int]::TryParse($headtrackingSourceValue, [ref]$null)) {
                        $HeadtrackingSourceComboBox.SelectedIndex = [int]$headtrackingSourceValue
                    } else {
                        [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                        $HeadtrackingSourceComboBox.SelectedIndex = 0
                    }
                }
            }
        }
    } catch {
        if ($debug) {[System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $($_.Exception.Message)")}
    }
})

# Initially disable the import and save buttons
$importButton.Enabled = $false
$editGroupBox.Controls.Add($importButton)

# Update the state of the buttons after loading the XML content

$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Export to XML"
$saveButton.Width = 120
$saveButton.Height = 30
$saveButton.Top = 215
$saveButton.Left = 330
$saveButton.TabIndex = 12
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
        if ($debug) {[System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")}
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
$closeButton.TabIndex = 14
$closeButton.Add_Click({
    $form.Close()
})


$form.Controls.Add($editGroupBox)

$form.ShowDialog()