# This turns off Windows Event Viewer.
# I am not sure whether I recommend this, as it could have useful debugging
# capabilities. On the other hand, the log saved could potentially be accessed by
# third-parties.


#Disable-AppBackgroundTaskDiagnosticLog -Confirm:$false