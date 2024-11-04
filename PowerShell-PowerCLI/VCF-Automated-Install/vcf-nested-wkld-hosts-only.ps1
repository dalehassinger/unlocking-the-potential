# Script to add Nested VCF WRKLDESXi Hosts
# Author: Dale Hassinger
# Based on Script by: William Lam



# vCenter Server used to deploy VMware Cloud Foundation Lab
$VIServer = "192.168.6.100"
$VIUsername = "administrator@vcrocs.local"
$VIPassword = "VMware1!"



# Full Path to both the Nested ESXi & Cloud Builder OVA
#$NestedESXiApplianceOVA = "/Users/dalehassinger/Downloads/Nested_ESXi8.0u3b_Appliance_Template_v1.ova"
$NestedESXiApplianceOVA = "/Users/hdale/Downloads/Nested_ESXi8.0u3b_Appliance_Template_v1.ova"



# VCF Licenses or leave blank for evaluation mode (requires VCF 5.1.1 or later)
$VCSALicense = ""
$ESXILicense = ""
$VSANLicense = ""
$NSXLicense = ""



# VCF Configurations
$VCFManagementDomainPoolName = "vcf-m01-rp01"
$VCFManagementDomainJSONFile = "vcf-mgmt.json"
$VCFWorkloadDomainUIJSONFile = "vcf-commission-host-ui.json"
$VCFWorkloadDomainAPIJSONFile = "vcf-commission-host-api.json"



# Nested ESXi VMs for Workload Domain
$NestedESXiHostnameToIPsForWorkloadDomain = @{
    "vcf-m01-esx05"   = "192.168.4.189"
    "vcf-m01-esx06"   = "192.168.4.190"
    "vcf-m01-esx07"   = "192.168.4.191"
    "vcf-m01-esx08"   = "192.168.4.192"
}



# Nested ESXi VM Resources for Workload Domain
$NestedESXiWLDVSANESA = $false
$NestedESXiWLDvCPU = "8"
$NestedESXiWLDvMEM = "36" #GB
$NestedESXiWLDCachingvDisk = "4" #GB
$NestedESXiWLDCapacityvDisk = "200" #GB
$NestedESXiWLDBootDisk = "32" #GB



# ESXi Network Configuration
$NestedESXiManagementNetworkCidr = "192.168.4.0/22" # should match $VMNetwork configuration
$NestedESXivMotionNetworkCidr = "192.168.8.0/24"
$NestedESXivSANNetworkCidr = "192.168.9.0/24"
$NestedESXiNSXTepNetworkCidr = "192.168.10.0/24"



# vCenter Configuration
#$VCSAName = "vcf-m01-vc01"
#$VCSAIP = "192.168.4.182"
#$VCSARootPassword = "VMware1!"
#$VCSASSOPassword = "VMware1!"
#$EnableVCLM = $true

# NSX Configuration
#$NSXManagerSize = "medium"
#$NSXManagerVIPHostname = "vcf-m01-nsx01"
#$NSXManagerVIPIP = "192.168.4.183"
#$NSXManagerNode1Hostname = "vcf-m01-nsx01a"
#$NSXManagerNode1IP = "192.168.4.184"
#$NSXRootPassword = "VMware1!VMware1!"
#$NSXAdminPassword = "VMware1!VMware1!"
#$NSXAuditPassword = "VMware1!VMware1!"

# General Deployment Configuration for Nested ESXi & Cloud Builder VM
$VMDatacenter = "Datacenter-DB-01"
$VMCluster = "VCF_LAB"
$VMNetwork = "VMs"
$VMDatastore = "ESX-04-2TB"
$VMNetmask = "255.255.252.0"
$VMGateway = "192.168.4.1"
$VMDNS = "192.168.6.1"
$VMNTP = "time.google.com"
$VMPassword = "VMware1!"
$VMDomain = "vcrocs.local"
$VMSyslog = "192.168.6.94"
$VMFolder = "VCF-VMs"








#### DO NOT EDIT BEYOND HERE ####

$verboseLogFile = "vcf-lab-deployment.log"
$random_string = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$VAppName = "Nested-VCF-Lab-$random_string"
$SeparateNSXSwitch = $false
$VCFVersion = ""

$preCheck = 1
$confirmDeployment = 1
$deployNestedESXiVMsForMgmt = 1

# WLD Setup
$deployNestedESXiVMsForWLD = 1
$deployCloudBuilder = 1
$moveVMsIntovApp = 1
$generateMgmJson = 1
$startVCFBringup = 0
$generateWldHostCommissionJson = 1
$uploadVCFNotifyScript = 0

#$srcNotificationScript = "vcf-bringup-notification.sh"
#$dstNotificationScript = "/root/vcf-bringup-notification.sh"

$StartTime = Get-Date

