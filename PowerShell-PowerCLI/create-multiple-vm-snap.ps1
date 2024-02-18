
# ----- Create Multiple VM Snaps Now -----

$vmName          = 'LINUX-U-240,LINUX-U-241,LINUX-U-242,LINUX-U-243'
$snapName        = 'DBH-Upgrade Orchestrator'
$snapDescription = 'Upgrade to version 8.12'

Write-Output "Automation Starting..."

$vmname = $vmName -split(",")

$output = 'Number of VMs: ' + $vmName.Count
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

foreach($vm in $vmName){
  $output = "VMName: " + $vmName
  Write-Output $output

  $output = "Snap Name: " + $snapName
  Write-Output $output

  $output = "Snap Description: " + $snapDescription
  Write-Output $output

  $output = 'Starting Process to Create SNAP for VM: ' + $vmName + '!'
  Write-Output $output

  # Create Snap
  New-Snapshot -VM $vm -Name $snapName -Description $snapDescription

} # end foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false

Write-Output "Automation completed."

