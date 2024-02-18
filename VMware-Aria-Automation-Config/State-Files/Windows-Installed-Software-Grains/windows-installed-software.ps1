<#
.SYNOPSIS
  This Script is used to Get Windows Installed Packages and add as Grain Data
.DESCRIPTION
  Windows Servers Installed Packages
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

# --- Minion Get Windows Server Installed Packages|Software

# --- Delete existing grains features data
$saltCommand = 'salt-call grains.delkey vCROCS_Windows_Installed_Software force=True'
#$saltCommand

# --- Run Salt Command
Invoke-Expression -Command $saltCommand

$saltCommand = 'salt-call pkg.list_pkgs --output=json'
#$saltCommand

# --- Run Salt Command
$results =Invoke-Expression -Command $saltCommand
#$results

$installedPackages = $results | ConvertFrom-Json
$installedPackages = $installedPackages.local
$installedPackages = $installedPackages -split(":")
$installedPackages = $installedPackages -split(";")
$installedPackages = $installedPackages -replace("@{","")
$installedPackages = $installedPackages -replace("}","")
$installedPackages = $installedPackages.trim()
$installedPackages = $installedPackages -replace("="," | ")
$installedPackages = $installedPackages | Sort-Object
#$installedPackages

foreach($installedPackage in $installedPackages){
    # --- Grains Append
    $saltCommand = 'salt-call grains.append vCROCS_Windows_Installed_Software "' + $installedPackage + '"'
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