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

it doesnt seem to save to the xml file.

#>


$scriptVersion = "0.0.6"
$currentLocation = Get-Location
$backupDir = Join-Path -Path $PSScriptRoot -ChildPath "VRSE AE Backup"
$global:profileArray = [System.Collections.ArrayList]@()
if (-not (Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

function Import-ProfileJson {
    $profileJsonPath = Join-Path -Path $currentLocation -ChildPath "profile.json"
    if (Test-Path -Path $profileJsonPath) {
            $profileContent = Get-Content -Path $profileJsonPath -ErrorAction Stop
            try {
                $global:profileArray = [System.Collections.ArrayList]($profileContent | ConvertFrom-Json -ErrorAction Stop)
            } catch {
                [System.Windows.Forms.MessageBox]::Show("The profile.json file is empty or malformed. Starting with an empty profile array.")
                $global:profileArray = [System.Collections.ArrayList]@()
            }
            if ($global:profileArray.Count -gt 0 -and $global:profileArray[0].Path) {
                $liveFolderPath = $global:profileArray[0].Path
                if (Test-Path -Path $liveFolderPath -PathType Container) {
                    [System.Windows.Forms.MessageBox]::Show("Found 'Live' folder at: $liveFolderPath")
                    $defaultProfilePath = Join-Path -Path $liveFolderPath -ChildPath "user\client\0\Profiles\default"
                    if (Test-Path -Path $defaultProfilePath -PathType Container) {
                        $attributesXmlPath = Join-Path -Path $defaultProfilePath -ChildPath "attributes.xml"
                        if (Test-Path -Path $attributesXmlPath) {
                            $destinationPath = Join-Path -Path $backupDir -ChildPath "attributes_backup.xml"
                            Copy-Item -Path $attributesXmlPath -Destination $destinationPath -Force
                            $global:xmlPath = $attributesXmlPath
                            try {
                                $global:xmlContent = [xml](Get-Content $global:xmlPath)
                                $panel.Controls.Clear()

                                $dataGridView = New-Object System.Windows.Forms.DataGridView
                                $dataGridView.Width = 500
                                $dataGridView.Height = 400
                                $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                                $global:dataTable = New-Object System.Data.DataTable

                                # Add columns to the DataTable
                                if ($xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                                    $xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                                        $global:dataTable.Columns.Add($_.Name) | Out-Null
                                    }

                                    # Add rows to the DataTable
                                    $xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                                        $row = $global:dataTable.NewRow()
                                        $_.Attributes | ForEach-Object {
                                            $row[$_.Name] = $_.Value
                                        }
                                        $global:dataTable.Rows.Add($row)
                                    }

                                    # Bind the DataTable to the DataGridView
                                    $dataGridView.DataSource = $global:dataTable

                                    $panel.Controls.Add($dataGridView)

                                    # Show the dataTableGroupBox and set its text to the XML path
                                    $dataTableGroupBox.Text = $xmlPath
                                    $dataTableGroupBox.Visible = $true
                                    Update-ButtonState

                                } else {
                                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                                }
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
                            }
                        } else {
                            [System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")
                        }
                    } else {
                        [System.Windows.Forms.MessageBox]::Show("'default' profile folder not found.")
                    }
                } else {
                    [System.Windows.Forms.MessageBox]::Show("'Live' folder not found in the selected directory.")
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Profile loaded successfully from profile.json, but 'Path' attribute is missing.")
            }
        } else {
        $global:profileArray = [System.Collections.ArrayList]@()
        [System.Windows.Forms.MessageBox]::Show("profile.json file not found. Starting with an empty profile array.")
    }
}

function Update-ButtonState {
    if ($null -ne $global:xmlContent) {
        $importButton.Enabled = $true
        $saveButton.Enabled = $true
    } else {
        $importButton.Enabled = $false
        $saveButton.Enabled = $false
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "VRse-AE (Attribute Editor "+$scriptVersion+")"
$form.Width = 600
$form.Height = 820
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(600,820)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false


$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Text = "Actions"
$groupBox.Width = 550
$groupBox.Height = 150
$groupBox.Top = 20
$groupBox.Left = 20

# add a menu toolbar with one option called "File"
$mainMenu = New-Object System.Windows.Forms.MainMenu
$fileMenuItem = New-Object System.Windows.Forms.MenuItem
$fileMenuItem.Text = "&File"    # The & character indicates the shortcut key
$mainMenu.MenuItems.Add($fileMenuItem)  # Add the File menu item to the main menu
#add an item Open Profile, which will load the profile.json file
$openProfileMenuItem = New-Object System.Windows.Forms.MenuItem 
$openProfileMenuItem.Text = "&Open Profile"
$openProfileMenuItem.Add_Click({
    Import-ProfileJson
})
$fileMenuItem.MenuItems.Add($openProfileMenuItem)  # Add the Open Profile menu item to the File menu

#add am item - Save Profile, which will save the profile.json file
$saveProfileMenuItem = New-Object System.Windows.Forms.MenuItem 
$saveProfileMenuItem.Text = "&Save Profile"
$saveProfileMenuItem.Add_Click({
    $profileJsonPath = Join-Path -Path (Get-Location) -ChildPath "profile.json"
    try {
        $global:profileArray | ConvertTo-Json | Set-Content -Path $profileJsonPath
        [System.Windows.Forms.MessageBox]::Show("Profile saved successfully to profile.json")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while saving the profile.json file: $_")
    }
})
$fileMenuItem.MenuItems.Add($saveProfileMenuItem)  # Add the Save Profile menu item to the File menu

# Add an item to the menu called "Open XML" and give it the same action as the $navigateButton
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
        $global:xmlPath = $openFileDialog.FileName
        if (Test-Path $global:xmlPath) {
            try {
                $global:xmlContent = [xml](Get-Content $global:xmlPath)
                $panel.Controls.Clear()

                $dataGridView = New-Object System.Windows.Forms.DataGridView
                $dataGridView.Width = 500
                $dataGridView.Height = 400
                $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                $dataTable = New-Object System.Data.DataTable

                # Add columns to the DataTable
                if ($xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                    $xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                        $dataTable.Columns.Add($_.Name) | Out-Null
                    }

                    # Add rows to the DataTable
                    $xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                        $row = $dataTable.NewRow()
                        $_.Attributes | ForEach-Object {
                            $row[$_.Name] = $_.Value
                        }
                        $dataTable.Rows.Add($row)
                        # Set the property on all rows so that the row is not editable
                        $dataGridView.ReadOnly = $true

                        # Disable double-click editing on cells
                        $dataGridView.CellDoubleClick.Add({
                            $_.Handled = $true
                        })
                    }

                    # Bind the DataTable to the DataGridView
                    $dataGridView.DataSource = $dataTable

                    $panel.Controls.Add($dataGridView)

                    # Show the dataTableGroupBox and set its text to the XML path
                    $dataTableGroupBox.Text = $xmlPath
                    $dataTableGroupBox.Visible = $true
                    Update-ButtonState

                    $global:xmlContent = [xml](Get-Content $global:xmlPath)
                    if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                        $fovTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[12].Attributes[1].value.ToString()
                        $heightTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[31].Attributes[1].value.ToString()
                        $widthTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[87].Attributes[1].Value.ToString()
                        $headtrackerEnabledComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[30].Attributes[1].Value.ToString())
                        #if ($global:xmlContent.DocumentElement.ChildNodes[0].Attributes["HeadtrackingSource"]) {
                            try {
                                $HeadtrackingSourceComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[29].Attributes[1].Value)
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                                $HeadtrackingSourceComboBox.SelectedIndex = 0
                            }
                        #} else {
                        #    $HeadtrackingSourceComboBox.SelectedIndex = 0
                        #}
                        <#$global:profileArray["FOV"] = $fovTextBox.Text
                        $global:profileArray["Height"] = $heightTextBox.Text
                        $global:profileArray["Width"] = $widthTextBox.Text
                        $global:profileArray["Headtracking"] = $headtrackerEnabledComboBox.SelectedIndex.ToString()
                        $global:profileArray["HeadtrackingSource"] = $HeadtrackingSourceComboBox.SelectedIndex.ToString() #>
                        $global:profileArray.Add([PSCustomObject]@{ FOV = $fovTextBox.Text; Height = $heightTextBox.Text; Width = $widthTextBox.Text; Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString(); HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString() }) | Out-Null
                    }

                    # Show the edit group box
                    $editGroupBox.Visible = $true
                    
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
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
$findLiveFolderButton.Text = "Find my Live Folder"
$findLiveFolderButton.Width = 120
$findLiveFolderButton.Height = 30
$findLiveFolderButton.Top = 30
$findLiveFolderButton.Left = 20
$findLiveFolderButton.TabIndex = 0
$findLiveFolderButton.Add_Click({
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    
    $folderBrowserDialog.Description = "Select the 'Star Citizen' folder containing 'Live'"
    if ($global:profileArray -and $global:profileArray.Path) {
        $folderBrowserDialog.SelectedPath = [System.IO.Path]::GetDirectoryName($global:profileArray.Path)
    }
    if ($folderBrowserDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowserDialog.SelectedPath
        $liveFolderPath = Join-Path -Path $selectedPath -ChildPath "Live"
        if (Test-Path -Path $liveFolderPath -PathType Container) {
            [System.Windows.Forms.MessageBox]::Show("Found 'Live' folder at: $liveFolderPath")
            $defaultProfilePath = Join-Path -Path $liveFolderPath -ChildPath "user\client\0\Profiles\default"
            if (Test-Path -Path $defaultProfilePath -PathType Container) {
                $attributesXmlPath = Join-Path -Path $defaultProfilePath -ChildPath "attributes.xml"
                if (Test-Path -Path $attributesXmlPath) {
                    $destinationPath = Join-Path -Path $backupDir -ChildPath "attributes_backup.xml"
                    Copy-Item -Path $attributesXmlPath -Destination $destinationPath -Force
                    $global:xmlPath = $attributesXmlPath
                    try {
                        $global:xmlContent = [xml](Get-Content $global:xmlPath)
                        $panel.Controls.Clear()

                        $dataGridView = New-Object System.Windows.Forms.DataGridView
                        $dataGridView.Width = 500
                        $dataGridView.Height = 400
                        $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                        $global:dataTable = New-Object System.Data.DataTable

                        # Add columns to the DataTable
                        if ($xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                            $xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                                $global:dataTable.Columns.Add($_.Name) | Out-Null
                            }

                            # Add rows to the DataTable
                            $xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                                $row = $global:dataTable.NewRow()
                                $_.Attributes | ForEach-Object {
                                    $row[$_.Name] = $_.Value
                                }
                                $global:dataTable.Rows.Add($row)
                            }

                            # Bind the DataTable to the DataGridView
                            $dataGridView.DataSource = $global:dataTable

                            $panel.Controls.Add($dataGridView)

                            # Show the dataTableGroupBox and set its text to the XML path
                            $dataTableGroupBox.Text = $xmlPath
                            $dataTableGroupBox.Visible = $true
                            Update-ButtonState

                            # Add the path to the $profileArray
                            $global:profileArray.Add([PSCustomObject]@{ Path = $liveFolderPath; DefaultProfilePath = $defaultProfilePath }) | Out-Null

                        } else {
                            [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
                    }
                } else {
                    [System.Windows.Forms.MessageBox]::Show("attributes.xml file not found in the 'default' profile folder.")
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("'default' profile folder not found.")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("'Live' folder not found in the selected directory.")
        }
    }
})
$groupBox.Controls.Add($findLiveFolderButton)

$littleLabel = New-Object System.Windows.Forms.Label
$littleLabel.Text = "Or"
$littleLabel.Top = 65
$littleLabel.Left = 70
$littleLabel.Width = 30
$littleLabel.Height = 20
$groupBox.Controls.Add($littleLabel)

$navigateButton = New-Object System.Windows.Forms.Button
$navigateButton.Text = "Navigate to File"
$navigateButton.Width = 120
$navigateButton.Height = 30
$navigateButton.Top = 90
$navigateButton.Left = 20
$navigateButton.TabIndex = 0
$xmlContent = $null

$global:xmlPath = $null
$navigateButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "XML Files (attributes.xml)|attributes.xml"
    $openFileDialog.Title = "Select the attributes.xml file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:xmlPath = $openFileDialog.FileName
        if (Test-Path $global:xmlPath) {
            try {
                $global:xmlContent = [xml](Get-Content $global:xmlPath)
                $panel.Controls.Clear()

                $dataGridView = New-Object System.Windows.Forms.DataGridView
                $dataGridView.Width = 500
                $dataGridView.Height = 400
                $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                $dataTable = New-Object System.Data.DataTable

                # Add columns to the DataTable
                if ($xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                    $xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                        $dataTable.Columns.Add($_.Name) | Out-Null
                    }

                    # Add rows to the DataTable
                    $xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                        $row = $dataTable.NewRow()
                        $_.Attributes | ForEach-Object {
                            $row[$_.Name] = $_.Value
                        }
                        $dataTable.Rows.Add($row)
                    }

                    # Bind the DataTable to the DataGridView
                    $dataGridView.DataSource = $dataTable

                    $panel.Controls.Add($dataGridView)

                    # Show the dataTableGroupBox and set its text to the XML path
                    $dataTableGroupBox.Text = $xmlPath
                    $dataTableGroupBox.Visible = $true
                    Update-ButtonState

                    # Populate the input boxes with the first row values
                    $global:xmlContent = [xml](Get-Content $global:xmlPath)
                    if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                        $fovTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[12].Attributes[1].value.ToString()
                        $heightTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[31].Attributes[1].value.ToString()
                        $widthTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[87].Attributes[1].Value.ToString()
                        $headtrackerEnabledComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[30].Attributes[1].Value.ToString())
                        #if ($global:xmlContent.DocumentElement.ChildNodes[0].Attributes["HeadtrackingSource"]) {
                            try {
                                $HeadtrackingSourceComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[29].Attributes[1].Value)
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                                $HeadtrackingSourceComboBox.SelectedIndex = 0
                            }
                        #} else {
                        #    $HeadtrackingSourceComboBox.SelectedIndex = 0
                        #}
                        <#$global:profileArray["FOV"] = $fovTextBox.Text
                        $global:profileArray["Height"] = $heightTextBox.Text
                        $global:profileArray["Width"] = $widthTextBox.Text
                        $global:profileArray["Headtracking"] = $headtrackerEnabledComboBox.SelectedIndex.ToString()
                        $global:profileArray["HeadtrackingSource"] = $HeadtrackingSourceComboBox.SelectedIndex.ToString() #>
                        $global:profileArray.Add([PSCustomObject]@{ FOV = $fovTextBox.Text; Height = $heightTextBox.Text; Width = $widthTextBox.Text; Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString(); HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString() }) | Out-Null

                    }

                    # Show the edit group box
                    $editGroupBox.Visible = $true
                    
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("XML file not found.")
        }
    }
})
$groupBox.Controls.Add($navigateButton)

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
    $cmd = "Start-Process cmd -ArgumentList '/c cd %systemroot%\System32\drivers\etc && echo #SC Bypass >> hosts && echo 127.0.0.1    modules-cdn.eac-prod.on.epicgames.com >> hosts && echo ::1    modules-cdn.eac-prod.on.epicgames.com >> hosts' -Verb RunAs"
    Invoke-Expression $cmd
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

