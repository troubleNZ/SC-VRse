
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


$loadFromProfileButton = New-Object System.Windows.Forms.Button
$loadFromProfileButton.Name = "LoadFromProfileButton"
$loadFromProfileButton.Text = "Import settings from profile"
$loadFromProfileButton.Width = (200 * $script:ScaleMultiplier)
$loadFromProfileButton.Height = (30 * $script:ScaleMultiplier)
$loadFromProfileButton.Top = (30 * $script:ScaleMultiplier)
$loadFromProfileButton.Left = (20 * $script:ScaleMultiplier)
$loadFromProfileButton.TabIndex = 4
$loadFromProfileButton.Enabled = $script:loadedProfile                 #$false  # Initially disabled
$loadFromProfileButton.Visible = $script:loadedProfile
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

