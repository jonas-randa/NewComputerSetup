## This is an option to load the safe-registry-updates script as a function
##  instead of pasting it into each script. (I generally recommend against
##  loading custom Powershell functions from a remote source. Local copies
##  are infinitely more secure).

$R= @( 
   # Disable CAM Location usage
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "Deny", "String"),
    @("HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "String")
)

function Set-RegistryValues {
    [CmdletBinding()]
    param ( $RegistryUpdates )

    # Verify if a reference to HKU registry hive for all users exists:
    # PowerShell as default only references HKCU and HKLM, but not HKU.
    <#If (!(Get-PSDrive -PSProvider Registry -Name "HKU")) {
         New-PSDrive -PSProvider Registry -Name "HKU" -Root "HKEY_USERS"
    }#> # For some reason, verification didn't work. Creating new one and will address later.
    New-PSDrive -PSProvider Registry -Name "HKU" -Root "HKEY_USERS"

    ForEach ($i in $RegistryUpdates) {
    $RegistryPath = $i[0] # Registry key path
    $Name = $i[1] # Name of registry key property, which doesn't have it's own path.
    $Value = $i[2] # Desired value of registry key property
    $ValueType = $i[3]  # Optional key value type
    If (!$ValueType) { $ValueType = "DWORD" }  # Default Key value type

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
}

Set-RegistryValues -RegistryUpdates $R

#$testVal = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value"
#$testVal.GetType()