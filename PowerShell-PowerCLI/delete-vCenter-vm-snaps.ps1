# ----- Multiple VM Snap Cleanup -----
$vmName = 'LINUX-U-240,LINUX-U-241,LINUX-U-242,LINUX-U-243'

Write-Output "Automation Starting..."

$vmname = $vmName -split(",")

$output = 'Number of VMs: ' + $vmName.Count
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

foreach($vm in $vmName){
  $output = "VMName: " + $vm
  Write-Output $output

  $output = 'Starting Process to Delete SNAP for VM: ' + $vmName + '!'
  Write-Output $output

  $snapDetails = Get-VM -Name $vm | Get-Snapshot
  #$snapDetails.Name

  # Delete VM Snap
  Get-VM -Name $vm | Get-Snapshot | Remove-Snapshot -Confirm:$false

} # end foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false

Write-Output "Automation completed."
