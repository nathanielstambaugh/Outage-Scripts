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

# Connect to the vcenter1
echo "Connecting to vcenter1...."
Connect-VIServer dst-vcenter-1.lexington.ibm.com -user "Administrator" -password "sm0ggyf0ggy" | out-null

# Collect the powered on VM's from GA64bit cluster and output to csv file
echo "Collecting information from vcenter1 GA64bit cluster..."
Get-Cluster "GA64bit" | Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter1_GA64bit.csv -NoTypeInformation
Get-Cluster "GA64bit" | Get-VMHost | Sort Name | Select Name | Export-CSV C:\powerclioutput\vcenter1_GA64bit_Hosts.csv -NoTypeInformation
Get-Cluster "LEXBZSAND" | Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter1_LEXBZSAND.csv -NoTypeInformation
Get-Cluster "LEXBZSAND" | Get-VMHost | Sort Name | Select Name | Export-CSV C:\powerclioutput\vcenter1_LEXBZSAND_Hosts.csv -NoTypeInformation
Disconnect-VIServer -confirm:$false | out-null
echo "Done!"

# Connect to vcenter3
echo "Connecting to vcenter3..."
Connect-VIServer dst-vcenter-3.bcsdc.lexington.ibm.com -user "Administrator" -password "sm0ggyf0ggy" | out-null

# Collect the powered on VM's from vcenter3
echo "Collecting information from vcenter3...."
Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter3.csv -NoTypeInformation
Get-VMHost | Sort Name | Select Name | Export-CSV C:\powerclioutput\vcenter3_Hosts.csv -NoTypeInformation
echo "Done!"
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter5
echo "Connecting to vcenter5..."
Connect-VIServer dst-vcenter-5.lexington.ibm.com -user "Administrator" -password "Work42ls" | out-null

# Collect the powered on VM's from vcenter5
echo "Collecting information from vcenter5..."
Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter5.csv -NoTypeInformation
Get-VMHost | Sort Name | Select Name | Export-CSV C:\powerclioutput\vcenter5_Hosts.csv -NoTypeInformation
echo "Done!"
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter6
echo "Connecting to vcenter6..."
Connect-VIServer dst-vcenter-6.lexington.ibm.com -user "Administrator" -password "vSphere414Stagingv3" | out-null

# Collect the powered on VM's from vcenter6
echo "Collecting information from vcenter6..."
Get-VM | Sort Name | Where-Object {$_.powerstate -eq "PoweredOn"} | Select Name | Export-CSV C:\powerclioutput\vcenter6.csv -NoTypeInformation
Get-VMHost | Sort Name | Select Name | Export-CSV C:\powerclioutput\vcenter6_Hosts.csv -NoTypeInformation
echo "Done!"
Disconnect-VIServer -confirm:$false | out-null
PauseScript






