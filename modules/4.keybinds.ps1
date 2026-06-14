
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
$keybindDeviceComboBox.Items.AddRange(@("kb1", "gamepad", "js1", "js2", "js3", "js4"))
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
#$listKeybinds_Options.Scrollbars = [System.Windows.Forms.ScrollBars]::Both

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
    $ActionMapDefaults = "./builds/4.8/actionmaps.xml"
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

function Initialise_KeyBindTab {
    $script:ActionMapsxmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "$commonChildPath\ActionMaps.xml"
    if (-not (Test-Path $script:ActionMapsxmlPath)) {
        Write-Host "XML file not found at $script:ActionMapsxmlPath"
        exit
    }
    $script:BindsXML = [xml](Get-Content $script:ActionMapsxmlPath)
    $script:keyBindsProfiles = $script:BindsXML.ActionMaps.ActionProfiles

    Populate-KeyBindsViewer | Out-Null
}
Initialise_KeyBindTab
