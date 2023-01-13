#######
# RemoveDefaultApps.ps1
# 
# Removes default apps and updates ContentDeliveryManager so that the apps
#  are not reinstalled.
# See Archive folder for references or script to undo actions.
# Additionally, do NOT remove Microsoft Store, as it is difficult to
#  reinstall without a reset.
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

# Get rid of MS 365 Store Version dependencies before removing
Get-AppxPackage -Name "Microsoft.Office.Desktop).Dependencies | Remove-AppxPackage"

# UninstallDefaultAppxPackagesScript
Write-Output "Uninstalling excess default applications."
$Apps = @(
    # Default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.Advertising.Xaml"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingTravel"
    "Microsoft.BingWeather"
    #"Microsoft.BioEnrollment"  # Windows Hello
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.FreshPaint"
    "Microsoft.GamingApp"
    "Microsoft.GamingServices"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MinecraftUWP"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    #"Microsoft.Windows.CloudExperienceHost"  # Failed. "Cannot be
    # uninstalled on a per-user basis. An administrator can attempt to remove
    #  the app from the Computer using Turn Windows Features on or off."
    #"Microsoft.Windows.ParentalControls"  # Failed ^
    #"Microsoft.Windows.PeopleExperienceHost"  # Failed ^
    "Microsoft.WindowsAlarms"
    ## "Microsoft.WindowsCalculator"  # Used by staff. Will later replace with dev build of Calculator with data collection turned off.
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsReadingList"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    #"Microsoft.XboxGameCallableUI"  # Failed w/ see admin error.
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.YourPhone"

    # Intel: TODO Test
    # "AppUp.IntelGraphicsExperience"

    # Other Default Apps
    "2FE3CB00.PicsArt-PhotoStudio"
    "46928bounde.EclipseManager"
    "4DF9E0F8.Netflix"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "6Wunderkinder.Wunderlist"
    "7EE7776C.LinkedInforWindows"
    "89006A2E.AutodeskSketchBook"
    "9E2F88E3.Twitter"
    "A278AB0D.DisneyMagicKingdoms"
    "A278AB0D.MarchofEmpires"
    "ActiproSoftwareLLC.562882FEEB491"
    "CAF9E577.Plex" # Code Writer from Actipro Software LLC
    "ClearChannelRadioDigital.iHeartRadio"
    "D52A8D61.FarmVille2CountryEscape"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "DolbyLaboratories.DolbyAccess"
    "DolbyLaboratories.DolbyAccess"
    "Drawboard.DrawboardPDF"
    "Facebook.Facebook"
    "Fitbit.FitbitCoach"
    "Flipboard.Flipboard"
    "GAMELOFTSA.Asphalt8Airborne"
    "KeeperSecurityInc.Keeper"
    "NORDCURRENT.COOKINGFEVER"
    "PandoraMediaInc.29680B314EFC2"
    "Playtika.CaesarsSlotsFreeCasino"
    "ShazamEntertainmentLtd.Shazam"
    "SlingTVLLC.SlingTV"
    #"SpotifyAB.SpotifyMusic"  # Used by team members to focus during work.
    "TheNewYorkTimes.NYTCrossword"
    "ThumbmunkeysLtd.PhototasticCollage"
    "TuneIn.TuneInRadio"
    "WinZipComputing.WinZipUniversal"
    "XINGAG.XING"
    "flaregamesGmbH.RoyalRevolt2"
    "king.com.*"
    "king.com.BubbleWitch3Saga"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "5A894077.McAfeeSecurity"
    "*McAfee*"  # Added for redundancy.
    "Disney.37853FC22B2CE"
    "Facebook.InstagramBeta"
    "AdobeSystemsIncorporated.AdobeCreativeCloudExpress"
    "AmazonVideo.PrimeVideo"
    "BytedancePte.Ltd.TikTok"

    # Even more default apps identified 1/9/23
    "4505Fortmedia.FMAP0Control"
    "*thunderbolt*"
    "*AppUp.Intel*"  # It's a store: has nothing to do with graphics.

    # apps which other apps depend on
    "Microsoft.Advertising.Xaml"
)

ForEach ($App in $Apps) {
    # For current users
    $AppExists = Get-AppxPackage -AllUsers -Name $App -ErrorAction SilentlyContinue
    If ($AppExists) {
        $AppExists | Remove-AppxPackage
    } Else {
        Write-Verbose "No app named $App."
    }

    # New users
    $AppIsProvisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue `
        | Where {$_.DisplayName -like $App}
                # (Provisioning doesn't accept DisplayName or PackageName as an arg)
    If ($AppIsProvisioned) {
        Write-Verbose "Preventing app $App from being installed for new users."
        $AppIsProvisioned | Remove-AppxProvisionedPackage -Online
    } Else {
        Write-Verbose "$App isn't provisioned."
    }
}
Write-Verbose "`n"

# End UninstallDefaultAppsScript
################################
# Uninstall App Package (non-x)

$AppPackages = @(
    "Lenovo Vantage Service"
    "Microsoft 365 - en-us"
)

ForEach ($AppName in $AppPackages) {
    $AppExists = Get-Package -Provider Programs -IncludeWindowsInstaller -Name $AppName -ErrorAction SilentlyContinue
    If($AppExists) {
        Write-Verbose "Removing App Package $AppName"
        $AppExists | Uninstall-Package
    }
}

################################
# In case McAfee is still there, try:

Write-Verbose "Attempting to remove McAfee again."
$McAfee = Get-WmiObject -Class Win32_Product | Where-Object{
    $_.Name -like "*McAfee*"
}
if ($McAfee) { $McAfee.uninstall() }


###############################################################
# NoReinstallScript: Prevent apps from re-installing themselves.

# PowerShell as default only references HKCU and HKLM registry hives, but not HKU.
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
$Names = @(
    #"ContentDeliveryAllowed"
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
ForEach ($CDMName in $Names) {
    $RegistryUpdates += , @($CDMPath, $CDMName, $CDMValue)  # Comma prevents array-of-arrays from getting unrolled into array-of-strings
}

ForEach ($i in $RegistryUpdates) {
    Write-Host $i
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
        #New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `  # Using "New is throwing errors it seems? Maybe run both under error suppression for ultra future-proofing.
        #    -PropertyType DWORD -Force | Out-Null
        Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value `
            -PropertyType DWORD -Force | Out-Null
    }
}
# End NoReinstallScript

$VerbosePreference = "SilentlyContinue"