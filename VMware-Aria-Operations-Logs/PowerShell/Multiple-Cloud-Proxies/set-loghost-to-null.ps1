# ----- [ Set loghost values to null on all Hosts ] -----

# ----- Set Variable Values to use with Script
$vcServer     = "vcsa8x.corp.local"
$vcUser       = "administrator@corp.local"
$vcPassword   = "VMware1!"

# ----- Connect to the vCenter Server or ESXi host
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword -Protocol https -Force

# ----- Get list of all Hosts
$hostList = Get-VMHost | Select-Object Name | Sort-Object Name

# ----- Get all ESXi Hosts
$hostList = Get-VMHost | Select-Object Name | Sort-Object Name

# ----- Output Data to screen and a CSV file.
foreach($hostName in $hostList){
    $output = "Server Name: " + $hostName.Name + " | syslog Name: Set to null"
    Write-Output $output

    # ----- Set logserver address to null
    Set-VMHostSysLogServer -SysLogServer $null -VMHost $hostName.Name

} # End foreach

# ----- Disconnect from the vCenter Server or ESXi host
Disconnect-VIServer -Server $vcServer -Confirm:$false
