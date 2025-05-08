
@echo off

:: Specify the PowerShell script to run
set "PowerShellScript=starcitizen_xml_editor.ps1"

:: Check for Administrator privileges
net session >nul 2>&1
IF %errorLevel%==0 (
    :: Launch the PowerShell script
    echo Running PowerShell script with Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PowerShellScript%"
)
IF %errorLevel% neq 0 (
    echo This script requires Administrator privileges, only to edit the host file.
    echo If you are not editing the host file this session, you can run the %PowerShellScript% script directly, with
    echo "powershell -ExecutionPolicy Bypass -file %PowerShellScript%"
    echo.
    echo Python3 is required only to run the FOV and Resolution wizard. this is not mandatory.
    echo.
    pause
    :: exit /b
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PowerShellScript%"
    exit /b
)
