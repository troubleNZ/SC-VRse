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
Chachi_Sanchez's VRse Discord
https://discord.gg/g2jn2vzju3

  

### Description

###### _What does this script do then?_

This tool is a work in progress, and intended as a one stop shop Powertool for managing your Star Citizen VR configuration focused on integrating the new Experimental VR Settings introduced in alpha 4.5 and updated for alpha 4.6.

- Easily configure your game for VR HeadTracking, Theater Mode, Mirror Mode, etc.

- Import the screen settings from the Star Citizen LIVE or PTU build, exposing settings like FOV/Resolution etc

- Save user profile configurations as json files, enabling quick restoring of settings

- Configure your FOV, Height x Width, whether Headtracking is toggled on, and what the Tracking Source is, all without loading into the game.

- expose many configurable settings directly from this tool

- Save some time and preload your VR configuration, or switch back to pancake mode at the push of a button.
  
- new feature: Keybinds search and view
  (to help you look up, remember or visualize your rebound buttons)

  

### Screenshot

![](https://github.com/troubleNZ/SC-VRse/blob/main/screenshot.jpg)

  
  

### How to use this script

  

Download the release on the right hand side - >

Unzip to a folder.
  
` powershell.exe -ExecutionPolicy Bypass -File "Path\To\starcitizen_powertool.ps1"`

  or "open with" the starcitizen_powertool.ps1 file with powershell.exe

### Then what?

The tool should automatically detect your Star Citizen Live Install, and populate the fields with the current values from the game.

You can enable and disable Easy Anticheat 'easily', and Toggle VR on with 1 button.

  

Many settings that a VR Citizen might want exposed are available to configure, from Filmgrain and Motion Blur, to Head Bob and Autozoom

The new Experimental VR Settings are all currently contained off a submenu, accessed via the button at the bottom of the screen.
This will likely be made the primary VR panel in a future iteration of this script.

Also find the handy Keybinds viewer under the Actions Menu, where you can easily see all your controller buttons and any settings that have changed from the defaults.

  

### current issues

  

- no major issues reported
- not all of the new experimental vr settings have been integrated yet. this is a work in progress, and i welcome git pushrequests to help keep the momentum up on script updates.
  

### future plans

- investigate the potential of editing the keybinds

- extensibility and exposing more attributes

### What's Changed    

* 0.5.0 by @troubleNZ in https://github.com/troubleNZ/SC-VR-Powertool

  

**Full Changelog**: https://github.com/troubleNZ/SC-VRse/compare/v0.2.2...v0.4.1