Function New-LogEvent {
    param(
    [Parameter(Mandatory=$true)][String]$message,
    [Parameter(Mandatory=$false)][String]$color="green"
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor $color " $message"
    $logMessage = "[$timeStamp] $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}








if($confirmDeployment -eq 1) {
    Write-Host -ForegroundColor Magenta "`nPlease confirm the following configuration will be deployed:`n"

    Write-Host -ForegroundColor Yellow "---- VCF Automated Lab Deployment Configuration ---- "
    Write-Host -NoNewline -ForegroundColor Green "VMware Cloud Foundation Version: "
    Write-Host -ForegroundColor White $VCFVersion
    Write-Host -NoNewline -ForegroundColor Green "Nested ESXi Image Path: "
    Write-Host -ForegroundColor White $NestedESXiApplianceOVA
    Write-Host -NoNewline -ForegroundColor Green "Cloud Builder Image Path: "
    Write-Host -ForegroundColor White $CloudBuilderOVA

    Write-Host -ForegroundColor Yellow "`n---- vCenter Server Deployment Target Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "vCenter Server Address: "
    Write-Host -ForegroundColor White $VIServer
    Write-Host -NoNewline -ForegroundColor Green "VM Network: "
    Write-Host -ForegroundColor White $VMNetwork

    Write-Host -NoNewline -ForegroundColor Green "VM Storage: "
    Write-Host -ForegroundColor White $VMDatastore
    Write-Host -NoNewline -ForegroundColor Green "VM Cluster: "
    Write-Host -ForegroundColor White $VMCluster
    Write-Host -NoNewline -ForegroundColor Green "VM vApp: "
    Write-Host -ForegroundColor White $VAppName

    Write-Host -ForegroundColor Yellow "`n---- Cloud Builder Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "Hostname: "
    Write-Host -ForegroundColor White $CloudbuilderVMHostname
    Write-Host -NoNewline -ForegroundColor Green "IP Address: "
    Write-Host -ForegroundColor White $CloudbuilderIP


    if($deployNestedESXiVMsForWLD -eq 1) {
        Write-Host -ForegroundColor Yellow "`n---- vESXi Configuration for VCF Workload Domain ----"
        Write-Host -NoNewline -ForegroundColor Green "# of Nested ESXi VMs: "
        Write-Host -ForegroundColor White $NestedESXiHostnameToIPsForWorkloadDomain.count
        Write-Host -NoNewline -ForegroundColor Green "IP Address(s): "
        Write-Host -ForegroundColor White $NestedESXiHostnameToIPsForWorkloadDomain.Values
        Write-Host -NoNewline -ForegroundColor Green "vCPU: "
        Write-Host -ForegroundColor White $NestedESXiWLDvCPU
        Write-Host -NoNewline -ForegroundColor Green "vMEM: "
        Write-Host -ForegroundColor White "$NestedESXiWLDvMEM GB"
        Write-Host -NoNewline -ForegroundColor Green "Caching VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiWLDCachingvDisk GB"
        Write-Host -NoNewline -ForegroundColor Green "Capacity VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiWLDCapacityvDisk GB"
    }

    Write-Host -NoNewline -ForegroundColor Green "`nNetmask "
    Write-Host -ForegroundColor White $VMNetmask
    Write-Host -NoNewline -ForegroundColor Green "Gateway: "
    Write-Host -ForegroundColor White $VMGateway
    Write-Host -NoNewline -ForegroundColor Green "DNS: "
    Write-Host -ForegroundColor White $VMDNS
    Write-Host -NoNewline -ForegroundColor Green "NTP: "
    Write-Host -ForegroundColor White $VMNTP
    Write-Host -NoNewline -ForegroundColor Green "Syslog: "
    Write-Host -ForegroundColor White $VMSyslog

}









if($deployNestedESXiVMsForMgmt -eq 1 -or $deployNestedESXiVMsForWLD -eq 1 -or $deployCloudBuilder -eq 1 -or $moveVMsIntovApp -eq 1) {
    New-LogEvent "Connecting to Management vCenter Server $VIServer ..."
    $viConnection = Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue -Protocol https -Force

    $datastore = Get-Datastore -Server $viConnection -Name $VMDatastore | Select -First 1
    $cluster = Get-Cluster -Server $viConnection -Name $VMCluster
    $vmhost = $cluster | Get-VMHost | Get-Random -Count 1
}







# --- Start WLD Hosts
if($deployNestedESXiVMsForWLD -eq 1) {
    $NestedESXiHostnameToIPsForWorkloadDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
        $VMName = $_.Key
        $VMIPAddress = $_.Value

        $ovfconfig = Get-OvfConfiguration $NestedESXiApplianceOVA
        $networkMapLabel = ($ovfconfig.ToHashTable().keys | where {$_ -Match "NetworkMapping"}).replace("NetworkMapping.","").replace("-","_").replace(" ","_")
        $ovfconfig.NetworkMapping.$networkMapLabel.value = $VMNetwork
        $ovfconfig.common.guestinfo.hostname.value = "${VMName}.${VMDomain}"
        $ovfconfig.common.guestinfo.ipaddress.value = $VMIPAddress
        $ovfconfig.common.guestinfo.netmask.value = $VMNetmask
        $ovfconfig.common.guestinfo.gateway.value = $VMGateway
        $ovfconfig.common.guestinfo.dns.value = $VMDNS
        $ovfconfig.common.guestinfo.domain.value = $VMDomain
        $ovfconfig.common.guestinfo.ntp.value = $VMNTP
        $ovfconfig.common.guestinfo.syslog.value = $VMSyslog
        $ovfconfig.common.guestinfo.password.value = $VMPassword
        $ovfconfig.common.guestinfo.ssh.value = $true

        New-LogEvent "Deploying Nested ESXi VM $VMName ..."
        $vm = Import-VApp -Source $NestedESXiApplianceOVA -OvfConfiguration $ovfconfig -Name $VMName -Location $VMCluster -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -Force

        New-LogEvent "Adding vmnic2/vmnic3 to Nested ESXi VMs ..."
        $vmPortGroup = Get-VirtualNetwork -Name $VMNetwork -Location ($cluster | Get-Datacenter)
        if($vmPortGroup.NetworkType -eq "Distributed") {
            $vmPortGroup = Get-VDPortgroup -Name $VMNetwork
            New-NetworkAdapter -VM $vm -Type Vmxnet3 -Portgroup $vmPortGroup.Name -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile -Force
            New-NetworkAdapter -VM $vm -Type Vmxnet3 -Portgroup $vmPortGroup.Name -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile -Force
        } else {
            New-NetworkAdapter -VM $vm -Type Vmxnet3 -NetworkName $vmPortGroup.Name -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile -Force
            New-NetworkAdapter -VM $vm -Type Vmxnet3 -NetworkName $vmPortGroup.Name -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile -Force
        }

        $vm | New-AdvancedSetting -name "ethernet2.filter4.name" -value "dvfilter-maclearn" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile
        $vm | New-AdvancedSetting -Name "ethernet2.filter4.onFailure" -value "failOpen" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile

        $vm | New-AdvancedSetting -name "ethernet3.filter4.name" -value "dvfilter-maclearn" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile
        $vm | New-AdvancedSetting -Name "ethernet3.filter4.onFailure" -value "failOpen" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile

        New-LogEvent "Updating vCPU Count to $NestedESXiWLDvCPU & vMEM to $NestedESXiWLDvMEM GB ..."
        Set-VM -Server $viConnection -VM $vm -NumCpu $NestedESXiWLDvCPU -CoresPerSocket $NestedESXiWLDvCPU -MemoryGB $NestedESXiWLDvMEM -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        New-LogEvent "Updating vSAN Cache VMDK size to $NestedESXiWLDCachingvDisk GB & Capacity VMDK size to $NestedESXiWLDCapacityvDisk GB ..."
        Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 2" | Set-HardDisk -CapacityGB $NestedESXiWLDCachingvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 3" | Set-HardDisk -CapacityGB $NestedESXiWLDCapacityvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        New-LogEvent "Updating vSAN Boot Disk size to $NestedESXiWLDBootDisk GB ..."
        Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 1" | Set-HardDisk -CapacityGB $NestedESXiWLDBootDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        # vSAN ESA requires NVMe Controller
        if($NestedESXiWLDVSANESA) {
            New-LogEvent "Updating storage controller to NVMe for vSAN ESA ..."
            $devices = $vm.ExtensionData.Config.Hardware.Device

            $newControllerKey = -102

            # Reconfigure 1 - Add NVMe Controller & Update Disk Mapping to new controller
            $deviceChanges = @()
            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec

            $scsiController = $devices | where {$_.getType().Name -eq "ParaVirtualSCSIController"}
            $scsiControllerDisks = $scsiController.device

            $nvmeControllerAddSpec = New-Object VMware.Vim.VirtualDeviceConfigSpec
            $nvmeControllerAddSpec.Device = New-Object VMware.Vim.VirtualNVMEController
            $nvmeControllerAddSpec.Device.Key = $newControllerKey
            $nvmeControllerAddSpec.Device.BusNumber = 0
            $nvmeControllerAddSpec.Operation = 'add'
            $deviceChanges+=$nvmeControllerAddSpec

            foreach ($scsiControllerDisk in $scsiControllerDisks) {
                $device = $devices | where {$_.key -eq $scsiControllerDisk}

                $changeControllerSpec = New-Object VMware.Vim.VirtualDeviceConfigSpec
                $changeControllerSpec.Operation = 'edit'
                $changeControllerSpec.Device = $device
                $changeControllerSpec.Device.key = $device.key
                $changeControllerSpec.Device.unitNumber = $device.UnitNumber
                $changeControllerSpec.Device.ControllerKey = $newControllerKey
                $deviceChanges+=$changeControllerSpec
            }

            $spec.deviceChange = $deviceChanges

            $task = $vm.ExtensionData.ReconfigVM_Task($spec)
            $task1 = Get-Task -Id ("Task-$($task.value)")
            $task1 | Wait-Task | Out-Null

            # Reconfigure 2 - Remove PVSCSI Controller
            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $scsiControllerRemoveSpec = New-Object VMware.Vim.VirtualDeviceConfigSpec
            $scsiControllerRemoveSpec.Operation = 'remove'
            $scsiControllerRemoveSpec.Device = $scsiController
            $spec.deviceChange = $scsiControllerRemoveSpec

            $task = $vm.ExtensionData.ReconfigVM_Task($spec)
            $task1 = Get-Task -Id ("Task-$($task.value)")
            $task1 | Wait-Task | Out-Null
        }

        New-LogEvent "Powering On $vmname ..."
        $vm | Start-Vm -RunAsync | Out-Null
    }
}
# --- End WLD Hosts









if($deployNestedESXiVMsForMgmt -eq 1 -or $deployNestedESXiVMsForWLD -eq 1 -or $deployCloudBuilder -eq 1) {
    New-LogEvent "Disconnecting from $VIServer ..."
    Disconnect-VIServer -Server $viConnection -Confirm:$false
}





$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

New-LogEvent "VCF Lab Deployment Complete!"
New-LogEvent "StartTime: $StartTime"
New-LogEvent "EndTime: $EndTime"
New-LogEvent "Duration: $duration minutes to Deploy Nested ESXi, CloudBuilder & initiate VCF Bringup"















# ---------- DNS Automation


function Connect-DNSServer {

    # SSH to DNS Server - MUST HAVE POSH-SSH PowerShell Module Installed 
    $Server   = '192.168.6.1'
    $userName = 'administrator@vcrocs.local'
    $Password = 'VMware1!'

    # The next line is how to create the encrypted password
    $psPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $psPassword

    $Params = @{
        "ComputerName" = $Server
        "Credential"   = $creds
    } # End Params


    # SSH Connection to Server
    $sshSession = Get-SSHSession
    if($sshSession.SessionId -eq 0){
        $output = 'SSH Connection to Server already completed' 
        return $output
    } # End If
    else{
        Write-Host 'Creating new SSH Connection to Server'
        New-SSHSession @Params
    } # End Else

    # Test SSH Connection
    $CheckSSHConnection = Get-SSHSession -SessionId 0
    $output = 'SSH Session: ' + $CheckSSHConnection.Connected
    Write-Output $output
    
} # End Function



$NestedESXiHostnameToIPsForWorkloadDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
    $VMName = $_.Key
    $VMName = $VMName + "." + $VMDomain
    Write-Host "VMname:"$VMName
    
    $VMIPAddress = $_.Value
    Write-Host "IP:"$VMIPAddress

    # Test to make sure DNS record is available
    $reachable = Test-Connection -ComputerName $VMName -Count 1 -Quiet
    if ($reachable) {
        "DNS Name Verifed"
    }
    else {
        "Creating DNS Name ..."
        $results = Connect-DNSServer
        $output = "SSH Server Connected: " + $results
        Write-Host $output

        $sshCommand = "PowerShell -Command " + '"' + "Add-DnsServerResourceRecordA -Name '" +  $VMname + "' -ZoneName '" + $VMDomain + "' -IPv4Address '" + $VMIPAddress + "' -ComputerName '" + $VMDNS + "'" + '"'
        $sshCommand

        $results = Invoke-SSHCommand -SessionId 0 -Command $sshCommand
        #$results.Output


        #Get last Octet of IP address
        #$lastOctet = ($VMIPAddress -match '\.(\d+)$') ? $matches[1] : $null
        #$lastOctet

        #$sshCommand = "PowerShell -Command " + '"' + "Add-DnsServerResourceRecordPtr -Name '" +  $lastOctet + "' -ZoneName '4.168.192.in-addr.arpa' -PtrDomainName '" + $VMName + "' -ComputerName '" + $VMDNS + "'" + '"'
        #$sshCommand

        #$results = Invoke-SSHCommand -SessionId 0 -Command $sshCommand
        #$results.Output

        # Remove SSH Session
        $results = Remove-SSHSession -SessionId 0
    } # End Else

} # End foreach


Resolve-DnsName -Name vcf-m01-esx05.vcrocs.local -Server 192.168.6.1

Add-DnsServerResourceRecordA -Name "dale" -IPv4Address "192.168.4.179" -ZoneName "vcrocs.local" -CreatePtr

