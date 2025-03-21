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

need to get it to save back to the xml file using the new values
#>

$scriptVersion = "0.1.1"                #milestone 1
$currentLocation = (Get-Location).Path
$BackupFolderName = "VRSE AE Backup"
$ProfileJsonPath = "profile.json"


$global:xmlPath = $null
$global:xmlContent = @()

$niceDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFileName = "attributes_backup_$niceDate.xml"

$profileContent = @()
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
$global:dataTable = $null
$global:xmlArray = @()


# XML Nodes
$fovNode                = @()
$heightNode             = @()
$widthNode              = @()
$headtrackingNode       = @()
$headtrackingSourceNode = @()



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


# Apply light mode to the form and its controls by default
Set-LightMode -control $form


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

function Import-ProfileJson {
    
    $profileJsonPath = Join-Path -Path ($currentLocation) -ChildPath $ProfileJsonPath

    if (Test-Path -Path $profileJsonPath) {
            $profileContent = Get-Content -Path $profileJsonPath -ErrorAction Stop
            
            try {
                $parsedJson = $profileContent | ConvertFrom-Json -ErrorAction Stop
                if ($parsedJson -is [System.Collections.ArrayList]) {
                    Write-Host "its an Array!" -BackgroundColor White -ForegroundColor Black
                    $global:profileArray = [System.Collections.ArrayList]$parsedJson
                } else {
                    throw "Invalid JSON structure. Expected an array."
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("The profile.json file is empty, malformed, or does not contain a valid array. Starting with an empty profile array.")
                $global:profileArray = [System.Collections.ArrayList]@()
            }
            
            if ($global:profileArray.Count -gt 0 -and $global:profileArray[0].Path) {
                $liveFolderPath = $global:profileArray[0].Path
                if (Test-Path -Path $liveFolderPath -PathType Container) {
                    #[System.Windows.Forms.MessageBox]::Show("Found 'Live' folder at: $liveFolderPath")
                    $defaultProfilePath = Join-Path -Path $liveFolderPath -ChildPath "user\client\0\Profiles\default"
                    if (Test-Path -Path $defaultProfilePath -PathType Container) {
                        $attributesXmlPath = Join-Path -Path $defaultProfilePath -ChildPath "attributes.xml"
                        if (Test-Path -Path $attributesXmlPath) {
                            $destinationPath = Join-Path -Path $backupDir -ChildPath $backupFileName
                            Copy-Item -Path $attributesXmlPath -Destination $destinationPath -Force

                            $global:xmlPath = $attributesXmlPath
                            Open-XMLViewer($global:xmlPath)         #refresh the xml viewer


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
        Write-Host "func:Import-ProfileJson : " + $global:profileArray -BackgroundColor White -ForegroundColor Black
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

function Set-DarkMode {
    param (
        [System.Windows.Forms.Control]$control
    )
    $control.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $control.ForeColor = [System.Drawing.Color]::White
    foreach ($child in $control.Controls) {
        Set-DarkMode -control $child
    }
}

function Set-LightMode {
    param (
        [System.Windows.Forms.Control]$control
    )
    $control.BackColor = [System.Drawing.Color]::White
    $control.ForeColor = [System.Drawing.Color]::Black
    foreach ($child in $control.Controls) {
        Set-LightMode -control $child
    }
}

function Switch-DarkMode {
    param (
        [System.Windows.Forms.DataGridView]$dataGridView
    )
    if ($form.BackColor -eq [System.Drawing.Color]::FromArgb(45, 45, 48)) {
        Set-LightMode -control $form
        $darkModeMenuItem.Text = "Enable Dark Mode"
        $global:profileArray.Add([PSCustomObject]@{ DarkMode = $false }) | Out-Null
        # Set light mode for the dataTable
        $dataGridView.BackgroundColor = [System.Drawing.Color]::White
        $dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::White
        $dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
        $dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::White
        $dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
    } else {
        Set-DarkMode -control $form
        $darkModeMenuItem.Text = "Disable Dark Mode"
        $global:profileArray.Add([PSCustomObject]@{ DarkMode = $true }) | Out-Null
        # Set dark mode for the dataTable
        $dataGridView.BackgroundColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $dataGridView.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $dataGridView.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
        $dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $dataGridView.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    }
}

function Set-ProfileArray {
    #if (-not [string]::IsNullOrWhiteSpace($liveFolderPath) -and
    #    -not [string]::IsNullOrWhiteSpace($attributesXmlPath) -and
    #    -not [string]::IsNullOrWhiteSpace($fovTextBox.Text) -and
    #    -not [string]::IsNullOrWhiteSpace($heightTextBox.Text) -and
    #    -not [string]::IsNullOrWhiteSpace($widthTextBox.Text) -and
    #    $headtrackerEnabledComboBox.SelectedIndex -ne -1 -and
    #    $HeadtrackingSourceComboBox.SelectedIndex -ne -1) {

        $global:profileArray.Clear()  # Clear the existing profile array
        
        $global:profileArray.Add([PSCustomObject]@{
            Path = $liveFolderPath;
            AttributesXmlPath = $attributesXmlPath;
            FOV = $fovTextBox.Text;
            Height = $heightTextBox.Text; 
            Width = $widthTextBox.Text; 
            Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString(); 
            HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString();
        }) | Out-Null
    #} else {
    #    Write-Host "Set-ProfileArray: One or more required fields are empty or invalid." -ForegroundColor Red
    #}

    Write-host "func:ProfileArray : " $global:profileArray -BackgroundColor White -ForegroundColor Black

}

function Open-XMLViewer {
    param (
        [string]$Path
    )

    if (Test-Path $Path) {
        try {
            $global:xmlContent = [xml](Get-Content $Path)
            $panel.Controls.Clear()

            $dataGridView = New-Object System.Windows.Forms.DataGridView
            $dataGridView.Width = 500
            $dataGridView.Height = 400
            $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

            $global:dataTable = New-Object System.Data.DataTable

            # Add columns to the DataTable
            if ($global:xmlContent.ChildNodes.Count -gt 0) {
                foreach ($node in $global:xmlContent.SelectNodes("//*")) { 
                    foreach ($attribute in $node.Attributes) {
                        if (-not $global:dataTable.Columns.Contains($attribute.Name)) {
                            $global:dataTable.Columns.Add($attribute.Name) | Out-Null   
                            #Write-Host "func:XMLViewer .Columns.Add : " + "$($attribute.Name): $($attribute.Value)" 
                            $global:xmlArray += $($attribute.Name) + " : " + "$($attribute.Value)"
                        }
                    }
                }

                # Add rows to the DataTable
                foreach ($node in $global:xmlContent.SelectNodes("//*")) { 
                    $row = $global:dataTable.NewRow()
                    foreach ($attribute in $node.Attributes) {
                        if ($global:dataTable.Columns.Contains($attribute.Name)) {
                            $row[$attribute.Name] = $attribute.Value
                        }
                    }
                    $global:dataTable.Rows.Add($row) | Out-Null
                    #Write-Host "func:XMLViewer .Rows.Add : " + "$($attribute.Name): $($attribute.Value)"                    
                }

                # Bind the DataTable to the DataGridView
                $dataGridView.DataSource = $global:dataTable

                $panel.Controls.Add($dataGridView)

                # Show the dataTableGroupBox and set its text to the XML path
                $dataTableGroupBox.Text = $Path
                $dataTableGroupBox.Visible = $true
                Update-ButtonState

                # Populate the input boxes with the first row values
                                        
                if ($null -ne $global:profileArray[0].FOV) {
                    $fovTextBox.Text = $global:profileArray[0].FOV
                }else {
                    $fovTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value
                }
                if ($null -ne $global:profileArray[0].Height) {
                    $heightTextBox.Text = $global:profileArray[0].Height
                    
                } else {
                    $heightTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value
                }
                if ($null -ne $global:profileArray[0].Width) {
                    $widthTextBox.Text = $global:profileArray[0].Width
                } else {
                    $widthTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value
                }
                if ($null -ne $global:profileArray[0].Headtracking) {
                    $headtrackerEnabledComboBox.SelectedIndex = $global:profileArray[0].Headtracking
                } else {
                    $headtrackerEnabledComboBox.SelectedIndex = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                }
                if ($null -ne $global:profileArray[0].HeadtrackingSource) {
                    $HeadtrackingSourceComboBox.SelectedIndex = $global:profileArray[0].HeadtrackingSource
                } else {
                    $HeadtrackingSourceComboBox.SelectedIndex = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
                }
                
                Write-Host "debug: try to Populate the input boxes with the first row values" -BackgroundColor White -ForegroundColor Black
                Set-ProfileArray

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



#add an item Open Profile, which will load the profile.json file
$openProfileMenuItem = New-Object System.Windows.Forms.MenuItem 
$openProfileMenuItem.Text = "&Open Profile"
$openProfileMenuItem.Add_Click({
    Import-ProfileJson
})
$fileMenuItem.MenuItems.Add($openProfileMenuItem)  # Add the Open Profile menu item to the File menu

$AutoLoadprofile = @()

#add am item - Save Profile, which will save the profile.json file
$saveProfileMenuItem = New-Object System.Windows.Forms.MenuItem 
$saveProfileMenuItem.Text = "&Save Profile"
$saveProfileMenuItem.Add_Click({
    $profileJsonPath = Join-Path -Path ($currentLocation) -ChildPath "profile.json"
    try {
        if ($global:profileArray.Count -gt 0) {
            $AutoLoadprofile = $global:profileArray[0]
            $AutoLoadprofile.FOV = $fovTextBox.Text
            $AutoLoadprofile.Height = $heightTextBox.Text
            $AutoLoadprofile.Width = $widthTextBox.Text
            $AutoLoadprofile.Headtracking = $headtrackerEnabledComboBox.SelectedIndex.ToString()
            $AutoLoadprofile.HeadtrackingSource = $HeadtrackingSourceComboBox.SelectedIndex.ToString()
            $AutoLoadprofile.AttributesXmlPath = $attributesXmlPath
            $AutoLoadprofile.Path = $liveFolderPath
        }
        
        $global:profileArray | ConvertTo-Json | Out-File -FilePath $profileJsonPath -Force
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
        $global:xmlPath = $openFileDialog.FileName
        if (Test-Path $global:xmlPath) {
            try {
                $global:xmlContent = [xml](Get-Content $global:xmlPath)
                $panel.Controls.Clear()

                $dataGridView = New-Object System.Windows.Forms.DataGridView
                $dataGridView.Width = 500
                $dataGridView.Height = 400
                $dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

                $global:dataTable = New-Object System.Data.DataTable

                # Add columns to the DataTable
                if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                    $global:xmlContent.DocumentElement.ChildNodes[0].Attributes | ForEach-Object {
                        $global:dataTable.Columns.Add($_.Name) | Out-Null
                    }

                    # Add rows to the DataTable
                    $global:xmlContent.DocumentElement.ChildNodes | ForEach-Object {
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

                    # Populate the input boxes with the first row values
                    $global:xmlContent = [xml](Get-Content $global:xmlPath)
                    if ($global:xmlContent.DocumentElement.ChildNodes.Count -gt 0) {
                        
                            
                        $fovTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value
                        $heightTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value
                        $widthTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value
                        $headtrackerEnabledComboBox.SelectedIndex = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                        $HeadtrackingSourceComboBox.SelectedIndex = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
    
                            Write-Host "debug: try to Populate the input boxes with the first row values" -BackgroundColor White -ForegroundColor Black
                                                    
                            ###     ################################# hard coded elements below for reference only. #################################
                                    #$fovTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[12].Attributes[1].value.ToString()
                                    #$heightTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[31].Attributes[1].value.ToString()
                                    #$widthTextBox.Text = $global:xmlContent.DocumentElement.ChildNodes[87].Attributes[1].Value.ToString()
                                    #$headtrackerEnabledComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[30].Attributes[1].Value.ToString())
                                    #try {
                                    #    $HeadtrackingSourceComboBox.SelectedIndex = [int]::Parse($global:xmlContent.DocumentElement.ChildNodes[29].Attributes[1].Value)
                                    #} catch {
                                    #    [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingSource. Setting to default (0).")
                                    #    $HeadtrackingSourceComboBox.SelectedIndex = 0
                                    #}
                            ###     ################################# hard coded elements above for reference only. #################################
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
    Switch-DarkMode -dataGridView $dataGridView
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
    if ($global:profileArray -and $global:profileArray.Path) {
        $folderBrowserDialog.SelectedPath = [System.IO.Path]::GetDirectoryName($global:profileArray.Path)
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
                    $global:xmlPath = $attributesXmlPath                
                    Open-XMLViewer($global:xmlPath)
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
$littleLabel.Visible = $false
$groupBox.Controls.Add($littleLabel)

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
        $global:xmlPath = $openFileDialog.FileName
        Open-XMLViewer($global:xmlPath)
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
                    
            if ($global:xmlContent.Attributes -and $global:xmlContent.Attributes.Attr) {
                $fovTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "FOV" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $widthTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Width" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $heightTextBox.Text = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "Height" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
                $headtrackingValue = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value -ErrorAction SilentlyContinue
            
                if (-not $heightTextBox.Text) {
                    $heightTextBox.Text = ""
                }
                if (-not $widthTextBox.Text) {
                    $widthTextBox.Text = ""
                }
                
            } else {
                [System.Windows.Forms.MessageBox]::Show("FOV attribute is missing in the XML file.")
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
            
            if ($null -ne $global:xmlContent.Attributes.Attr) {
                try {
                    $headtrackerEnabledComboBox.SelectedIndex = ([int]::Parse($global:xmlContent.Attributes.Attr) | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value)
                } catch {
                $headtrackingValue = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingToggle" } | Select-Object -ExpandProperty value
                }
                if ([int]::TryParse($headtrackingValue, [ref]$null)) {
                    $headtrackerEnabledComboBox.SelectedIndex = [int]$headtrackingValue
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Invalid value for HeadtrackingEnabled. Setting to default (0).")
                    $headtrackerEnabledComboBox.SelectedIndex = 0
                }
                try {
                    $HeadtrackingSourceComboBox.SelectedIndex = ([int]::Parse($global:xmlContent.Attributes.Attr) | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value)
                } catch {
                $headtrackingSourceValue = $global:xmlContent.Attributes.Attr | Where-Object { $_.name -eq "HeadtrackingSource" } | Select-Object -ExpandProperty value
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
        [System.Windows.Forms.MessageBox]::Show("An error occurred while loading the XML file: $($_.Exception.Message)")
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
$saveButton.Top = 115
$saveButton.Left = 20
$saveButton.TabIndex = 8
$saveButton.Add_Click({
    try {       
        if ($null -eq $global:xmlContent) {
            [System.Windows.Forms.MessageBox]::Show("XML content is null. Please load a valid XML file before saving.")
            return
        }

        $fovNode = $global:xmlContent.SelectSingleNode("//attribute[@name='FOV']")
        if ($null -ne $fovNode) {
            $fovNode.SetAttribute("value", $fovTextBox.Text)  # FOV
        }

        $heightNode = $global:xmlContent.SelectSingleNode("//attribute[@name='Height']")
        if ($null -ne $heightNode) {
            $heightNode.SetAttribute("value", $heightTextBox.Text)  # HEIGHT
        }

        $widthNode = $global:xmlContent.SelectSingleNode("//attribute[@name='Width']")
        if ($null -ne $widthNode) {
            $widthNode.SetAttribute("value", $widthTextBox.Text)  # WIDTH
        }

        $headtrackingNode = $global:xmlContent.SelectSingleNode("//attribute[@name='Headtracking']")
        if ($null -ne $headtrackingNode) {
            $headtrackingNode.SetAttribute("value", $headtrackerEnabledComboBox.SelectedIndex.ToString())  # HEADTRACKING
        }

        $headtrackingSourceNode = $global:xmlContent.SelectSingleNode("//attribute[@name='HeadtrackingSource']")
        if ($null -ne $headtrackingSourceNode) {
            $headtrackingSourceNode.SetAttribute("value", $HeadtrackingSourceComboBox.SelectedIndex.ToString())  # HEADTRACKINGSOURCE
        }
                  
        try {
            $global:xmlContent.Save($global:xmlPath)
            [System.Windows.Forms.MessageBox]::Show("Values saved successfully!")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while saving the XML file to $global:xmlPath: $_")
        }
            #$global:xmlContent.Save($global:xmlPath)
            
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