$groupBox.Controls.Add($eacGroupBox)
$form.Controls.Add($groupBox)

$panel = New-Object System.Windows.Forms.Panel
$panel.Width = 550
$panel.Height = 400
$panel.Top = 200  # Adjusted the Top property to move the panel up
$panel.Left = 20

$form.Controls.Add($panel)

# Add a group box for the DataTable
$dataTableGroupBox = New-Object System.Windows.Forms.GroupBox
$dataTableGroupBox.Top = 180  # Position it above the DataTable
$dataTableGroupBox.Left = 20
$dataTableGroupBox.Width = 550
$dataTableGroupBox.Height = 420  # Adjust height to fit the DataTable
$dataTableGroupBox.Visible = $false  # Initially hide the group box

$form.Controls.Add($dataTableGroupBox)

$editGroupBox = New-Object System.Windows.Forms.GroupBox
$editGroupBox.Text = "Edit VR View"
$editGroupBox.Width = 550
$editGroupBox.Height = 150
$editGroupBox.Top = 600
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

<#$HeadtrackingCheckBox = New-Object System.Windows.Forms.CheckBox
$HeadtrackingCheckBox.Text = "On/Off"
$HeadtrackingCheckBox.Top = 70
$HeadtrackingCheckBox.Left = 140
$HeadtrackingCheckBox.Width = 60
$HeadtrackingCheckBox.TabIndex = 6
$HeadtrackingCheckBox.Checked = $false
$editGroupBox.Controls.Add($HeadtrackingCheckBox)#>

