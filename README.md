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

Configure the Screen Size for VR use, configure your FOV, Height x Width, whether Headtracking is toggled on, and what the Tracking Source is, all without loading the game, or even while in game open the XML file remotely with this tool.

I'll expose more options soon. i think a fullscreen toggle would be useful.


### Screenshot
![](https://cdn.discordapp.com/attachments/1037213809800122470/1354246552339615816/Screenshot_2.png?ex=67e497e2&is=67e34662&hm=21738fd50692c3050fa7f636262c77fe206853b1e119ea27f37eb8a88254c3fc&)


### How to use this script

download the .ps1 somewhere and run it through powershell. simples.

` powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\star citizen xml editor.ps1"`

You can run it remotely directly from your standard powershell session. no admin rights are required.

just open the powershell (or the IDE) and run this:

` iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/troubleNZ/SC-VRse/refs/heads/main/starcitizen_xml_editor.ps1"))`

### Fixed
- Import and Export now works

### current issues

- profile.json (which is used for convenience remembering last location on script start) is broken.
- dark mode is broken sorry
