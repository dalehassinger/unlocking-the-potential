# ----- [ Check DRS Status ] -----

$clusterName = 'Cluster-01'

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force

# --- [ Check DRS ] ---
$drsStatus = Get-Cluster -Name $clusterName | Select-Object *
#$drsStatus.DrsEnabled

$outPut = $clusterName + ' | DRS is enabled: ' + $drsStatus.DrsEnabled 
Write-Output $outPut

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false
