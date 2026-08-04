<p align="center">
  <a href="https://github.com/troubleNZ/SC-VRse/issues"><img src="https://img.shields.io/github/issues/troubleNZ/SC-VRse"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/network/members"><img src="https://img.shields.io/github/forks/troubleNZ/SC-VRse"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/stargazers"><img src="https://img.shields.io/github/stars/troubleNZ/SC-VRse?color=white"/></a>
  <a href="https://github.com/troubleNZ/SC-VRse/blob/main/LICENSE"><img src="https://img.shields.io/github/license/troubleNZ/SC-VRse?color=black"/></a>
</p>

# SC/VR Powertool

### Easy Virtual Reality configuration manager for Star Citizen (Live PU).

  

Get help with VR in Star Citizen at  
Chachi_Sanchez's VRse Discord
https://discord.gg/g2jn2vzju3

  

### Description

###### _What does this script do then?_

This tool is a work in progress, and intended as a one stop shop Powertool for managing your Star Citizen VR configuration focused on integrating the new Experimental VR Settings introduced in alpha 4.5. 
As of Star Citizen Alpha 4.7, all relevant configurations have been exposed via this tool.

- Easily configure your game for VR HeadTracking, Theater Mode, Mirror Mode, etc.

- Import the screen settings from the Star Citizen LIVE or PTU build, exposing settings like FOV/Resolution etc

- Save user profile configurations as json files, enabling quick restoring of settings

- Configure your FOV, Height x Width, whether Headtracking is toggled on, and what the Tracking Source is, all without loading into the game.

- expose many configurable settings directly from this tool

- Save some time and preload your VR configuration, or switch back to pancake mode at the push of a button.
  
- new feature: Keybinds search and view
  (to help you look up, remember or visualize your rebound buttons)

  

### Screenshot

![](https://github.com/troubleNZ/SC-VRse/blob/main/screenshot.png)

  
  

### How to use this script


The easiest way is to create a folder anywhere you want it downloaded to.
then open that folder directory in powershell. start > run > powershell.exe to open the command line interface.

In the powershell CLI enter `cd <yourpath>` and when you are in the directory you created type:

```

irm https://raw.githubusercontent.com/troubleNZ/SC-VRse/refs/heads/main/install.ps1 | iex


```

copy and paste the whole line above, press enter and it will automatically download the files needed directly into the folder you specified.

now you can run the powershell script at the same command prompt with `.\starcitizen_powertool.ps1` and press enter.

you can also right-click on the same starcitizen_powertool.ps1 in explorer and open with powershell.exe. 
___

Alternatively, download the release on the right hand side, and unzip to a folder , 
you will probably have permission issues if you havent set up your powershell environment to allow untrusted code execution.
` powershell.exe -ExecutionPolicy Bypass -File ".\Path\To\starcitizen_powertool.ps1"`
will allow it to temporarily bypass the restrictions. i would not recommend this as the first option, if you are new to using powershell.

a better method is to open the folder you unzipped with VSCode and run the main starcitizen_powertool.ps1 script that will launch the rest of the modules.

### Then what?

The tool should automatically detect your Star Citizen Live Install, and populate the fields with the current values from the game.
if it does not detect the registry values, you can manually navigate to the Live/PTU/Hotfix folder via the toolbar.

Many settings that a VR Citizen might want exposed are available to configure, from Filmgrain and Motion Blur, to Head Bob and Autozoom

The new Experimental VR Settings are presented first, as they will be the most applicable to users. the legacy HMD settings are still available on the second tab.

Also find the handy Keybinds viewer under the Actions Menu, where you can easily see all your controller buttons and any settings that have changed from the defaults.
  

### current issues

  
- no major issues reported  

### future plans

- investigate the potential of editing the keybinds

- extensibility and exposing more attributes

### What's Changed    

**0.5.0** + Experimental VR settings introduced from alpha 4.5, ~ Remove EACBypass references 
**0.5.1** + Experimental VR settings introduced from alpha 4.6  

**0.5.8** + Experimental VR settings introduced from alpha 4.8  
**0.5.13** ~ bugfixes, darkmode memory, removed r_stereodebugdrawing and added crosshair opacity  

**Full Changelog**: https://github.com/troubleNZ/SC-VRse/compare/v0.2.2...v0.5.13

