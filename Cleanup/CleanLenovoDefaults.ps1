# On Lenovo Devices, stop extraneous Lenovo services & uninstall apps.
# (There are other Lenovo services that provide needed 
#   functionality, however these ones only collect data.)

# Comment or Uncomment for statuses/debugging.
$VerbosePreference = "Continue"

Write-Host "Removing Lenovo Scheduled tasks`n" -ForegroundColor Green
# Lenovo tasks are known to reinstall Lenovo services.
$LenovoTasks = @(
    "Lenovo iM Controller Monitor"
    "Lenovo iM Controller Scheduled Maintenance"
    "LenovoSystemUpdatePlugin-WeeklyTask"
    "GlanceDiscovery" # TODO is it still there? what happened to it
    "AppUp.ThunderboltControlCenter"
)

ForEach ($LenovoTaskName in $LenovoTasks) {
    $LenovoTaskExists = Get-ScheduledTask -TaskName $LenovoTaskName -ErrorAction SilentlyContinue
    If ($LenovoTaskExists) {
        Unregister-ScheduledTask -TaskName $LenovoTaskName -Confirm:$false
        Write-Verbose "$LenovoTaskName task is no longer scheduled."
    } Else {
        Write-Verbose "$LenovoTaskName doesn't exist."
    }
}
Write-Output "`n"


Write-Host "Disable Lenovo Services`n" -ForegroundColor Green
# Disabled service cannot be run by an user or application
$LenovoServices = @(
    "Lenovo Hotkey Client Loader"
    "Lenovo Intelligent Thermal Solution Service"
    "Lenovo Platform Service"
    "Lenovo PM Service"
    "Lenovo Smart Standby"
    "System Interface Foundation Service" # Lenovo Vantage Part 1
)

ForEach ($LenovoServiceName in $LenovoServices) {
    $LenovoServiceExists = Get-Service -DisplayName $LenovoServiceName -ErrorAction SilentlyContinue
    If ($LenovoServiceExists) {
        Stop-Service $LenovoServiceExists
        $LenovoServiceExists | Set-Service -StartupType Disabled
        Write-Verbose "$LenovoServiceName stopped & startup disabled."
    } Else {
        Write-Verbose "$LenovoServiceName doesn't exist."
    }
}
Write-Output "`n"


Write-Host "Lenovo App Removal`n" -ForegroundColor Green
$LenovoApps = @(
    "*LenovoCompanion*" # Lenovo Vantage Part 2.
    # Note: Lenovo states Malware disguises itself as this companion.
    "*MirametrixInc.GlancebyMirametrix*" # Glance by Miratrix eyeball tracker
    "*AIMeetingManager*"
)

ForEach ($LenovoApp in $LenovoApps) {
    # Current user
    $LenovoAppExists = Get-AppxPackage -AllUsers -Name $LenovoApp -ErrorAction SilentlyContinue
    If ($LenovoAppExists) {
        # Stop-AppvClientPackage $LenovoAppExists
        $LenovoAppExists | Remove-AppxPackage
        Write-Verbose "$LenovoApp removed."
    } Else {
        Write-Verbose "$LenovoApp doesn't exist."
    }
    # New users
    $AppIsProvisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue `
        | Where {$_.DisplayName -like $LenovoApp}
                # (Provisioning doesn't accept DisplayName or PackageName as an arg)
    If ($AppIsProvisioned) {
        Write-Verbose "Preventing app $LenovoApp from being installed for new users."
        $AppIsProvisioned | Remove-AppxProvisionedPackage -Online
    } Else {
        Write-Verbose "$LenovoApp isn't provisioned."
    }
}
Write-Output "`n"

$VerbosePreference = "SilentlyContinue"