# Script that will collect powered on VM information and store it in a csv file

# PauseScript function
Function PauseScript
{
   echo ""
   Write-Host "Finished! Press any key to exit this script..."
   $x=$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}

# Initialize powercli environment
& "C:\Program Files (x86)\Vmware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 2>$null
cls

# Connect to vcenter6
echo "Connecting to vcenter6..."
Connect-VIServer dst-vcenter-6.lexington.ibm.com -user "Administrator" -password "vSphere414Stagingv3" | out-null

# Collect the powered on VM's from vcenter6
echo "Collecting information from vcenter6..."
Get-Cluster "TSAM721STAGE" | Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter6_TSAM721STAGE.csv -NoTypeInformation
Disconnect-VIServer -confirm:$false | out-null
PauseScript
