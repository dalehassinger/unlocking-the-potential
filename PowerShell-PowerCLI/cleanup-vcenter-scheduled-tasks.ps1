# ----- [ Check Scheduled Tasks that have completed ] -----
#$deleteTask = 'True'
$deleteTask = 'False'

$connectvCenter = Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force

# --- Starting Scheduled Tasks ---
$output = "Starting Process to Cleanup Scheduled Tasks."
Write-Output $output

if($connectvCenter.IsConnected -eq 'True'){
  # --- Get List of All Scheduled Tasks that have run and can be deleted
  $TaskList = (Get-View ScheduledTaskManager).ScheduledTask | ForEach-Object{(Get-View $_).Info} | Where-Object {$_.Description -Like "vRA*" -and $_.NextRunTime -eq $null}
  #$TaskList
  #$TaskList.Count

  if($TaskList.Count -gt 0){
    $output = 'There are ' + $TaskList.Count + ' Scheduled tasks to delete that have already run.'
    Write-Output $output

    foreach($scheduledTask in $TaskList){
      #$scheduledTask

      $VMName = (Get-VM | Where-Object {$_.ID -eq $scheduledTask.Entity}).Name
      #$vmName

      if($deleteTask -eq 'True'){
        $output = 'Deleting Scheduled task: ' + $VMName + ' | ' + $scheduledTask.Name + ' | ' + $scheduledTask.Description
        Write-Output $output

        #Write-Host $TASk.ScheduledTask
        $si = Get-View ServiceInstance
        $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
        $t = Get-View -Id $scheduledTaskManager.ScheduledTask | Where-Object {$_.MoRef -eq $scheduledTask.ScheduledTask}
        #$t

        # --- The next line removes the scheduled task from vCenter. Comment out Next line for TEST.
        $t.RemoveScheduledTask()

      } # End If
      else{
        $output = 'Scheduled task: ' + $VMName + ' | ' + $scheduledTask.Name + ' | ' + $scheduledTask.Description
        Write-Output $output
      } # End Else

    } # End foreach

  } # End if
  else{
    $output = 'No Scheduled Task(s) to Delete.'
    Write-Output $output

  } # End Else

} # End If

Write-Output 'Disconnecting from all vCenters...'
Disconnect-VIServer * -Force -Confirm:$false

if($deleteTask -eq 'True'){
  $output = "Process to Cleanup Scheduled Tasks complete."
  Write-Output $output
} # End If
else{
  $output = "Scheduled Tasks List has been completed."
  Write-Output $output
} # End Else
