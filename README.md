<p align="center">
  <a href="https://github.com/troubleNZ/SC-VRse/issues"><img src="https://img.shields.io/github/issues/troubleNZ/SC-VRse"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/network/members"><img src="https://img.shields.io/github/forks/troubleNZ/SC-VRse"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/stargazers"><img src="https://img.shields.io/github/stars/troubleNZ/SC-VRse?color=white"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/blob/main/LICENSE"><img src="https://img.shields.io/github/license/troubleNZ/SC-VRse?color=black"/></a>
</p>

# SC-VRse
## VRse-AE (Attribute Editor)

### Easy Virtual Reality configuration manager for Star Citizen (Live PU).

Get help with VR in Star Citizen at  
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

new feature: Keybinds search and view

### Screenshot
![](https://github.com/troubleNZ/SC-VRse/blob/main/screenshot.jpg)


### How to use this script

Download the release on the right hand side - >
Unzip to a folder.

Run the bat file StarCitizenVRSetUp.bat or run powershell as below

` powershell.exe -ExecutionPolicy Bypass -File "Path\To\starcitizen_xml_editor.ps1"`

### Then what?
The tool should automatically detect your Star Citizen Live Install, and populate the fields with the current values from the game.
You can enable and disable Easy Anticheat 'easily', and Toggle VR on with 1 button.

Many settings that a VR Citizen might want exposed are available to configure, from Filmgrain and Motion Blur, to Head Bob and Autozoom

Included is a Field of View (FOV) Wizard , to pick the optimal FOV for your chosen HMD resolution.

Also find the handy Keybinds viewer under the Actions Menu, where you can easily see all your controller buttons and any settings that have changed from the defaults.

### current issues

- no major issues reported

### future plans
- investigate the potential of editing the keybinds
- extensibility and exposing more attributes


### Reverting EAC changes?
Just run the tool and click the Remove Bypass from Hosts file, you'll need administrator rights.
You can easily restore the EAC Cached files by running Verify Files in the Star Citizen Launcher

### What's Changed    

* 0.3.0 by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/73
* 0.3.1 apply/save and minimize by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/74
* 0.3.2 keybinds panel split into tabs ActionMaps, Devices and Options by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/75
* 0.3.3 by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/76
* 0.3.4 by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/81
* 0.3.5 Invictus Blue and Yellow dark mode by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/82
* 0.3.6 by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/84
* 0.3.7 by @troubleNZ in https://github.com/troubleNZ/SC-VRse/pull/86


**Full Changelog**: https://github.com/troubleNZ/SC-VRse/compare/v0.2.2...v0.3.4