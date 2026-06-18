
$splash = New-Object System.Windows.Forms.Form

$splash.Text = "SC/VR Powertools (Attribute Editor "+$scriptVersion+")"
$splash.Width = (640 * $script:ScaleMultiplier)
$splash.Height = (480 * $script:ScaleMultiplier)
$splash.StartPosition = 'CenterScreen'
$splash.Size = New-Object System.Drawing.Size($splash.Width,$splash.Height)
$splash.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$splash.MaximizeBox = $false
$splash.MinimizeBox = $true
$splash.Add_Shown({
    $splash.Activate()
    $splash.TopMost = $true
    $splash.TopMost = $false
})
#$splash.Icon = $scriptIcon
#$splash.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

$splashWarrantyBlurb = "Thanks for trying out this tool. Please understand that the user acknowledges and agrees that the use of the Software is at user's sole risk. The Software and related documentation are provided 'AS IS' and without any warranty of any kind and Seller EXPRESSLY DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE."

#$splashLabel
$splashLabel = New-Object System.Windows.Forms.Label
$splashLabel.Text = $splashWarrantyBlurb
$splashLabel.Top = (60 * $script:ScaleMultiplier)
$splashLabel.Left = (10 * $script:ScaleMultiplier)
$splashLabel.Height = (200 * $script:ScaleMultiplier)
$splashLabel.Width = ($splash.Width - $splashLabel.Left)
$splashLabel.Font = New-Object System.Drawing.Font($splashLabel.Font.FontFamily, [math]::Round($splashLabel.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$splashLabel.Size = New-Object System.Drawing.Size((550 * $script:ScaleMultiplier),(200 * $script:ScaleMultiplier))
$splash.Controls.Add($splashLabel)

$splashbuttonLoadMainForm = New-Object System.Windows.Forms.Button
$splashbuttonLoadMainForm.Text = "Thanks!"
#$splashbuttonLoadMainForm.Location = ((10 * $script:ScaleMultiplier),(310 * $script:ScaleMultiplier))
#$splashbuttonLoadMainForm.Location = "10,310"
$splashbuttonLoadMainForm.Top = (310 * $script:ScaleMultiplier)
#$splashbuttonLoadMainForm.Left = ((($splash.Width /2)-($splashbuttonLoadMainForm.Size /2))  * $script:ScaleMultiplier)
$splashbuttonLoadMainForm.Left = ($splash.Width /2)
$splashbuttonLoadMainForm.Font = New-Object System.Drawing.Font($splashbuttonLoadMainForm.Font.FontFamily, [math]::Round($splashbuttonLoadMainForm.Font.Size * $script:ScaleMultiplier), [System.Drawing.FontStyle]::Regular)
$splashbuttonLoadMainForm.Size = New-Object System.Drawing.Size((100 * $script:ScaleMultiplier), (30 * $script:ScaleMultiplier))
$splashbuttonLoadMainForm.Width = (80 * $script:ScaleMultiplier)
$splashbuttonLoadMainForm.TabIndex = 4
$splash.Controls.Add($splashbuttonLoadMainForm)

$splashbuttonLoadMainForm.Add_Click({
    $splash.Hide()
    $form.ShowDialog()
    })


Set-DefaultFont -control $form
#Set-DefaultFont -control $formHIDLookup

#Set-DefaultFont -control $groupExperimentalVRSettings
#Set-DefaultFont -control $keyBindsForm
Set-DefaultFont -control $splash
Switch-DarkMode

$splash.ShowDialog()