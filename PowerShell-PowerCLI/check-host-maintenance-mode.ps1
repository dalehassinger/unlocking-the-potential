# ----- [ Check Host Maintenance Mode ] -----

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear

$hostNames = Get-VMHost | Sort-Object Name
#$hostNames.Name
#$hostNames.ConnectionState

# --- [ Check Maintenance Mode Status ] ---
foreach($hostName in $hostNames.Name){
  $hostStatus = Get-VMHost -Name $hostName
  $output = $hostName + ' | Maintenance Mode Status: ' + $hostStatus.ConnectionState
  Write-Output $output
} # End Foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false
