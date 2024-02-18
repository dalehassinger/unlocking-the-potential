# Format New Drives using grain data added to minion during vRA Server Build

# ----- [ Get minion data ] -----
$eDrive = salt-call grains.get vCROCS_Drive_E_Size --output=json | ConvertFrom-Json
$eDrive = $eDrive.local
$output = 'E-Drive: ' + $eDrive
Write-Output $output

$lDrive = salt-call grains.get vCROCS_Drive_L_Size --output=json | ConvertFrom-Json
$lDrive = $lDrive.local
$output = 'L-Drive: ' +$lDrive
Write-Output $output

$tDrive = salt-call grains.get vCROCS_Drive_T_Size --output=json | ConvertFrom-Json
$tDrive = $tDrive.local
$output = 'T-Drive: ' + $tDrive
Write-Output $output

$SQL = salt-call grains.get vCROCS_SQL --output=json | ConvertFrom-Json
$SQL = $SQL.local
$output = 'SQL: ' + $SQL
Write-Output $output

# ----- [ Function to bring drive online and format ] -----
function set-driveOnline{

    param(
    [parameter(mandatory = $true)]
    [string]$driveLetter,
    [int]$diskNumber
    )

    $diskOnline = Get-Disk | Where-Object Number -EQ $diskNumber
    if($diskOnline.OperationalStatus -eq 'offline'){
        Get-Disk | Where-Object Number -EQ $diskNumber | Set-Disk -IsOffline $False

        $disksize = Get-Disk -Number $diskNumber | Select-Object size
        $disksize = $disksize.size
        $disksize = $disksize/1073741824
        $output = 'Disk ' + $diskNumber + ' Size: ' + $disksize
        Write-Output $output

        if($disksize -gt 0){
            Initialize-Disk $diskNumber -PartitionStyle GPT
        } # End if
        
        New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter $driveLetter
        
        if($SQL -eq 'True'){
            Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SQL Data" -AllocationUnitSize 65536 -Confirm:$false
        } # End If
        else{
            Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "APP Data" -AllocationUnitSize 4096 -Confirm:$false
        } # End Else

        $global:diskNumber++
        $output = 'Disk Number: ' + $global:diskNumber
        Write-Output $output
    } # end if offline

} # end function



$global:diskNumber = 1
$output = 'Disk Number: ' + $global:diskNumber
Write-Output $output

if($eDrive -gt 0){
    $driveLetter = 'E'
    $output = 'Drive Letter: ' + $driveLetter
    Write-Output $output
    
    # run function
    set-driveOnline -driveLetter $driveLetter -diskNumber $global:diskNumber

} # end if

if($lDrive -gt 0){
    $driveLetter = 'L'
    $output = 'Drive Letter: ' + $driveLetter
    Write-Output $output
    
    # run function
    set-driveOnline -driveLetter $driveLetter -diskNumber $global:diskNumber

} # end if

if($tDrive -gt 0){
    $driveLetter = 'T'
    $output = 'Drive Letter: ' + $driveLetter
    Write-Output $output
    
    # run function
    set-driveOnline -driveLetter $driveLetter -diskNumber $global:diskNumber

} # end if

