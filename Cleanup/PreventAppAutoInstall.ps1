#######
# PreventAppAutoInstall.ps1
# 
# Windows Store and Windows Content Manager will install apps silently in
#  the background. Registries will be updated to prevent this.
#
# Tested 12/23/22 on Windows 10 Pro version 21H2, OS build 19044.2251
#######

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

<# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
} #>

###############################################################
# NoReinstallScript: Prevent apps from re-installing themselves.

# Add reference to KHU: all user registry hive.
New-PSDrive -PSProvider Registry -Name "HKU" -Root "HKEY_USERS"

$RegistryUpdates = @(
    # Prevent Windows Store from downloading new apps.
    @("HKLM:\Software\Policies\Microsoft\WindowsStore", "AutoDownload", 2),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", 0),
    # Prevent Suggested Apps from returning
    @("HKLM:\Software\Policies\Microsoft\Windows\CloudContent", "DisableWindowsConsumerFeatures", 1)
)

# ContentDeliveryManager Settings (CDM)
$CDMPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$CDMNames = @(
    "ContentDeliveryAllowed"
    "FeatureManagementEnabled"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SubscribedContent-314559Enabled"
    "SubscribedContent-338387Enabled"
    "SubscribedContent-338388Enabled"
    "SubscribedContent-338389Enabled"
    "SubscribedContent-338393Enabled"
    "SubscribedContentEnabled"
    "SystemPaneSuggestionsEnabled"
)
$CDMValue = 0
# Add ContentDeliveryManager keys to list of keys that need to be updated.
ForEach ($Name in $CDMNames) {
    $RegistryUpdates += @($CDMPath, $CDMNames, $CDMValue)
}

ForEach ($i in $RegistryUpdates) {
    $RegistryPath = $i[0] # Registry key path
    $Name = $i[1] # Name of registry key property, which doesn't have it's own path.
    $Value = $i[2] # Desired value of registry key property

    # Check if Key exists. If Key exists, check if Key Value exists.
    If(!(Test-Path $RegistryPath)) {
        Write-Verbose "Creating new registry key and key value:`n $RegistryPath"
        New-Item -Path $RegistryPath -Force | Out-Null
        New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
            -PropertyType DWORD -Force | Out-Null
    } ElseIf (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue) {
        Write-Verbose "Updating existing registry key value:`n $RegistryPath"
        # See Note 2 for Set-ItemProperty usage info.
        Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force | Out-Null
    } Else {
        Write-Verbose "Creating new value for existing registry key:`n $RegistryPath"
        New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
            -PropertyType DWORD -Force | Out-Null
    }
}
# End NoReinstallScript
############################################################

$VerbosePreference = "SilentlyContinue"