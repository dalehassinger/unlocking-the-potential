# ----- [ Get current loghost vaules ] -----

# ----- Set Variable Values to use with Script
$vcServer     = "vcsa8x.corp.local"
$vcUser       = "administrator@corp.local"
$vcPassword   = "VMware1!"

# ----- File Name to store data
$filePath = "C:\Github\PS-TAM-Lab\syslog-current-info.csv"

# ----- Connect to the vCenter Server or ESXi host
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword -Protocol https -Force

# ----- Get list of all Hosts
$hostList = Get-VMHost | Select-Object Name | Sort-Object Name

# ----- Create new CSV file
New-Item -Path $filePath -ItemType File -Force

# ----- add header to CSV file
Add-Content -Path $filePath -Value "ServerName,syslogName"

# ----- Get all ESXi Hosts
$hostList = Get-VMHost | Select-Object Name | Sort-Object Name

# ----- Output Data to screen and the CSV file
foreach($hostName in $hostList){
    $syslogInfo = Get-VMHost -Name $hostName.Name | Get-AdvancedSetting -Name "Syslog.global.logHost"

    $output = "Server Name: " + $syslogInfo.Entity.Name + " | syslog Name: " + $syslogInfo.Value
    Write-Output $output
    
    # ----- add info to csv file
    $addContentstr = $syslogInfo.Entity.Name + "," + $syslogInfo.Value
    Add-Content -Path $filePath -Value $addContentstr
} # End foreach

# ----- Disconnect from the vCenter Server or ESXi host
Disconnect-VIServer -Server $vcServer -Confirm:$false
