#######
# UpdatePrivacySettings.ps1
# 
# Increase privacy & prevent new users from being prompted with the Privacy
#  Experience Setup (All features of which allow data collection by MS).
# See Archive folder for references or script to undo actions.
#
# Edited 12/16/22
# Needs to be tested
#######

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

<# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
} #>

# Stop and disable Diagnostics Tracking Service
Write-Verbose "Stopping and disabling Diagnostics Tracking Service..."
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled


# Verify if a reference to HKU registry hive for all users exists:
# PowerShell as default only references HKCU and HKLM, but not HKU.
<#If (!(Get-PSDrive -PSProvider Registry -Name "HKU")) {
    New-PSDrive -PSProvider Registry -Name "HKU" -Root "HKEY_USERS"
}#> # For some reason, verification didn't work. Creating new one and will address later.
New-PSDrive -PSProvider Registry -Name "HKU" -Root "HKEY_USERS"

$RegistryUpdates = @(
    ###   Updates to HKLM are settings for local machine   ###
    # Disable Location Tracking for all users (AKA Microsoft.LocationSetting)
    @("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}",`
      "SensorPermissionState", 0),
    @("HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration", "Status", 0),
    
    # Disable Privacy Settings: FindMyDevice
    # Automatically disabled by turning off location settings above
    # @("HKLM:\Software\Microsoft\Settings\FindMyDevice", "LocationSyncEnabled", 0),

    # Set Default Telemetry Values : See Note 1 below for more info.
    @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry", 0),

    # Disable Privacy Settings Experience on new user login
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE", "DisablePrivacyExperience", 1),

    # TODO: wrap duplicates.
    ###   Updates to HKCU are settings for current users   ###
    ###  Updates to HKU are default settings for new users ###

    # Disable Bing Search in Start Menu
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 0),

    # Disable Feedback prompts
    @("HKCU:\Software\Microsoft\Siuf\Rules", "NumberOfSIUFInPeriod", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Siuf\Rules", "NumberOfSIUFInPeriod", 0),
    
    
    # Disable Cortana Data Collection
    @("HKCU:\Software\Microsoft\Personalization\Settings", "AcceptedPrivacyPolicy", 0), # Leave Cortana Search on
    @("HKU:\.DEFAULT\Software\Microsoft\Personalization\Settings", "AcceptedPrivacyPolicy", 0),
    @("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitTextCollection", 1),
    @("HKU:\.DEFAULT\Software\Microsoft\InputPersonalization", "RestrictImplicitTextCollection", 1),
    @("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitInkCollection", 1),
    @("HKU:\.DEFAULT\Software\Microsoft\InputPersonalization", "RestrictImplicitInkCollection", 1),
    @("HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore", "HarvestContacts", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\InputPersonalization\TrainedDataStore", "HarvestContacts", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search", "DeviceHistoryEnabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search", "DeviceHistoryEnabled", 0),

    # Disable Online Speech recognition (via Cortana dictation service)
    @("HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", 0),

    # Prevent CapabilityAccessManager from tracking eye movement, location, and app usabe
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "Deny", "String"),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "Deny", "String"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics", "Value", "Deny", "String"),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics", "Value", "Deny", "String"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\gazeInput", "Value", "Deny", "String"),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\gazeInput", "Value", "Deny", "String"),

    # Disable Diagnostic Data Tracking
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack", "ShowedToastAtLevel", 1),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack", "ShowedToastAtLevel", 1),

    # Disable 'Improve Inking & Typing' recognition
    @("HKCU:\Software\Microsoft\Input\TIPC", "Enabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Input\TIPC", "Enabled", 0),

    # Disable more diagnostic settings
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", 0),

    # Disable advertising ID
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", 0),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", 0)
)

ForEach ($i in $RegistryUpdates) {
    $RegistryPath = $i[0] # Registry key path
    $Name = $i[1] # Name of registry key property, which doesn't have it's own path.
    $Value = $i[2] # Desired value of registry key property
    $ValueType = $i[3]  # Optional key value type
    If (!$ValueType) { $ValueType = "DWORD" }  # Default key value type

    # Check if Key exists. If Key exists, check if Key Value exists.
    If(!(Test-Path $RegistryPath)) {
        Write-Verbose "Creating new registry key and key value:`n $RegistryPath"
        New-Item -Path $RegistryPath -Force | Out-Null
        New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
            -PropertyType $ValueType -Force | Out-Null
    } ElseIf (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue) {
        Write-Verbose "Updating existing registry key value:`n $RegistryPath"
        # See Note 2 for Set-ItemProperty usage info.
        Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force | Out-Null
    } Else {
        Write-Verbose "Creating new value for existing registry key:`n $RegistryPath"
        New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
            -PropertyType $ValueType -Force | Out-Null
    }
}

# Note 1:
#  Set Default Telemetry Value : System data uploaded by the Connected User Experience.
#   Telemetry levels are:
#    0 Security "Enterprise Only": No WER data.
#    1 Basic Telemetry: StageOne Log File Only. Use this if you are on non-Enterprise Windows.
#    2 Enhanced Telemetry: StageOne Log File Only
#    3 Full Telemetry: StageOne Log File, and Cab File when requested.
#   Levels 1 & 2 are noted by Windows to "degrade certain experiences".
#
#  A setting for "maximum allowed Intune telemetry valu"e can also be set at the following key:
#  @("HKLM:\Software\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 0),
#  All Telemetry values can be overwritten by a Group Policy.

# Note 2:
#  As of 12/22, Set-ItemProperty CAN work perfectly fine whether the key
#  value exists or not, as "Set" is both a setter & a constructor here.
#  However, it would not be unexpected for this to change in updates to
#  follow the getter-setter-constructor pattern, so I am future-proofing
#  this. Hopefully.

$VerbosePreference = "SilentlyContinue"