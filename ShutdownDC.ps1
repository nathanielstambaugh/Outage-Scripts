# This is the shutdown script that takes the csv files located in C:\powerclioutput as input

# PauseScript function
Function PauseScript
{
   echo ""
   Write-Host "Finished! Press any key to exit this script..."
   $x=$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}
   
Function ShutdownVC($server,$user,$password,$cluster)
{
   Write-Host "Connecting to $server.."
   Connect-VIServer $server -user $user -password $password | out-null
   $vms=Get-Cluster $cluster | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}
   
   If ($server -eq "dst-vcenter-1.lexington.ibm.com") -or ($server -eq "dst-vcenter-3.bcsdc.lexington.ibm.com")
   {
        Set-Cluster -Cluster $cluster -DrsEnabled:$false -confirm:$false | out-null
   }
   
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
   Do {
    sleep 2.0
    $numvms=@(Get-Cluster $cluster | Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
   
   Write-Host "Shutting down ESXi hosts...."
   $esxhosts = Get-Cluster $cluster | Get-VMHost
   $esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null
   
   Write-Host "Shutdown Complete for $cluster cluster on $server...."
   
   If($server -eq "dst-vcenter-1.lexington.ibm.com") -or ($server -eq "dst-vcenter-3.bcsdc.lexington.ibm.com")
   {
        Set-Cluster -Cluster "GA64bit" -DrsEnabled:$true -confirm:$false | out-null
   }
   Disconnect-VIServer -confirm:$false | out-null
   
   

# PowerCLI environment init
& "C:\Program Files (x86)\Vmware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 2>$null
cls

# Warn user to make sure to check csv contents for accuracy
echo "WARN:This script will shutdown servers. Please make sure you are ready to execute!"
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
Write-Host "Connecting to vcenter1..."
Connect-VIServer dst-vcenter-1.lexington.ibm.com -user "Administrator" -password "sm0ggyf0ggy" | out-null
Set-Cluster -Cluster "GA64bit" -DrsEnabled:$false -confirm:$false | out-null
$vms=Get-Cluster "GA64bit" | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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

 #Wait for the VMs to be Shutdown
Do {
    sleep 2.0
    $numvms=@(Get-Cluster "GA64bit" | Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
    
 #Shutdown ESXi Hosts
Write-Host "Shutting down ESXi hosts...."
$esxhosts = Get-Cluster "GA64bit" | Get-VMHost
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown Complete for GA64bit cluster"

 #Shutdown dst-i8872-7.lexington.ibm.com
Write-Host "Shutting down dst-i8872-7"
$vms=Get-Cluster "LEXBZSAND" | Get-VMHost "dst-i8872-7.lexington.ibm.com" | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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

 #Wait for the VMs to be Shutdown
Do {
    sleep 2.0
    $numvms=@(Get-Cluster "LEXBZSAND" | Get-VMHost "dst-i8872-7.lexington.ibm.com" | Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)

Write-Host "Shutdown complete for vcenter1..."
Set-Cluster -Cluster "GA64bit" -DrsEnabled:$true -confirm:$false | out-null
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter3
Write-Host "Connecting to vcenter3..."
Connect-VIServer dst-vcenter-3.bcsdc.lexington.ibm.com -user "Administrator" -password "sm0ggyf0ggy" | out-null
Get-Cluster | Set-Cluster -DrsEnabled:$false -confirm:$false | out-null
$vms=Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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
    $numvms=@(Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
   
# Shutdown ESXi Hosts
Write-Host "Shutting down ESXi hosts...."
$esxhosts = Get-VMHost
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown complete for vcenter3..."
Get-Cluster | Set-Cluster -DrsEnabled:$true -confirm:$false | out-null
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter5
Write-Host "Connecting to vcenter5..."
Connect-VIServer dst-vcenter-5.lexington.ibm.com -user "Administrator" -password "Work42ls" | out-null

$vms=Get-Cluster "Lex Blue Traditional" | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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
    $numvms=@(Get-Cluster "Lex Blue Traditional" | Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
   
 # Shutdown ESXi Hosts on Lex Blue Traditional Cluster
Write-Host "Shutting down ESXi hosts...."
$esxhosts = Get-Cluster "Lex Blue Traditional" | Get-VMHost
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

# Shutdown ESXi Hosts on Sandbox_724_LEX_BZ
$esxhosts = Get-Cluster "Sandbox_724_LEX_BZ" | Get-VMHost
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown complete for vcenter5..."
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter6
Write-Host "Connecting to vcenter6..."
Connect-VIServer dst-vcenter-6.lexington.ibm.com -user "Administrator" -password "vSphere414Stagingv3" | out-null
$vms=Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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
    $numvms=@(Get-VM | Where-Object { $_.powerstate -eq "PoweredOn" })
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
   
 # Shutdown ESXi Hosts
Write-Host "Shutting down ESXi hosts...."
$esxhosts = Get-VMHost
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown complete for vcenter6..."
Disconnect-VIServer -confirm:$false | out-null

# Connect to vcenter7
Write-Host "Connecting to vcenter7..."
Connect-VIServer dst-vcenter-7.bcsdc.lexington.ibm.com -user "Administrator" -password "Work42ls" | out-null
$vms=Get-VMHost "dst-x8877-1.bcsdc.lexington.ibm.com" | Get-VM

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

# Wait for the VMs to be Shutdown
Do {
    sleep 2.0
    $numvms=@(Get-VMHost "dst-x8877-1.bcsdc.lexington.ibm.com" | Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"})
    $numcount=$numvms.count
    Write-Host "Waiting for shutdown of $numcount VMs..."
   } Until ($numvms.count -eq 0)
   
 # Shutdown ESXi Hosts
Write-Host "Shutting down dst-x8877-1 host...."
$esxhosts = Get-VMHost "dst-x8877-1.bcsdc.lexington.ibm.com"
$esxhosts | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)} | out-null

Write-Host "Shutdown complete for vcenter7..."
Disconnect-VIServer -confirm:$false | out-null

# Connect to yzcloud-72-vc
Write-Host "Connecting to yzcloud-72-vc..."
Connect-VIServer yzcloud-72-vc.bcsdc.lexington.ibm.com -user "Administrator" -password "LAsm0g" | out-null
$vms=Get-VM | Where-Object {$_.powerstate -eq "PoweredOn"}

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
   
Write-Host "Done with yzcloud-72-vc.....Please manually shutdown the hosts from vcenter client"
Disconnect-VIServer -confirm:$false | out-null
PauseScript
