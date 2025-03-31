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
![](https://media.discordapp.net/attachments/1037213809800122470/1356156608278822982/image.png?ex=67eb8ac3&is=67ea3943&hm=07578318cf0a708c4eaf68c7fe956532648f0ed1e0b16933df1e28a4b9de4274&=&format=webp&quality=lossless&width=1402&height=1951)


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
