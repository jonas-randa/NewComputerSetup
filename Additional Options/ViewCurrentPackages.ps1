# View Default Packages currently installed on computer for reference

Get-AppxPackage | Select Name, PackageFullName

# Wildcard Package Name
# Get-AppxPackage *xboxapp* | Name, PackageFullName

# Remove Packages
# Get-AppxPackage -AllUsers [Name] | Remove-AppxPackage
# OR
# Get-AppxPackage -AllUsers [PackageFullName] | Remove-AppxPackage

# Reinstall a Default Package
# Add-AppxPackage -Register "C:Program FilesWindowsAppsPackageFullNameappxmanifest.xml" -DisableDevelopmentMode

# NOT RECOMMENDED: Reinstall all Default Apps
<#
Get-AppxPackage -AllUsers | foreach {
    Add-AppxPackage -Register "$($_.InstallLOcation)appxmanifest.xml" -DisableDevelopmentMode
}
#>


# View Scheduled Tasks currently set to run on computer
# May use similar *wildcard* and pipeline| sytnax as above.

Get-ScheduledTask | Select TaskName
# May also Select TaskPath, State

# While I'm at it, check for Scheduled Jobs I guess? They aren't common.
Get-ScheduledJob | Select Name