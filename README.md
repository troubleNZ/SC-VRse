# SC-VRse
## VRse-AE (Attribute Editor)

VR fan project for
Chachi_Sanchez's VRse
https://discord.gg/g2jn2vzju3

### Description
What does this script do then?
- Easily perform the necessary steps to enable VR HeadTracking 

This includes:
- Add the bypass route to the Hosts file automatically.
- Purge any EAC files in the user's windows profile
- import the screen settings from the Star Citizen LIVE build, exposing settings like FOV/Resolution etc
- save user profile configurations as json files, enabling quick restoring of settings

Configure the Screen Size for VR use, configure your FOV, Height x Width, whether Headtracking is toggled on, and what the Tracking Source is, all without loading into the game.

Save some time and preload your VR configuration, or switch back to pancake mode at the push of a button.


### Screenshot
![](https://media.discordapp.net/attachments/1037213809800122470/1356156608278822982/image.png?ex=67eb8ac3&is=67ea3943&hm=07578318cf0a708c4eaf68c7fe956532648f0ed1e0b16933df1e28a4b9de4274&=&format=webp&quality=lossless&width=701&height=975)


### How to use this script

download the .ps1 somewhere and run it through powershell. simples.

` powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\star citizen xml editor.ps1"`

You can run it remotely directly from your standard powershell session. no admin rights are required.

just open the powershell (or the IDE) and run this:

` iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/troubleNZ/SC-VRse/refs/heads/main/starcitizen_xml_editor.ps1"))`


### Then what?
click the Open SC Folder button, and navigate to your main Star Citizen folder.
This will automatically find the attributes.xml file located in "LIVE\user\client\0\Profiles\default"

then you can IMPORT the values from the dataset, edit the values as necessary (FOV etc), and then click Export to save these values back to the XML for the game to read on next launch.

Once you have specified values in the input fields, you may want to save these as a profile configuration file which can be done by clicking on the File Menu and clicking Save Profile.

once you have a saved profile, you can Open it from the same File Menu. having 2 profiles, 1 for flat screen, and 1 for VR seems to be the most efficient method.


### current issues

- dark mode is broken sorry

### future plans
- visualize and interact with the mbk/hotas binding xml




