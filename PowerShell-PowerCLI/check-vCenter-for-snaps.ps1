# ----- [ Check for Snaps ] -----

# --- [ Connect vCenter ] ---
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

# --- [ Check for Snaps ] ---
$snapInfo = Get-VM | Get-Snapshot | Select-Object VM, Name, Created | Sort-Object VM

if(!$snapInfo){
  $outPut = 'There is currently no VM SNAPs!'
  Write-Output $outPut
} # End If
else {
  Write-Output $snapInfo | Format-Table -AutoSize
} # End Else

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false
