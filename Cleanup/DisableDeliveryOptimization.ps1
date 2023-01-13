#######
# DisableDeliveryOptimization.ps1
# 
# Turn off torrent-style Windows update seeding, known as "Delivery Optimization"
# See Archive folder for references or script to undo actions.
#
# Edited & tested 12/23/22 on Windows 10 Pro version 21H2, OS build 19044.2251
#######

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

<# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
} #>

Write-Output "Disable seeding of updates to other computers via Group Policies"
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
$Name = "DODownloadMode"
$Value = 0

# Check if Key exists. If Key exists, check if Key Value exists.
# SafeRegistryUpdateScript
If(!(Test-Path $RegistryPath)) {
    Write-Verbose "Creating new registry key and key value:n` $RegistryPath"
    New-Item -Path $RegistryPath -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
        -PropertyType DWORD -Force | Out-Null
} ElseIf (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue) {
    Write-Verbose "Updating existing registry key value:n` $RegistryPath"
    # See Note 2 for Set-ItemProperty usage info.
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force | Out-Null
} Else {
    Write-Verbose "Creating new value for existing registry key:n` $RegistryPath"
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
        -PropertyType DWORD -Force | Out-Null
}
# End SafeRegistryUpdateScript

$VerbosePreference = "SilentlyContinue"