# ----- [ A Single VM Snap Now ] -----

$vmName          = 'LINUX-U-240'
$snapName        = 'DBH-Before Aria Upgrade'
$snapDescription = 'Upgrade to version 8.12'

Write-Output "Automation Starting..."

$output = "VMName: " + $vmName
Write-Output $output

$output = "Snap Name: " + $snapName
Write-Output $output

$output = "Snap Description: " + $snapDescription
Write-Output $output

$output = 'Starting Process to Schedule SNAP for VM: ' + $vmName + '!'
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force

Write-Output "Connected to vCenter"

# Create the Snap
New-Snapshot -VM $vmName -Name $snapName -Description $snapDescription

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false
