# SC-VRse
## VRse-AE (Attribute Editor)

VR fan project for
Chachi_Sanchez's VRse
https://discord.gg/g2jn2vzju3

### Description
Easily perform the necessary steps to enable VR HeadTracking 

This includes:
Enabling VORPX functionality (Vorpx not included) with Star Citizen by:
- setting the Route Table for bypassing EAC verification
- purging previously cached EAC files from temporary cache

Configure the Screen Size for VR use, configure your FOV, Height x Width, whether Headtracking is toggled on, and what the Tracking Source is, all without loading into the game.
save some time and preload your VR configuration, or switch back to pancake mode at the push of a button.


### Screenshot
![](https://media.discordapp.net/attachments/1037213809800122470/1347424143712194590/Screenshot_2025-03-07_172156.png?ex=67d1b4c5&is=67d06345&hm=f5bd4f0cc35705d2ed1805e3fbf9ffd5ac17aad3d851463ec1f7f692eb013730)


### How to use this script

download the .ps1 somewhere and run it through powershell. simples.

` powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\star citizen xml editor.ps1"`

You can run it remotely directly from your standard powershell session. no admin rights are required.

just open the powershell (or the IDE) and run this:

` iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/troubleNZ/SC-VRse/refs/heads/main/starcitizen_xml_editor.ps1"))`

### Fixed
- Import and Export now works

### current issues

- profile.json , used for autoloading a saved set of screen settings, isnt loading properly (ironically) 
- dark mode is broken sorry

### future plans
- visualize and interact with the mbk/hotas binding xml