$headtrackerEnabledComboBox = New-Object System.Windows.Forms.ComboBox
$headtrackerEnabledComboBox.Top = 70
$headtrackerEnabledComboBox.Left = 140
$headtrackerEnabledComboBox.Width = 100  # Adjusted width to fit the combo box
$headtrackerEnabledComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$headtrackerEnabledComboBox.Items.AddRange(@(0, 1, 2, 3))
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
$HeadtrackingSourceComboBox.Items.AddRange(@(0, 1, 2, 3))
$HeadtrackingSourceComboBox.TabIndex = 7
$HeadtrackingSourceComboBox.SelectedIndex = 0
$editGroupBox.Controls.Add($HeadtrackingSourceComboBox)


$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import from XML"
$importButton.Width = 120
$importButton.Height = 30
$importButton.Top = 115
$importButton.Left = 160
$importButton.TabIndex = 10

$importButton.Add_Click({
    try {
        $global:xmlContent = [xml](Get-Content $global:xmlPath)
        if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
            $fovTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[12].Attributes[1].value.ToString()
            $heightTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[31].Attributes[1].value.ToString()
            $widthTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[87].Attributes[1].Value.ToString()
            $headtrackerEnabledComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[30].Attributes[1].Value.ToString())
            #if ($global:xmlContent.DocumentElement.ChildNodes[0].Attributes["HeadtrackingSource"]) {
                try {
                    $HeadtrackingSourceComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[29].Attributes[1].Value)
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                    $HeadtrackingSourceComboBox.SelectedIndex = 0
                }
            #} else {
            #    $HeadtrackingSourceComboBox.SelectedIndex = 0
            #}
            <#$global:profileArray["FOV"] = $fovTextBox.Text
            $global:profileArray["Height"] = $heightTextBox.Text
            $global:profileArray["Width"] = $widthTextBox.Text
            $global:profileArray["Headtracking"] = $headtrackerEnabledComboBox.SelectedIndex.ToString()
            $global:profileArray["HeadtrackingSource"] = $HeadtrackingSourceComboBox.SelectedIndex.ToString() #>
            $global:profileArray.Add([PSCustomObject]@{ FOV = $fovTextBox.Text; Height = $heightTextBox.Text; Width = $widthTextBox.Text; Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString(); HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString() }) | Out-Null

        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
    }
})
# Initially disable the import and save buttons
$importButton.Enabled = $false
$editGroupBox.Controls.Add($importButton)

