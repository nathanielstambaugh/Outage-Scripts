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

    If($server -eq "dst-vcenter-1.lexington.ibm.com") -or ($server -eq "dst-vcenter-3.bcsdc.lexington.ibm.com")
    {
        $vm = $csv
        Write-Host "Starting VM's......please be patient as this might take awhile"
        Start-VM $vm
        Write-Host "Done with startup of $server......"
    }
    Else
    {
        $count=$csv.count
        ForEach($vm in $csv)
        {
          $count = $count - 1
          Write-Host "Starting up $vm....$count left to go"
          Start-VM -RunAsync $vm -confirm:$false | out-null
        }
    }
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
$vcenter1_GA64bit=Import-CSV C:\powerclioutput\vcenter1_GA64bit.csv | Select -ExpandProperty Name
$vcenter3=Import-CSV C:\powerclioutput\vcenter3.csv | Select -ExpandProperty Name
$vcenter5=Import-CSV C:\powerclioutput\vcenter5.csv | Select -ExpandProperty Name
$vcenter6=Import-CSV C:\powerclioutput\vcenter6.csv | Select -ExpandProperty Name
$yzcloud72vc=Import-CSV C:\powerclioutput\yzcloud-72-vc.csv | Select -ExpandProperty Name

# Startup vcenter1 GA64bit
#StartupVC "dst-vcenter-1.lexington.ibm.com" "Administrator" "sm0ggyf0ggy" $vcenter1_GA64bit

# Startup vcenter3
#StartupVC "dst-vcenter-3.bcsdc.lexington.ibm.com" "Administrator" "sm0ggyf0ggy" $vcenter3

# Startup vcenter5
#StartupVC "dst-vcenter-5.lexington.ibm.com" "Administrator" "Work42ls" $vcenter5

# Startup vcenter6
#StartupVC "dst-vcenter-6.lexington.ibm.com" "Administrator" "vSphere414Stagingv3" $vcenter6

# Startup yzcloud-72-vc
StartupVC "yzcloud-72-vc.bcsdc.lexington.ibm.com" "Administrator" "LAsm0g" $yzcloud72vc

PauseScript