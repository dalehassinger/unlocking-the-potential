# ----- Set Variable Values to use with Script
$vcServer     = "vcsa8x.corp.local"
$vcUser       = "administrator@corp.local"
$vcPassword   = "VMware1!"

# ----- This example uses (1) syslog setting for each host.
#$syslogServers = "udp://vaol-vip.corp.local:514"

# ----- This example uses (2) syslog settings for each host.
#$syslogServers = "udp://vaol-vip.corp.local:514,tcp://DBH-CP-VAOL-01.corp.local:514"

# ----- This example uses (2) syslog settings divided equally between hosts.
$syslogServers = "tcp://DBH-CP-VAOL-01.corp.local:514;tcp://DBH-CP-VAOL-02.corp.local:514"

# ----- This example uses (3) syslog settings divided equally between hosts.
#$syslogServers = "udp://vaol-vip-03.corp.local:514;udp://vaol-vip-02.corp.local:514;udp://vaol-vip-01.corp.local:514"

# ----- This example uses (4) syslog settings divided equally between hosts.
#$syslogServers = "udp://vaol-vip-01.corp.local:514;udp://vaol-vip-02.corp.local:514;udp://vaol-vip-03.corp.local:514;udp://vaol-vip-04.corp.local:514"


# ----- Get list of syslog server specifed and seperated by semicolons. Semicolons were used in case you would want to specify (2) syslog servers seperated by commas.
$syslogServerList = $syslogServers.Split(";")
$syslogServerList = $syslogServerList | Sort-Object

$output = "syslog Server List: " + $syslogServerList
Write-Output $output

[int]$syslogServerCount = $syslogServerList.Count

$output = "syslog Server Count: " + $syslogServerCount
Write-Output $output


# ----- Connect to the vCenter Server or ESXi host
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword -Protocol https -Force

if($syslogServerCount -gt 1){

    # ----- Get Number of Hosts
    $hostList = Get-VMHost | Select-Object Name | Sort-Object Name
    #$hostList

    [int]$hostCount = $hostList.Count
    # ----- Total Number of Hosts
    $output = "Host Count: " + $hostCount
    Write-Output $output


    # ----- Calculate how to divide the hosts
    $baseValue = [math]::Floor($hostCount / $syslogServerCount)
    $remainder = $hostCount % $syslogServerCount

    # ----- Create an array to hold the results
    $syslogProxyNumber = @(1..$syslogServerCount | ForEach-Object { $baseValue })
    #$syslogProxyNumber

    # ----- Distribute the remainder among the numbers
    for ($i = 0; $i -lt $syslogServerCount; $i++) {
        if ($remainder -eq 0) { break }
        $syslogProxyNumber[$i]++
        $remainder--
    }
    $output = "Hosts Per Syslog Group: " + $syslogProxyNumber
    Write-Output $output
    

    $output = "Highest sysloggroup array value: " + ($syslogProxyNumber.Count - 1)
    Write-Output $output

    $output = "Syslog Group Count: " + $syslogProxyNumber.Count
    Write-Output $output

    # ----- Calculate the sum
    [int]$sum = ($syslogProxyNumber | Measure-Object -Sum).Sum
    $output = "Total Hosts to add syslog info: " + $sum
    Write-Output $output


    if($sum -eq $hostCount){
        Write-Output "Hosts were divided as equal as posible"
    }
    else{
        Write-Output "Hosts were NOT divided equal. TRY AGAIN!"
    }
} # End If
else{
    Write-Output "Only 1 syslog Server was specififed!"
} # end else

$syslogProxyNumberArrayValue = 0
$servercountstart = 1
$serverCountTotal = $syslogProxyNumber[$syslogProxyNumberArrayValue]

# Loop thru ESXi Hosts
foreach($esxiName in $hostList){
    # ----- Create Server Count Number
    $servercountstartstr = '0000' + $servercountstart
    $servercountstartstr = $servercountstartstr[-4..-1] -join ''

    # ----- Set the syslog Host value on Each ESXi Host
    if($syslogServerCount -gt 1){
        $output = "Server Count: " + $servercountstartstr + " | ESXi Server Name: " + $esxiName.Name + " | Proxy Name: " + $syslogServerList[$syslogProxyNumberArrayValue]
        Write-Output $output
        
        # ----- Set the Syslog.global.logHost value
        $output = "------------- Get-VMHost " + $esxiName.Name + " | Get-AdvancedSetting -Name 'Syslog.Global.Loghost' | Set-AdvancedSetting -Value " + $syslogServerList[$syslogProxyNumberArrayValue] + " -Confirm:$false"
        Write-Output $output
        # ----- The next line will make the changes. Remove the line comment after you test the script and make sure you are getting the results you want to use.
        Get-VMHost $esxiName.Name | Get-AdvancedSetting -Name 'Syslog.Global.Loghost' | Set-AdvancedSetting -Value $syslogServerList[$syslogProxyNumberArrayValue] -Confirm:$false

    } # End If
    elseif($syslogServerCount -eq 1){
        $output = "Server Count: " + $servercountstartstr + " | ESXi Server Name: " + $esxiName.Name + " | Proxy Name: " + $syslogServerList
        Write-Output $output
        # ----- The next line will make the changes. Remove the line comment after you test the script and make sure you are getting the results you want to use.
        #Get-VMHost $esxiName.Name | Get-AdvancedSetting -Name 'Syslog.Global.Loghost' | Set-AdvancedSetting -Value $syslogServerList -Confirm:$false
    } # End Elseif
    
    # ----- Increment Host Count and switch which Proxy to use based on count
    $servercountstart++
    if($servercountstart -gt $serverCountTotal -and $syslogServerCount -gt 1){
        $servercountstart = 1
        $syslogProxyNumberArrayValue++
        $serverCountTotal = $syslogProxyNumber[$syslogProxyNumberArrayValue]
    } # End If
} # End foreach


# ----- Disconnect from the vCenter Server or ESXi host
Disconnect-VIServer -Server $vcServer -Confirm:$false
