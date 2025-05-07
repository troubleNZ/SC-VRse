
@echo off

:: Specify the PowerShell script to run
set "PowerShellScript=starcitizen_xml_editor.ps1"

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires Administrator privileges.
    echo Please run this script as an Administrator.
    echo This is only to write to the host file.
    echo If you are not editing the host file this session, you can run the %PowerShellScript% script directly, with
    echo "powershell -ExecutionPolicy Bypass -file %PowerShellScript%"
    pause
    exit /b
)

:: Specify the PowerShell script to run
set "PowerShellScript=starcitizen_xml_editor.ps1"

:: Launch the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%PowerShellScript%"