# Update the state of the buttons after loading the XML content
$openXmlMenuItem.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "XML Files (attributes.xml)|attributes.xml"
    $openFileDialog.Title = "Select the attributes.xml file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:xmlPath = $openFileDialog.FileName
        if (Test-Path $global:xmlPath) {
            try {
                $global:xmlContent = [xml](Get-Content $global:xmlPath)
                $panel.Controls.Clear()

                $dataGridView = New-Object System.Windows.Forms.DataGridView
                $dataGridView.Width = 500
                $dataGridView.Height = 400
                $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                $dataTable = New-Object System.Data.DataTable

                # Add columns to the DataTable
                if ($xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                    $xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                        $dataTable.Columns.Add($_.Name) | Out-Null
                    }

                    # Add rows to the DataTable
                    $xmlContent.DocumentElement.ChildNodes | ForEach-Object {
                        $row = $dataTable.NewRow()
                        $_.Attributes | ForEach-Object {
                            $row[$_.Name] = $_.Value
                        }
                        $dataTable.Rows.Add($row)
                    }

                    # Bind the DataTable to the DataGridView
                    $dataGridView.DataSource = $dataTable

                    $panel.Controls.Add($dataGridView)

                    # Show the dataTableGroupBox and set its text to the XML path
                    $dataTableGroupBox.Text = $xmlPath
                    $dataTableGroupBox.Visible = $true
                    Update-ButtonState

                    # Populate the input boxes with the first row values
                    $global:xmlContent = [xml](Get-Content $global:xmlPath)
                    if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                        $fovTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[12].Attributes[1].value.ToString()
                        $heightTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[31].Attributes[1].value.ToString()
                        $widthTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[87].Attributes[1].Value.ToString()
                        $headtrackerEnabledComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[30].Attributes[1].Value.ToString())
                        try {
                            $HeadtrackingSourceComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[29].Attributes[1].Value)
                        } catch {
                            [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                            $HeadtrackingSourceComboBox.SelectedIndex = 0
                        }
                        <#$global:profileArray["FOV"] = $fovTextBox.Text
                        $global:profileArray["Height"] = $heightTextBox.Text
                        $global:profileArray["Width"] = $widthTextBox.Text
                        $global:profileArray["Headtracking"] = $headtrackerEnabledComboBox.SelectedIndex.ToString()
                        $global:profileArray["HeadtrackingSource"] = $HeadtrackingSourceComboBox.SelectedIndex.ToString() #>

                        $global:profileArray.Add([PSCustomObject]@{ FOV = $fovTextBox.Text; Height = $heightTextBox.Text; Width = $widthTextBox.Text; Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString(); HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString() }) | Out-Null
                    }

                    # Show the edit group box
                    $editGroupBox.Visible = $true

                    # Update button state
                    Update-ButtonState
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No attributes found in the XML file.")
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $_")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("XML file not found.")
        }
    }
})
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Export to XML"
$saveButton.Width = 120
$saveButton.Height = 30
$saveButton.Top = 115
$saveButton.Left = 20
$saveButton.TabIndex = 8
$saveButton.Add_Click({
    try {
        $global:xmlContent.DocumentElement.ChildNodes | ForEach-Object {
            if ($_.Attributes["FOV"]) {
                $_.Attributes["FOV"].Value = $fovTextBox.Text
            }
            if ($_.Attributes["Height"]) {
                $_.Attributes["Height"].Value = $heightTextBox.Text
            }
            if ($_.Attributes["Width"]) {
                $_.Attributes["Width"].Value = $widthTextBox.Text
            }
            if ($_.Attributes["Headtracking"]) {
                $_.Attributes["Headtracking"].Value = $headtrackerEnabledComboBox.SelectedIndex.ToString()
            }
            if ($_.Attributes["HeadtrackingSource"]) {
                $_.Attributes["HeadtrackingSource"].Value = $HeadtrackingSourceComboBox.SelectedIndex.ToString()
            }
        }
        try {
            $global:xmlContent.Save($global:xmlPath)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while saving the XML file to $global:xmlPath: $_")
        }
            $global:xmlContent.Save($global:xmlPath)
            [System.Windows.Forms.MessageBox]::Show("Values saved successfully!")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to save the XML file: $_")
        }

        # Refresh and update the dataTable with the new data
        $global:dataTable.Clear()
        $global:xmlContent.DocumentElement.ChildNodes | ForEach-Object {
            $row = $global:dataTable.NewRow()
            $_.Attributes | ForEach-Object {
                $row[$_.Name] = $_.Value
            }
            $global:dataTable.Rows.Add($row)
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
$closeButton.TabIndex = 9
$closeButton.Add_Click({
    $form.Close()
})


$form.Controls.Add($editGroupBox)

$form.ShowDialog()
