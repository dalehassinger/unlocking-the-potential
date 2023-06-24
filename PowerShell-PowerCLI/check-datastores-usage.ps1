# ----- [ Check DataStores ] -----

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear

Get-Datastore | Select-Object @{n="Datastore | Name";e={($_.Name)}},@{n="Capacity | GB";e={[system.math]::Round($_.CapacityGB,0)}},@{n="FreeSpace | GB";e={[system.math]::Round($_.FreeSpaceGB,0)}} | Sort-Object 'Datastore | Name' | Format-Table -AutoSize

# --- [ Disconnect from all vCenters ] ---
#Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false
