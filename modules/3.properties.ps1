

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
$applySaveButton.Top = (485 * $script:ScaleMultiplier)
$applySaveButton.Left = (250 * $script:ScaleMultiplier)
$applySaveButton.TabIndex = 22
$applySaveButton.Enabled = $false  # Initially disabled
#$applySaveButton.Add_Click({Save-SettingsToGame})
$applySaveButton.Add_Click({

    <# Validate that we have a loaded XML file
    if (-not $script:attributesXmlPath) { return }
    #>
    try {
            Save-SettingsToGame
        } catch {
            if ($debug) {Write-Host "[Error200] Error trying to Save-SettingsToGame: $($_.Exception.Message)" -ForegroundColor Red}
            return
        }
    if ($debug) { Write-Host "Applied changes to XML." }

    Open-XMLViewer($($script:profileArray.AttributesXmlPath))
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
$saveAndCloseButton.Top = (485 * $script:ScaleMultiplier)
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
$labelExpCategory_EscMenuSettings_EscMenuDistance.Text = "Menu Distance"
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
$labelExpCategory_EscMenuSettings_EscMenuYPos.Text = "Menu Height"
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
$labelExpCategory_EscMenuSettings_EscMenuScale.Text = "Menu Scale"
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
$textboxExpCategory_TheatreMode_Curvature.Text = "0"
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

$groupUIResolution = New-Object System.Windows.Forms.GroupBox
$groupUIResolution.Text = "UI Resolution Settings"
$groupUIResolution.Width = (250 * $script:ScaleMultiplier)
$groupUIResolution.Height = (85 * $script:ScaleMultiplier)
$groupUIResolution.Top = (340 * $script:ScaleMultiplier)         ## Adjusted the Top property to move the group box up
$groupUIResolution.Left = (5 * $script:ScaleMultiplier)
$groupUIResolution.Visible = $true
$tabVRSettings_Experimental.Controls.Add($groupUIResolution)

$labelExpCategory_UIResolution_Horizontal = New-Object System.Windows.Forms.Label      #r_StereoUIWidth
$labelExpCategory_UIResolution_Horizontal.Text = "Horizontal Resolution"
$labelExpCategory_UIResolution_Horizontal.Top = (25 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Horizontal.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Horizontal.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Horizontal.Width = (149 * $script:ScaleMultiplier)
$groupUIResolution.Controls.Add($labelExpCategory_UIResolution_Horizontal)

$textboxExpCategory_UIResolution_Horizontal = New-Object System.Windows.Forms.TextBox          #r_StereoUIWidth
$textboxExpCategory_UIResolution_Horizontal.Name = "StereoUIResX"
$textboxExpCategory_UIResolution_Horizontal.Top = (25 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Horizontal.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Horizontal.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Horizontal.TextAlign = 'Left'
$textboxExpCategory_UIResolution_Horizontal.AcceptsTab = $true
$textboxExpCategory_UIResolution_Horizontal.Text = "2560"
$textboxExpCategory_UIResolution_Horizontal.TabIndex = 6
$groupUIResolution.Controls.Add($textboxExpCategory_UIResolution_Horizontal)

$labelExpCategory_UIResolution_Vertical = New-Object System.Windows.Forms.Label          # r_StereoUIHeight
$labelExpCategory_UIResolution_Vertical.Text = "Vertical Resolution"
$labelExpCategory_UIResolution_Vertical.Top = (55 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Vertical.Height = (20 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Vertical.Left = (10 * $script:ScaleMultiplier)
$labelExpCategory_UIResolution_Vertical.Width = (149 * $script:ScaleMultiplier)
$groupUIResolution.Controls.Add($labelExpCategory_UIResolution_Vertical)

$textboxExpCategory_UIResolution_Vertical = New-Object System.Windows.Forms.TextBox          #r_StereoUIWidth
$textboxExpCategory_UIResolution_Vertical.Name = "StereoUIResY"
$textboxExpCategory_UIResolution_Vertical.Top = (55 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Vertical.Left = (160 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Vertical.Width = (40 * $script:ScaleMultiplier)
$textboxExpCategory_UIResolution_Vertical.TextAlign = 'Left'
$textboxExpCategory_UIResolution_Vertical.AcceptsTab = $true
$textboxExpCategory_UIResolution_Vertical.Text = "1440"
$textboxExpCategory_UIResolution_Vertical.TabIndex = 6
$groupUIResolution.Controls.Add($textboxExpCategory_UIResolution_Vertical)

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

$textboxExpCategory_UIResolution_Horizontal.Add_TextChanged({ Enable-SaveButtons })
$textboxExpCategory_UIResolution_Vertical.Add_TextChanged({ Enable-SaveButtons })

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

$textboxExpCategory_UIResolution_Horizontal.add_MouseHover({ $ShowHelp.Invoke($_) })
$textboxExpCategory_UIResolution_Vertical.add_MouseHover({ $ShowHelp.Invoke($_) })


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
        "StereoUIResX" {$tip = "Default UI Resolution is 2560 (in pixels). Increase the number to make UI smaller"}
        "StereoUIResY" {$tip = "Default is 1440 (in pixels). Increase the number to make UI smaller"}

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
    $script:xmlPath = Join-Path -Path $script:liveFolderPath -ChildPath "$commonChildPath\attributes.xml"
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
