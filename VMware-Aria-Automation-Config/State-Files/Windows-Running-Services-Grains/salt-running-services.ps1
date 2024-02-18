<#
.SYNOPSIS
  This Script is used to Get Windows Servers Running Services and add as Grain Data
.DESCRIPTION
  Windows Servers Running Services
.PARAMETER
  No Parameters
.INPUTS
  No inputs
.OUTPUTS
  salt grain data
.NOTES
  Version:        1.00
  Author:         Dale Hassinger
  Creation Date:  04/20/2023
  Purpose/Change: Initial script development
  Revisions:

.EXAMPLE
    N/A
#>

# ----- [ Start of Code ] ---------------------------------------------------------------------------

# --- Minion Get Windows Server Running Services

# --- Delete existing grains running services data
$saltCommand = 'salt-call grains.delkey vCROCS_Windows_Services_Running force=True'
#$saltCommand

# --- Run Salt Command
Invoke-Expression -Command $saltCommand

# --- Get all Running Services
$serviceNames = Get-Service | Where-Object {$_.Status -eq 'Running'}

# --- Create Array
$servicesGrains = @()

# --- Add Service data to the array
foreach($serviceName in $serviceNames){
  $grainString = $serviceName.Name + ' | ' + $serviceName.DisplayName
  $servicesGrains = $servicesGrains + $grainString
} # End Foreach
#$servicesGrains

# --- Add Windows Running Services as Grain Data
foreach($servicesGrain in $servicesGrains){
    # --- Grains Append
    $saltCommand = 'salt-call grains.append vCROCS_Windows_Services_Running "' + $servicesGrain + '"'
    #$saltCommand

    # --- Run Salt Command
    Invoke-Expression -Command $saltCommand

} # End Foreach

# --- Delete existing grains last update data
$saltCommand = 'salt-call grains.delkey vCROCS_last_grains_update force=True'
#$saltCommand

# --- Run Salt Command
Invoke-Expression -Command $saltCommand

# --- Add a Date that grains last updated
$grainsupdateDate = Get-Date
$grainsupdateDate = $grainsupdateDate.ToString("MM/dd/yyyy | hh:mm")
#$grainsupdateDate

# --- Grains Append
$saltCommand = 'salt-call grains.append vCROCS_last_grains_update "' + $grainsupdateDate + '"'

# --- Run Salt Command
Invoke-Expression -Command $saltCommand

# --- Grains Sync
$saltCommand = 'salt-call saltutil.sync_grains'

# --- Run Salt Command
Invoke-Expression -Command $saltCommand

# ----- [ End of Code ] ---------------------------------------------------------------------------