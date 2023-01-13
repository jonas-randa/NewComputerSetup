#######
# ModifyServices.ps1
# 
# HomeGroup services aren't run no YMCA devices; not relevant.
# Remote Assistance & Remote Desktop likewise.
# NOTE update to safe reg-updates before running. see UpdatePrivacySettings.ps1 for examples
#
#
# Edited & tested by jranda 12/16/22 on Windows 10 Pro version 21H2, OS build 19044.2251
#######

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

<# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
} #>

# Stop and disable Home Groups services
Write-Host "Stopping and disabling Home Groups services..."
Stop-Service "HomeGroupListener"
Set-Service "HomeGroupListener" -StartupType Disabled
Stop-Service "HomeGroupProvider"
Set-Service "HomeGroupProvider" -StartupType Disabled

# Disable Remote Assistance
# This is a Microsoft support feature which currently doesn't work anyways.
Write-Host "Disabling Remote Assistance..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

# Disable Remote Desktop
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1

$VerbosePreference = "SilentlyContinue"