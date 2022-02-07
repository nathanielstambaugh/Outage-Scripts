# This is the startup script that takes the csv files located in C:\powerclioutput as input

# PauseScript function
Function PauseScript
{
   echo ""
   Write-Host "Finished! Press any key to exit this script..."
   $x=$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}

Function StartupVC($server,$user,$password,$csv)
{
   Write-Host "Connecting to $server.."
   Connect-VIServer $server -user $user -password $password | out-null
   $vm=$csv
   
   Write-Host "Starting up VM's.....please be patient as this might take awhile"
   Start-VM $vm
   Write-Host "Done with startup of $server"
   Disconnect-VIServer -confirm:$false | out-null
}

# PowerCLI environment init
& "C:\Program Files (x86)\Vmware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 2>$null
cls

# Warn user to make sure the csv contents are up to date
echo "WARN:Please make sure you have the newest version of the CSV files by running the collection script!"
$input=Read-Host 'Proceed? [Y/N] '

# Check input from stdin
If($input -eq "N")
{
    exit
}

If ($input -eq "n")
{
    exit
}

# Read csv contents into memory
$vcenter6=Import-CSV C:\powerclioutput\vcenter6_TSAM721STAGE.csv | Select -ExpandProperty Name

StartupVC "dst-vcenter-6.lexington.ibm.com" "Administrator" "vSphere414Stagingv3" $vcenter6

PauseScript