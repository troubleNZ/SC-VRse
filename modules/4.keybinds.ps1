$keybindSearchField = New-Object System.Windows.Forms.TextBox
$keybindSearchField.Name = "KeybindSearchField"
$keybindSearchField.Top = (8 * $script:ScaleMultiplier)
$keybindSearchField.Left = (410 * $script:ScaleMultiplier)
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
$keybindDeviceComboBox.Top = (8 * $script:ScaleMultiplier) #($keybindSearchField.Top + $keybindSearchField.Height + 10)
#$keybindDeviceComboBox.Anchor = "Top, Left"
$keybindDeviceComboBox.Left = (350 * $script:ScaleMultiplier)
#$keybindDeviceComboBox.Size = (60 * $script:ScaleMultiplier)
$keybindDeviceComboBox.Width = (60 * $script:ScaleMultiplier)
$keybindDeviceComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$keybindDeviceComboBox.Items.AddRange(@("","kb1", "gamepad", "js1", "js2", "js3", "js4"))
$keybindDeviceComboBox.SelectedIndex = 0
$KeybindDeviceComboBox.add_MouseHover({ $ShowHelp.Invoke($_) })
$tabVRSettings_Keybinds.Controls.Add($keybindDeviceComboBox)

# Handler function for device dropdown selection
function On-KeybindDeviceComboBox-Changed {
    param($sender, $eventArgs)
    $selectedDevice = $keybindDeviceComboBox.SelectedItem
    # Filter ActionMaps tree to only show actions with rebind/input starting with the selected device prefix
    $treeKeybinds_ActionMaps.BeginUpdate()
    $treeKeybinds_ActionMaps.Nodes.Clear()
    #$profileNode = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    $profileNode = $treeKeybinds_ActionMaps.Nodes.Add("Rebinds")    #Profile: "$($script:keyBindsProfiles.profileName)"
    foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
        $amNode = $profileNode.Nodes.Add("Category: $($actionmap.name)")
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
    $profileNode.Expand()
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

$radius = 5
$tabControl_Keybinds.Region = New-RoundedRegion -width $tabControl_Keybinds.Width -height $tabControl_Keybinds.Height -radius $radius

# --- Tab 1: ActionMaps ---
$tabKeybinds_ActionMaps = New-Object System.Windows.Forms.TabPage
$tabKeybinds_ActionMaps.Text = "ReBinds"
$tabKeybinds_ActionMaps.BackColor = [System.Drawing.Color]::FromArgb(204, 162, 105)
$tabKeybinds_ActionMaps.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)

$treeKeybinds_ActionMaps = New-Object Windows.Forms.TreeView
#$treeKeybinds_ActionMaps.Location = (10 * $script:ScaleMultiplier),(10 * $script:ScaleMultiplier)
#$treeKeybinds_ActionMaps.Location = "10,10"
$treeKeybinds_ActionMaps.Top = (0 * $script:ScaleMultiplier)
$treeKeybinds_ActionMaps.Left = (0 * $script:ScaleMultiplier)
#$treeKeybinds_ActionMaps.Font = New-Object System.Drawing.Font("Segoe UI", [math]::Round(10 * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$treeKeybinds_ActionMaps.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$treeKeybinds_ActionMaps.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$treeKeybinds_ActionMaps.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$treeKeybinds_ActionMaps.Size = New-Object Drawing.Size((350 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$treeKeybinds_ActionMaps.HideSelection = $false

$listKeybinds_ActionMaps = New-Object Windows.Forms.ListView
#$listKeybinds_ActionMaps.Location = "370,10"
$listKeybinds_ActionMaps.Top = (0 * $script:ScaleMultiplier)
$listKeybinds_ActionMaps.Left = (350 * $script:ScaleMultiplier)

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
$listKeybinds_Defaults.GridLines = $false
$listKeybinds_Defaults.Visible = $false

# --- Tab 2: Device ---

$tabKeybinds_Device = New-Object System.Windows.Forms.TabPage
$tabKeybinds_Device.Text = "Device Curves"

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
$listKeybinds_Device.GridLines = $false

# --- Tab 3: Options ---
$tabKeybinds_Options = New-Object System.Windows.Forms.TabPage
$tabKeybinds_Options.Text = "HID Properties"

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
$listKeybinds_Options.GridLines = $false
#$listKeybinds_Options.Scrollbars = [System.Windows.Forms.ScrollBars]::Both

