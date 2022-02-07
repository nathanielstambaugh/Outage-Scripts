# This is the shutdown script that takes the csv files located in C:\powerclioutput as input

# PauseScript function
Function PauseScript
{
   echo ""
   Write-Host "Finished! Press any key to exit this script..."
   $x=$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}

# PowerCLI environment init
& "C:\Program Files (x86)\Vmware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 2>$null
cls

# Warn user to make sure to check csv contents for accuracy
echo "WARN:Please check each csv accordingly before executing this script!"
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

# Check vmware tools status in each server
echo "Connecting to vcenter6..."
Connect-VIServer dst-vcenter-6.lexington.ibm.com -user "Administrator" -password "vSphere414Stagingv3" | out-null
$vms=Get-Cluster "TSAM721STAGE" | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

ForEach($vm in $vms)
{
    $vm_view=$vm | get-view
    $vmtoolstatus=$vm_view.summary.guest.toolsrunningstatus
    
    If ($vmtoolstatus -eq "guestToolsRunning")
    {
        Write-Host "Graceful shutdown being performed on $vm"
        Shutdown-VMGuest -VM $vm -Confirm:$false | out-null
    }
    Else
    {
        Write-Host "Power-Off is being performed on $vm"
        Stop-VM -RunAsync -VM $vm -Confirm:$false | out-null
    }
}
Write-Host "Waiting until VM's are powered off...."

# Wait for the VMs to be Shutdown
Do {
    sleep 2.0
    $numvms=@(Get-Cluster "TSAM721STAGE" | Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
    
# Shutdown ESXi Hosts
#Write-Host "Shutting down ESXi hosts...."
#$esxhosts = Get-Cluster "TSAM721STAGE" | Get-VMHost
#$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown Complete for vcenter6"
Disconnect-VIServer -confirm:$false | out-null
PauseScript
