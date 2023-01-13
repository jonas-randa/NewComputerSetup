#######
# DisableDefaultServices.ps1
# 
# Disables a number of default Windows Services.
# Disabled service cannot be run by an user or application
# See Archive folder for references or script to undo actions.
#
# Edited & tested by jranda 12/16/22 on Windows 10 Pro version 21H2, OS build 19044.2251
#######

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

# DefaultServicesScript: disables unwanted default services
$DefaultServices = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service

    #Intel Defaults # TO DO: TEST, run benchmark before and after.
    #"Intel(R) Capability Licensing Service TCP IP Interface" # Send License file over network
    # ----license service known to use 100% of CPU :/
    #"Intel(R) TPM Provisioning Service"
    #"Intel(R) Audio Service"
    # Also look into:
    #  Intel Content Protection HDCP Service- Internal GPU DRM for protected videos
    #  Intel Dynamic Tuning Service- Laptop dynamic gpu-cpu power sharing, which
    #      allegedly is redundant and is done at uefi level
    #  Intel HD Graphics Control Panel- internal GPU CPL service
    #  Intel Dynamic Application Loader Host Interface -- see jranda for project notes
)

ForEach ($Service in $DefaultServices) {
    $ServiceExists = Get-Service -Name $Service
    If ($ServiceExists) {
        Write-Verbose "Attempting to disable $Service"
        Stop-Service $ServiceExists
        $ServiceExists | Set-Service -StartupType Disabled
    } Else {
        Write-Verbose "$Service doesn't exist."
    }
}
# End DefaultServicesScript

$VerbosePreference = "SilentlyContinue"