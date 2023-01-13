:: Cleanup Only!
:: Edited & tested by jranda 12/16/22 on Windows 10 Pro version 21H2, OS build 19044.2251
:: @ECHO off

ECHO "Verify script run as admin."
NET SESSION
if %errorLevel% NEQ 0 (
	echo "Please run script as admin."
	PAUSE
	exit
)

:: Paths below are set for running from USB E: drive.
Set drive = "E:\ComputerSetup"

:: Cleanup
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\UpdatePrivacySettings.ps1"
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\RemoveDefaultApps.ps1"
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\DisableDefaultServices.ps1"
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\DisableDeliveryOptimization.ps1"
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\PreventAppAutoInstall.ps1"
:: Cleanup-Lenovo
powershell.exe -executionpolicy bypass -file "%drive%\Cleanup\CleanLenovoDefaults.ps1"

:: Keep File open for Troubleshooting
PAUSE
:: Restart PC
:: powershell.exe -executionpolicy bypass -file "%drive%\RestartPC.ps1"