# --- Tab 4: Defaults ---
$tabKeybinds_Defaults = New-Object System.Windows.Forms.TabPage
$tabKeybinds_Defaults.Text = "Default Binds"

$treeKeybinds_Defaults = New-Object Windows.Forms.TreeView
#$treeKeybinds_Defaults.Location = "10,10"
$treeKeybinds_Defaults.Top = (10 * $script:ScaleMultiplier)
$treeKeybinds_Defaults.Left = (10 * $script:ScaleMultiplier)
$treeKeybinds_Defaults.Size = New-Object Drawing.Size((350 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$treeKeybinds_Defaults.HideSelection = $false

$listKeybinds_Defaults_Binds = New-Object Windows.Forms.ListView
#$listKeybinds_Defaults_Bind.Location = "370,10"
$listKeybinds_Defaults_Binds.Top = (10 * $script:ScaleMultiplier)
$listKeybinds_Defaults_Binds.Left = (370 * $script:ScaleMultiplier)
$listKeybinds_Defaults_Binds.Size = New-Object Drawing.Size((220 * $script:ScaleMultiplier),(400 * $script:ScaleMultiplier))
$listKeybinds_Defaults_Binds.View = 'Details'
$listKeybinds_Defaults_Binds.FullRowSelect = $true
$listKeybinds_Defaults_Binds.GridLines = $false


# Add tabs to TabControl
$tabControl_Keybinds.TabPages.Add($tabKeybinds_ActionMaps)

$tabControl_Keybinds.TabPages.Add($tabKeybinds_Device)
$tabControl_Keybinds.TabPages.Add($tabKeybinds_Options)
$tabVRSettings_Keybinds.Controls.Add($tabControl_Keybinds)
$tabControl_Keybinds.TabPages.Add($tabKeybinds_Defaults)

# Load default action maps json
$ActionMapDefaults = $null
if (![string]::IsNullOrEmpty($PSScriptRoot)) {
    $ActionMapDefaults = Join-Path $PSScriptRoot -ChildPath "/defaultProfile.json"
} else {
    $ActionMapDefaults = "./defaultProfile.json"  # TODO eww need to fix this.
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
    
    $defaultsJson = Get-Content $ActionMapDefaults | ConvertFrom-Json
    # --- ActionMaps ---
    #$actionProfileNode = $treeKeybinds_ActionMaps.Nodes.Add("Profile: $($script:keyBindsProfiles.profileName)")
    $actionProfileNode = $treeKeybinds_ActionMaps.Nodes.Add("Rebinds")
    foreach ($actionmap in $script:keyBindsProfiles.actionmap) {
        $amNode = $actionProfileNode.Nodes.Add("Category: $($actionmap.name)")
        foreach ($action in $actionmap.action) {
            $aNode = $amNode.Nodes.Add("Action: $($action.name)")

            foreach ($rebind in $action.rebind) {
                $aNode.Nodes.Add("Rebound: $($rebind.input)") | Out-Null
            }
        }

        <#new json loop for reference later
        foreach ($actionmap in $defaultsJson.actionmap) {
            $amNode = $actionProfileNode.Nodes.Add("Category: $($actionmap["@name"])")

            foreach ($action in $actionmap.action) {
                $aNode = $amNode.Nodes.Add("Action: $($action["@name"])")

                foreach ($rebind in $action.rebind) {
                    if ($null -ne $rebind["@input"] -and $rebind["@input"].Trim() -ne "") {
                        $aNode.Nodes.Add("Rebound: $($rebind["@input]")") | Out-Null
                    }
                }
            }
        }

        #>
    }
    $actionProfileNode.Expand()
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
        <#if ($node.Text -like "Action: *") {
            $actionName = $node.Text.Substring(8)
             # Find the action in defaultProfile.json using already-loaded JSON data
            if ($script:defaultActionMapsJson) {
                $listKeybinds_ActionMaps.Items.Clear()
                Add-Column $listKeybinds_ActionMaps @("Default Input", "MultiTap")

                foreach ($actionmap in $script:defaultActionMapsJson.actionmap) {
                    $currentActionMapName = $actionmap."@name"

                    foreach ($action in $actionmap.action) {
                        $currentActionName = $action."@name"

                        if ($currentActionName -eq $actionName) {
                            # Add default bindings from "default" array
                            if ($action.default) {
                                foreach ($default in $action.default) {
                                    if ($null -ne $default."@input" -and 
                                        [string]::IsNullOrWhiteSpace($default."@input") -eq $false) {
                                        $item = $listKeybinds_ActionMaps.Items.Add($default."@input")
                                        if ($null -ne $item) {
                                            try {
                                                $multiTapValue = if ($default."@multiTap" -ne $null) {
                                                    $default."@multiTap"
                                                } else {""}
                                                $item.SubItems.Add($multiTapValue) | Out-Null
                                            } catch {
                                                if ($debug) {
                                                    Write-Host "Error adding MultiTap: $($_.Exception.Message)" -ForegroundColor Red
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            # Add rebind bindings from "rebind" array
                            foreach ($rebind in $action.rebind) {
                                if ($null -ne $rebind."@input" -and
                                    [string]::IsNullOrWhiteSpace($rebind."@input") -eq $false) {
                                    $item = $listKeybinds_ActionMaps.Items.Add($rebind."@input")
                                    if ($null -ne $item) {
                                        try {
                                            $multiTapValue = if ($rebind."@multiTap" -ne $null) {
                                                $rebind."@multiTap"
                                            } else {""}
                                            $item.SubItems.Add($multiTapValue) | Out-Null
                                        } catch {
                                            if ($debug) {
                                                Write-Host "Error adding MultiTap: $($_.Exception.Message)" -ForegroundColor Red
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }#>
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
    $deviceProfileNode.Expand()
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
        $optNode = $optionsProfileNode.Nodes.Add("$($opt.type) $($opt.instance) : $($opt.Product)")
        foreach ($child in $opt.ChildNodes) {
            $optNode.Nodes.Add("$($child.Name): $($child.OuterXml)") | Out-Null
        }
    }
    $optionsProfileNode.Expand()
    $treeKeybinds_Options.Add_AfterSelect({
        $listKeybinds_Options.Items.Clear()
        $node = $treeKeybinds_Options.SelectedNode
        if ($null -eq $node) { return }
        if ($node.Text -like "Order: *") {
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


function Populate-KeyBindsDefaults {

    # Clear all nodes and items for this tab
    #$treeKeybinds_Defaults.Nodes.Clear()
    #$listKeybinds_Defaults_Binds.Items.Clear()

    if (-not $script:defaultActionMapsJson) {
        Write-Host "Error: Default action maps JSON not loaded" -ForegroundColor Red
        return
    }

    # --- ActionMaps Defaults ---
    $actionProfileNode = $treeKeybinds_Defaults.Nodes.Add("Defaults")

    foreach ($actionmap in $script:defaultActionMapsJson.actionmap) {
        # Handle @ attributes for JSON-parsed data
        $actionMapName = $actionmap."@name"
        $amNode = $actionProfileNode.Nodes.Add("Category: $($actionMapName)")

        foreach ($action in $actionmap.action) {
            $actionName = $action."@name"
            $aNode = $amNode.Nodes.Add("Action: $($actionName)")

            # Add default bindings (from the "default" array in JSON)
            if ($action.default) {
                foreach ($default in $action.default) {
                    if ($null -ne $default."@input" -and [string]::IsNullOrWhiteSpace($default."@input") -eq $false) {
                        $aNode.Nodes.Add("Default Bind: $($default."@input")") | Out-Null

                        # Add MultiTap info if present
                        if ($null -ne $default."@multiTap") {
                            $multiTapValue = $default."@multiTap"
                            $aNode.Nodes.Add("MultiTap: $($multiTapValue)") | Out-Null
                        }
                    }
                }
            }

            # Add mapping defaults (from the "mapping" array in JSON)
            if ($action.mapping) {
                foreach ($mapping in $action.mapping) {
                    if ($null -ne $mapping."@input" -and [string]::IsNullOrWhiteSpace($mapping."@input") -eq $false) {
                        $aNode.Nodes.Add("Default: $($mapping."@input")") | Out-Null

                        # Add MultiTap info if present
                        if ($null -ne $mapping."@multiTap") {
                            $multiTapValue = $mapping."@multiTap"
                            $aNode.Nodes.Add("MultiTap: $($multiTapValue)") | Out-Null
                        }
                    }
                }
            }
        }
    }

    $actionProfileNode.Expand()

    # Add AfterSelect event handler to display selected action details in ListView
    $treeKeybinds_Defaults.Add_AfterSelect({
        $listKeybinds_Defaults_Binds.Items.Clear()
        $node = $treeKeybinds_Defaults.SelectedNode
        if ($null -eq $node) { return }

        # Check if a valid action node is selected
        if ($node.Text -like "Action: *") {
            $actionName = $node.Text.Substring(8)

            # Find the matching action in the JSON data
            foreach ($actionmap in $script:defaultActionMapsJson.actionmap) {
                $actionMapName = $actionmap["@name"]

                foreach ($action in $actionmap.action) {
                    $currentActionName = $action["@name"]

                    if ($currentActionName -eq $actionName) {
                        Add-Column $listKeybinds_Defaults_Binds @("Default Input", "MultiTap")

                        # Display default bindings
                        foreach ($default in $action.default) {
                            if ($null -ne $default["@input"] -and 
                                [string]::IsNullOrWhiteSpace($default["@input"]) -eq $false) {
                                $item = $listKeybinds_Defaults_Binds.Items.Add($default["@input"])
                                if ($null -ne $item) {
                                    # Handle null/empty multiTap values gracefully
                                    try {
                                        $multiTapValue = if ($default["@multiTap"] -ne $null) { 
                                            $default["@multiTap"] 
                                        } else { 
                                            "" 
                                        }
                                        $item.SubItems.Add($multiTapValue) | Out-Null
                                    } catch {
                                        if ($debug) {
                                            Write-Host "Error adding MultiTap: $($_.Exception.Message)" -ForegroundColor Red
                                        }
                                    }
                                }
                            }
                        }

                        # Display rebind defaults
                        foreach ($rebind in $action.rebind) {
                            if ($null -ne $rebind["@input"] -and 
                                [string]::IsNullOrWhiteSpace($rebind["@input"]) -eq $false) {
                                $item = $listKeybinds_Defaults_Binds.Items.Add($rebind["@input"])
                                if ($null -ne $item) {
                                    try {
                                        $multiTapValue = if ($rebind["@multiTap"] -ne $null) { 
                                            $rebind["@multiTap"] 
                                        } else { 
                                            "" 
                                        }
                                        $item.SubItems.Add($multiTapValue) | Out-Null
                                    } catch {
                                        if ($debug) {
                                            Write-Host "Error adding MultiTap: $($_.Exception.Message)" -ForegroundColor Red
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    })

    # Add controls to the tab page
    #$tabKeybinds_Defaults.Controls.Clear()
    $tabKeybinds_Defaults.Controls.Add($treeKeybinds_Defaults)
    $tabKeybinds_Defaults.Controls.Add($listKeybinds_Defaults_Binds)
}



function Initialise_KeyBindTab {

    # Load default action maps JSON first (before keyBindsProfiles is loaded)
    $ActionMapDefaults = $null
    if (![string]::IsNullOrEmpty($PSScriptRoot)) {
        $ActionMapDefaults = Join-Path $PSScriptRoot -ChildPath "/defaultProfile.json"
    } else {
        $ActionMapDefaults = "./defaultProfile.json"  # TODO eww need to fix this.
    }

    if (Test-Path $ActionMapDefaults) {
        if ($debug) {Write-Host "Loading default profile from: $ActionMapDefaults" -ForegroundColor Cyan}

        # Parse JSON ONCE at application load time
        try {
            $script:defaultActionMapsJson = Get-Content $ActionMapDefaults | ConvertFrom-Json
            if ($debug) {Write-Host "Successfully loaded default action maps JSON" -ForegroundColor Green}

            # Populate the Default Binds tab (data never changes, so do this once)
            Populate-KeyBindsDefaults | Out-Null
            if ($debug) {Write-Host "Default binds tab populated successfully" -ForegroundColor Green}

        } catch {
            Write-Host "Error loading default profile JSON: $($_.Exception.Message)" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "Warning: Default profile file not found at $ActionMapDefaults" -ForegroundColor Yellow
    }

    # Load the main action maps XML (original behavior)
    $script:ActionMapsxmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "$commonChildPath\ActionMaps.xml"
    if (-not (Test-Path $script:ActionMapsxmlPath)) {
        Write-Host "XML file not found at $script:ActionMapsxmlPath" -ForegroundColor Red
        exit
    }

    try {
        $script:BindsXML = [xml](Get-Content $script:ActionMapsxmlPath)
        $script:keyBindsProfiles = $script:BindsXML.ActionMaps.ActionProfiles

        # Populate the main keybinds viewer (user-modified bindings)
        Populate-KeyBindsViewer | Out-Null
        if ($debug) {Write-Host "Key bind tab initialized successfully" -ForegroundColor Green}

    } catch {
        Write-Host "Error loading ActionMaps XML: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
}

# Execute initialization
Initialise_KeyBindTab