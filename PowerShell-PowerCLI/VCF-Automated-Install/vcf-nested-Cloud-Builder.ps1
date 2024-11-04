# Script to create Cloud Builder VM and json files
# Author: Dale Hassinger
# Based on Script by: William Lam



# vCenter Server used to deploy VMware Cloud Foundation Lab
$VIServer   = "192.168.6.100"
$VIUsername = "administrator@vcrocs.local"
$VIPassword = "VMware1!"



# Full Path to both the Nested ESXi & Cloud Builder OVA
#$NestedESXiApplianceOVA = "/Users/dalehassinger/Downloads/Nested_ESXi8.0u3b_Appliance_Template_v1.ova"
$CloudBuilderOVA = "/Users/dalehassinger/Downloads/VMware-Cloud-Builder-5.2.1.0-24307856_OVF10.ova"



# VCF Licenses or leave blank for evaluation mode (requires VCF 5.1.1 or later)
$VCSALicense = ""
$ESXILicense = ""
$VSANLicense = ""
$NSXLicense  = ""



# VCF Configurations
$VCFManagementDomainPoolName  = "vcf-m01-rp01"
$VCFManagementDomainJSONFile  = "vcf-mgmt.json"
$VCFWorkloadDomainUIJSONFile  = "vcf-commission-host-ui.json"
$VCFWorkloadDomainAPIJSONFile = "vcf-commission-host-api.json"



# Cloud Builder Configurations
$CloudbuilderVMHostname    = "vcf-m01-cb01"
$CloudbuilderFQDN          = "vcf-m01-cb01.vcrocs.local"
$CloudbuilderIP            = "192.168.4.180"
$CloudbuilderAdminUsername = "admin"
$CloudbuilderAdminPassword = "VMw@re123!VMw@re123!"
$CloudbuilderRootPassword  = "VMw@re123!VMw@re123!"



# SDDC Manager Configuration
$SddcManagerHostname      = "vcf-m01-sddcm01"
$SddcManagerIP            = "192.168.4.181"
$SddcManagerVcfPassword   = "VMware1!VMware1!"
$SddcManagerRootPassword  = "VMware1!VMware1!"
$SddcManagerRestPassword  = "VMware1!VMware1!"
$SddcManagerLocalPassword = "VMware1!VMware1!"




$NestedESXiHostnameToIPsForManagementDomain = @{
    "VCF-DDC-ESX185" = "192.168.4.185"
}



<#
    "VCF-DDC-ESX186"   = "192.168.4.186"
    "VCF-DDC-ESX187"   = "192.168.4.187"
    "VCF-DDC-ESX188"   = "192.168.4.188"



# Nested ESXi VMs for Management Domain
$NestedESXiHostnameToIPsForManagementDomain = @{
    "vcf-m01-esx01"   = "192.168.4.185"
    "vcf-m01-esx02"   = "192.168.4.186"
    "vcf-m01-esx03"   = "192.168.4.187"
    "vcf-m01-esx04"   = "192.168.4.188"
}
#>

<#
# Nested ESXi VMs for Workload Domain
$NestedESXiHostnameToIPsForWorkloadDomain = @{
    "vcf-m01-esx05"   = "192.168.4.189"
    "vcf-m01-esx06"   = "192.168.4.190"
    "vcf-m01-esx07"   = "192.168.4.191"
    "vcf-m01-esx08"   = "192.168.4.192"
}
#>



# Nested ESXi VM Resources for Management Domain
$NestedESXiMGMTvCPU          = "12"
$NestedESXiMGMTvMEM          = "78" #GB
$NestedESXiMGMTCachingvDisk  = "4" #GB
$NestedESXiMGMTCapacityvDisk = "500" #GB
$NestedESXiMGMTBootDisk      = "32" #GB



# Nested ESXi VM Resources for Workload Domain
$NestedESXiWLDVSANESA       = $false
$NestedESXiWLDvCPU          = "8"
$NestedESXiWLDvMEM          = "36" #GB
$NestedESXiWLDCachingvDisk  = "4" #GB
$NestedESXiWLDCapacityvDisk = "200" #GB
$NestedESXiWLDBootDisk      = "32" #GB



# ESXi Network Configuration
$NestedESXiManagementNetworkCidr = "192.168.4.0/22" # should match $VMNetwork configuration
$NestedESXivMotionNetworkCidr    = "192.168.8.0/24"
$NestedESXivSANNetworkCidr       = "192.168.9.0/24"
$NestedESXiNSXTepNetworkCidr     = "192.168.10.0/24"



# vCenter Configuration
$VCSAName         = "vcf-m01-vc01"
$VCSAIP           = "192.168.4.182"
$VCSARootPassword = "VMware1!"
$VCSASSOPassword  = "VMware1!"
$EnableVCLM       = $true



# NSX Configuration
$NSXManagerSize          = "medium"
$NSXManagerVIPHostname   = "vcf-m01-nsx01"
$NSXManagerVIPIP         = "192.168.4.183"
$NSXManagerNode1Hostname = "vcf-m01-nsx01a"
$NSXManagerNode1IP       = "192.168.4.184"
$NSXRootPassword         = "VMware1!VMware1!"
$NSXAdminPassword        = "VMware1!VMware1!"
$NSXAuditPassword        = "VMware1!VMware1!"



# General Deployment Configuration for Nested ESXi & Cloud Builder VM
# This is information from you current vCenter lab environment
$VMDatacenter = "Datacenter-DB-01"
$VMCluster    = "VCF_LAB"
$VMNetwork    = "VMs"
$VMDatastore  = "ESX-04-2TB"
$VMNetmask    = "255.255.252.0"
$VMGateway    = "192.168.4.1"
$VMDNS        = "192.168.6.1"
$VMNTP        = "time.google.com"
$VMPassword   = "VMware1!"
$VMDomain     = "vcrocs.local"
$VMSyslog     = "192.168.6.94"
$VMFolder     = "VCF-VMs"










#### DO NOT EDIT BEYOND HERE ####

$verboseLogFile    = "vcf-lab-deployment.log"
$random_string     = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$VAppName          = "Nested-VCF-Lab-$random_string"
$SeparateNSXSwitch = $false
$VCFVersion        = ""

$preCheck                   = 1
$confirmDeployment          = 1
$deployNestedESXiVMsForMgmt = 1

# WLD Setup
$deployNestedESXiVMsForWLD     = 0
$deployCloudBuilder            = 1
$moveVMsIntovApp               = 1
$generateMgmJson               = 1
$startVCFBringup               = 0
$generateWldHostCommissionJson = 1
$uploadVCFNotifyScript         = 0

$srcNotificationScript = "vcf-bringup-notification.sh"
$dstNotificationScript = "/root/vcf-bringup-notification.sh"

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
} # End Function



if($preCheck -eq 1) {
    # Detect VCF version based on Cloud Builder OVA (support is 5.1.0+)
    if($CloudBuilderOVA -match "5.2.0" -or $CloudBuilderOVA -match "5.2.1") {
        $VCFVersion = "5.2.0"
    } elseif($CloudBuilderOVA -match "5.1.1") {
        $VCFVersion = "5.1.1"
    } elseif($CloudBuilderOVA -match "5.1.0") {
        $VCFVersion = "5.1.0"
    } else {
        $VCFVersion = $null
    }

    if($VCFVersion -eq $null) {
        Write-Host -ForegroundColor Red "`nOnly VCF 5.1.0+ is currently supported ...`n"
        exit
    }

    if($VCFVersion -ge "5.2.0") {
        write-host "here"
        if( $CloudbuilderAdminPassword.ToCharArray().count -lt 15 -or $CloudbuilderRootPassword.ToCharArray().count -lt 15) {
            Write-Host -ForegroundColor Red "`nCloud Builder passwords must be 15 characters or longer ...`n"
            exit
        }
    }

    if(!(Test-Path $NestedESXiApplianceOVA)) {
        Write-Host -ForegroundColor Red "`nUnable to find $NestedESXiApplianceOVA ...`n"
        exit
    }

    if(!(Test-Path $CloudBuilderOVA)) {
        Write-Host -ForegroundColor Red "`nUnable to find $CloudBuilderOVA ...`n"
        exit
    }

    if($PSVersionTable.PSEdition -ne "Core") {
        Write-Host -ForegroundColor Red "`tPowerShell Core was not detected, please install that before continuing ... `n"
        exit
    }
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

    if($deployNestedESXiVMsForMgmt -eq 1) {
        Write-Host -ForegroundColor Yellow "`n---- vESXi Configuration for VCF Management Domain ----"
        Write-Host -NoNewline -ForegroundColor Green "# of Nested ESXi VMs: "
        Write-Host -ForegroundColor White $NestedESXiHostnameToIPsForManagementDomain.count
        Write-Host -NoNewline -ForegroundColor Green "IP Address(s): "
        Write-Host -ForegroundColor White $NestedESXiHostnameToIPsForManagementDomain.Values
        Write-Host -NoNewline -ForegroundColor Green "vCPU: "
        Write-Host -ForegroundColor White $NestedESXiMGMTvCPU
        Write-Host -NoNewline -ForegroundColor Green "vMEM: "
        Write-Host -ForegroundColor White "$NestedESXiMGMTvMEM GB"
        Write-Host -NoNewline -ForegroundColor Green "Caching VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiMGMTCachingvDisk GB"
        Write-Host -NoNewline -ForegroundColor Green "Capacity VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiMGMTCapacityvDisk GB"
    } # End If

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
    } # End If

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

} # End If









if($deployNestedESXiVMsForMgmt -eq 1 -or $deployNestedESXiVMsForWLD -eq 1 -or $deployCloudBuilder -eq 1 -or $moveVMsIntovApp -eq 1) {
    New-LogEvent "Connecting to Management vCenter Server $VIServer ..."
    $viConnection = Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue -Protocol https -Force

    $datastore = Get-Datastore -Server $viConnection -Name $VMDatastore | Select -First 1
    $cluster = Get-Cluster -Server $viConnection -Name $VMCluster
    $vmhost = $cluster | Get-VMHost | Get-Random -Count 1
} # End if






# Start Create Cloud Builder VM
if($deployCloudBuilder -eq 1) {
    $ovfconfig = Get-OvfConfiguration $CloudBuilderOVA

    $networkMapLabel = ($ovfconfig.ToHashTable().keys | where {$_ -Match "NetworkMapping"}).replace("NetworkMapping.","").replace("-","_").replace(" ","_")
    $ovfconfig.NetworkMapping.$networkMapLabel.value = $VMNetwork
    $ovfconfig.common.guestinfo.hostname.value = $CloudbuilderFQDN
    $ovfconfig.common.guestinfo.ip0.value = $CloudbuilderIP
    $ovfconfig.common.guestinfo.netmask0.value = $VMNetmask
    $ovfconfig.common.guestinfo.gateway.value = $VMGateway
    $ovfconfig.common.guestinfo.DNS.value = $VMDNS
    $ovfconfig.common.guestinfo.domain.value = $VMDomain
    $ovfconfig.common.guestinfo.searchpath.value = $VMDomain
    $ovfconfig.common.guestinfo.ntp.value = $VMNTP
    $ovfconfig.common.guestinfo.ADMIN_USERNAME.value = $CloudbuilderAdminUsername
    $ovfconfig.common.guestinfo.ADMIN_PASSWORD.value = $CloudbuilderAdminPassword
    $ovfconfig.common.guestinfo.ROOT_PASSWORD.value = $CloudbuilderRootPassword

    New-LogEvent "Deploying Cloud Builder VM $CloudbuilderVMHostname ..."
    $vm = Import-VApp -Source $CloudBuilderOVA -OvfConfiguration $ovfconfig -Name $CloudbuilderVMHostname -Location $VMCluster -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -Force

    New-LogEvent "Powering On $CloudbuilderVMHostname ..."
    $vm | Start-Vm -RunAsync | Out-Null
}





# Move VMs into vApp. Keeps all the VCF VMs together.
if($moveVMsIntovApp -eq 1) {
    # Check whether DRS is enabled as that is required to create vApp
    if((Get-Cluster -Server $viConnection $cluster).DrsEnabled) {
        New-LogEvent "Creating vApp $VAppName ..."
        $rp = Get-ResourcePool -Name Resources -Location $cluster
        $VApp = New-VApp -Name $VAppName -Server $viConnection -Location $cluster

        if(-Not (Get-Folder $VMFolder -ErrorAction Ignore)) {
            New-LogEvent "Creating VM Folder $VMFolder ..."
            $folder = New-Folder -Name $VMFolder -Server $viConnection -Location (Get-Datacenter $VMDatacenter | Get-Folder vm)
        }

        if($deployNestedESXiVMsForMgmt -eq 1) {
            New-LogEvent "Moving Nested ESXi VMs into $VAppName vApp ..."
            $NestedESXiHostnameToIPsForManagementDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
                $vm = Get-VM -Name $_.Key -Server $viConnection -Location $cluster | where{$_.ResourcePool.Id -eq $rp.Id}
                Move-VM -VM $vm -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
            }
        }

        if($deployNestedESXiVMsForWLD -eq 1) {
            New-LogEvent "Moving Nested ESXi VMs into $VAppName vApp ..."
            $NestedESXiHostnameToIPsForWorkloadDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
                $vm = Get-VM -Name $_.Key -Server $viConnection -Location $cluster | where{$_.ResourcePool.Id -eq $rp.Id}
                Move-VM -VM $vm -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
            }
        }

        if($deployCloudBuilder -eq 1) {
            $cloudBuilderVM = Get-VM -Name $CloudbuilderVMHostname -Server $viConnection -Location $cluster | where{$_.ResourcePool.Id -eq $rp.Id}
            New-LogEvent "Moving $CloudbuilderVMHostname into $VAppName vApp ..."
            Move-VM -VM $cloudBuilderVM -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }

        New-LogEvent "Moving $VAppName to VM Folder $VMFolder ..."
        Move-VApp -Server $viConnection $VAppName -Destination (Get-Folder -Server $viConnection $VMFolder) | Out-File -Append -LiteralPath $verboseLogFile
    } else {
        New-LogEvent "vApp $VAppName will NOT be created as DRS is NOT enabled on vSphere Cluster ${cluster} ..."
    }
}









# Create Cloud Builder json file used to deploy VCF

if($generateMgmJson -eq 1) {
    if($SeparateNSXSwitch) { $useNSX = "false" } else { $useNSX = "true" }

    $esxivMotionNetwork = $NestedESXivMotionNetworkCidr.split("/")[0]
    $esxivMotionNetworkOctects = $esxivMotionNetwork.split(".")
    $esxivMotionGateway = ($esxivMotionNetworkOctects[0..2] -join '.') + ".1"
    $esxivMotionStart = ($esxivMotionNetworkOctects[0..2] -join '.') + ".101"
    $esxivMotionEnd = ($esxivMotionNetworkOctects[0..2] -join '.') + ".118"

    $esxivSANNetwork = $NestedESXivSANNetworkCidr.split("/")[0]
    $esxivSANNetworkOctects = $esxivSANNetwork.split(".")
    $esxivSANGateway = ($esxivSANNetworkOctects[0..2] -join '.') + ".1"
    $esxivSANStart = ($esxivSANNetworkOctects[0..2] -join '.') + ".101"
    $esxivSANEnd = ($esxivSANNetworkOctects[0..2] -join '.') + ".118"

    $esxiNSXTepNetwork = $NestedESXiNSXTepNetworkCidr.split("/")[0]
    $esxiNSXTepNetworkOctects = $esxiNSXTepNetwork.split(".")
    $esxiNSXTepGateway = ($esxiNSXTepNetworkOctects[0..2] -join '.') + ".1"
    $esxiNSXTepStart = ($esxiNSXTepNetworkOctects[0..2] -join '.') + ".101"
    $esxiNSXTepEnd = ($esxiNSXTepNetworkOctects[0..2] -join '.') + ".118"

    $hostSpecs = @()
    $count = 1
    $NestedESXiHostnameToIPsForManagementDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
        $VMName = $_.Key
        $VMIPAddress = $_.Value

        $hostSpec = [ordered]@{
            "association" = "vcf-m01-dc01"
            "ipAddressPrivate" = [ordered]@{
                "ipAddress" = $VMIPAddress
                "cidr" = $NestedESXiManagementNetworkCidr
                "gateway" = $VMGateway
            }
            "hostname" = $VMName
            "credentials" = [ordered]@{
                "username" = "root"
                "password" = $VMPassword
            }
            "sshThumbprint" = "SHA256:DUMMY_VALUE"
            "sslThumbprint" = "SHA25_DUMMY_VALUE"
            "vSwitch" = "vSwitch0"
            "serverId" = "host-$count"
        }
        $hostSpecs+=$hostSpec
        $count++
    }

    $vcfConfig = [ordered]@{
        "subscriptionLicensing" = $false
        "skipEsxThumbprintValidation" = $true
        "managementPoolName" = $VCFManagementDomainPoolName
        "sddcId" = "vcf-m01"
        "taskName" = "workflowconfig/workflowspec-ems.json"
        "esxLicense" = "$ESXILicense"
        "ceipEnabled" = $true
        "ntpServers" = @($VMNTP)
        "dnsSpec" = [ordered]@{
            "subdomain" = $VMDomain
            "domain" = $VMDomain
            "nameserver" = $VMDNS
        }
        "sddcManagerSpec" = [ordered]@{
            "ipAddress" = $SddcManagerIP
            "netmask" = $VMNetmask
            "hostname" = $SddcManagerHostname
            "localUserPassword" = "$SddcManagerLocalPassword"
            "vcenterId" = "vcenter-1"
            "secondUserCredentials" = [ordered]@{
                "username" = "vcf"
                "password" = $SddcManagerVcfPassword
            }
            "rootUserCredentials" = [ordered]@{
                "username" = "root"
                "password" = $SddcManagerRootPassword
            }
            "restApiCredentials" = [ordered]@{
                "username" = "admin"
                "password" = $SddcManagerRestPassword
            }
        }
        "networkSpecs" = @(
            [ordered]@{
                "networkType" = "MANAGEMENT"
                "subnet" = $NestedESXiManagementNetworkCidr
                "gateway" = $VMGateway
                "vlanId" = "0"
                "mtu" = "1500"
                "portGroupKey" = "vcf-m01-cl01-vds01-pg-mgmt"
                "standbyUplinks" = @()
                "activeUplinks" = @("uplink1","uplink2")
            }
            [ordered]@{
                "networkType" = "VMOTION"
                "subnet" = $NestedESXivMotionNetworkCidr
                "gateway" = $esxivMotionGateway
                "vlanId" = "0"
                "mtu" = "9000"
                "portGroupKey" = "vcf-m01-cl01-vds01-pg-vmotion"
                "association" = "vcf-m01-dc01"
                "includeIpAddressRanges" = @(@{"startIpAddress" = $esxivMotionStart;"endIpAddress" = $esxivMotionEnd})
                "standbyUplinks" = @()
                "activeUplinks" = @("uplink1","uplink2")
            }
            [ordered]@{
                "networkType" = "VSAN"
                "subnet" = $NestedESXivSANNetworkCidr
                "gateway"= $esxivSANGateway
                "vlanId" = "0"
                "mtu" = "9000"
                "portGroupKey" = "vcf-m01-cl01-vds01-pg-vsan"
                "includeIpAddressRanges" = @(@{"startIpAddress" = $esxivSANStart;"endIpAddress" = $esxivSANEnd})
                "standbyUplinks" = @()
                "activeUplinks" = @("uplink1","uplink2")
            }
        )
        "nsxtSpec" = [ordered]@{
            "nsxtManagerSize" = $NSXManagerSize
            "nsxtManagers" = @(@{"hostname" = $NSXManagerNode1Hostname;"ip" = $NSXManagerNode1IP})
            "rootNsxtManagerPassword" = $NSXRootPassword
            "nsxtAdminPassword" = $NSXAdminPassword
            "nsxtAuditPassword" = $NSXAuditPassword
            "rootLoginEnabledForNsxtManager" = $true
            "sshEnabledForNsxtManager" = $true
            "overLayTransportZone" = [ordered]@{
                "zoneName" = "vcf-m01-tz-overlay01"
                "networkName" = "netName-overlay"
            }
            "vlanTransportZone" = [ordered]@{
                "zoneName" = "vcf-m01-tz-vlan01"
                "networkName" = "netName-vlan"
            }
            "vip" = $NSXManagerVIPIP
            "vipFqdn" = $NSXManagerVIPHostname
            "nsxtLicense" = $NSXLicense
            "transportVlanId" = "2005"
            "ipAddressPoolSpec" = [ordered]@{
                "name" = "vcf-m01-c101-tep01"
                "description" = "ESXi Host Overlay TEP IP Pool"
                "subnets" = @(
                    @{
                        "ipAddressPoolRanges" = @(@{"start" = $esxiNSXTepStart;"end" = $esxiNSXTepEnd})
                        "cidr" = $NestedESXiNSXTepNetworkCidr
                        "gateway" = $esxiNSXTepGateway
                    }
                )
            }
        }
        "vsanSpec" = [ordered]@{
            "vsanName" = "vsan-1"
            "vsanDedup" = "false"
            "licenseFile" = $VSANLicense
            "datastoreName" = "vcf-m01-cl01-ds-vsan01"
        }
        "dvSwitchVersion" = "7.0.0"
        "dvsSpecs" = @(
            [ordered]@{
                "dvsName" = "vcf-m01-cl01-vds01"
                "vcenterId" = "vcenter-1"
                "vmnics" = @("vmnic0","vmnic1")
                "mtu" = "9000"
                "networks" = @(
                    "MANAGEMENT",
                    "VMOTION",
                    "VSAN"
                )
                "niocSpecs" = @(
                    @{"trafficType"="VSAN";"value"="HIGH"}
                    @{"trafficType"="VMOTION";"value"="LOW"}
                    @{"trafficType"="VDP";"value"="LOW"}
                    @{"trafficType"="VIRTUALMACHINE";"value"="HIGH"}
                    @{"trafficType"="MANAGEMENT";"value"="NORMAL"}
                    @{"trafficType"="NFS";"value"="LOW"}
                    @{"trafficType"="HBR";"value"="LOW"}
                    @{"trafficType"="FAULTTOLERANCE";"value"="LOW"}
                    @{"trafficType"="ISCSI";"value"="LOW"}
                )
                "isUsedByNsxt" = $useNSX
            }
        )
        "clusterSpec" = [ordered]@{
            "clusterName" = "vcf-m01-cl01"
            "vcenterName" = "vcenter-1"
            "clusterEvcMode" = ""
            "hostFailuresToTolerate" = 0
            "vmFolders" = [ordered] @{
                "MANAGEMENT" = "vcf-m01-fd-mgmt"
                "NETWORKING" = "vcf-m01-fd-nsx"
                "EDGENODES" = "vcf-m01-fd-edge"
            }
            "clusterImageEnabled" = $EnableVCLM
        }
        "resourcePoolSpecs" =@(
            [ordered]@{
                "name" = "vcf-m01-cl01-rp-sddc-mgmt"
                "type" = "management"
                "cpuReservationPercentage" = 0
                "cpuLimit" = -1
                "cpuReservationExpandable" = $true
                "cpuSharesLevel" = "normal"
                "cpuSharesValue" = 0
                "memoryReservationMb" = 0
                "memoryLimit" = -1
                "memoryReservationExpandable" = $true
                "memorySharesLevel" = "normal"
                "memorySharesValue" = 0
            }
            [ordered]@{
                "name" = "vcf-m01-cl01-rp-sddc-edge"
                "type" = "network"
                "cpuReservationPercentage" = 0
                "cpuLimit" = -1
                "cpuReservationExpandable" = $true
                "cpuSharesLevel" = "normal"
                "cpuSharesValue" = 0
                "memoryReservationPercentage" = 0
                "memoryLimit" = -1
                "memoryReservationExpandable" = $true
                "memorySharesLevel" = "normal"
                "memorySharesValue" = 0
            }
            [ordered]@{
                "name" = "vcf-m01-cl01-rp-user-edge"
                "type" = "compute"
                "cpuReservationPercentage" = 0
                "cpuLimit" = -1
                "cpuReservationExpandable" = $true
                "cpuSharesLevel" = "normal"
                "cpuSharesValue" = 0
                "memoryReservationPercentage" = 0
                "memoryLimit" = -1
                "memoryReservationExpandable" = $true
                "memorySharesLevel" = "normal"
                "memorySharesValue" = 0
            }
            [ordered]@{
                "name" = "vcf-m01-cl01-rp-user-vm"
                "type" = "compute"
                "cpuReservationPercentage" = 0
                "cpuLimit" = -1
                "cpuReservationExpandable" = $true
                "cpuSharesLevel" = "normal"
                "cpuSharesValue" = 0
                "memoryReservationPercentage" = 0
                "memoryLimit" = -1
                "memoryReservationExpandable" = $true
                "memorySharesLevel" = "normal"
                "memorySharesValue" = 0
            }
        )
        "pscSpecs" = @(
            [ordered]@{
                "pscId" = "psc-1"
                "vcenterId" = "vcenter-1"
                "adminUserSsoPassword" = $VCSASSOPassword
                "pscSsoSpec" = @{"ssoDomain"="vsphere.local"}
            }
        )
        "vcenterSpec" = [ordered]@{
            "vcenterIp" = $VCSAIP
            "vcenterHostname" = $VCSAName
            "vcenterId" = "vcenter-1"
            "licenseFile" = $VCSALicense
            "vmSize" = "tiny"
            "storageSize" = ""
            "rootVcenterPassword" = $VCSARootPassword
        }
        "hostSpecs" = $hostSpecs
        "excludedComponents" = @("NSX-V", "AVN", "EBGP")
    }

    if($SeparateNSXSwitch) {
        $sepNsxSwitchSpec = [ordered]@{
            "dvsName" = "vcf-m01-nsx-vds01"
            "vcenterId" = "vcenter-1"
            "vmnics" = @("vmnic2","vmnic3")
            "mtu" = 9000
            "networks" = @()
            "isUsedByNsxt" = $true

        }
        $vcfConfig.dvsSpecs+=$sepNsxSwitchSpec
    }

    # License Later feature only applicable for VCF 5.1.1 and later
    if($VCFVersion -ge "5.1.1") {
        if($VCSALicense -eq "" -and $ESXILicense -eq "" -and $VSANLicense -eq "" -and $NSXLicense -eq "") {
            $EvaluationMode = $true
        } else {
            $EvaluationMode = $false
        }
        $vcfConfig.add("deployWithoutLicenseKeys",$EvaluationMode)
    }

    New-LogEvent "Generating Cloud Builder VCF Management Domain configuration deployment file $VCFManagementDomainJSONFile"
    $vcfConfig | ConvertTo-Json -Depth 20 | Out-File -LiteralPath $VCFManagementDomainJSONFile
}








# I am not sure if this is needed for my lab. I want to create WRKLD manually first time to learn the steps.
<#
if($generateWldHostCommissionJson -eq 1) {
    New-LogEvent "Generating Cloud Builder VCF Workload Domain Host Commission file $VCFWorkloadDomainUIJSONFile and $VCFWorkloadDomainAPIJSONFile for SDDC Manager UI and API"

    $commissionHostsUI= @()
    $commissionHostsAPI= @()
    $NestedESXiHostnameToIPsForWorkloadDomain.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
        $hostFQDN = $_.Key + "." + $VMDomain

        $tmp1 = [ordered] @{
            "hostfqdn" = $hostFQDN;
            "username" = "root";
            "password" = $VMPassword;
            "networkPoolName" = "$VCFManagementDomainPoolName";
            "storageType" = "VSAN";
        }
        $commissionHostsUI += $tmp1

        $tmp2 = [ordered] @{
            "fqdn" = $hostFQDN;
            "username" = "root";
            "password" = $VMPassword;
            "networkPoolId" = "TBD";
            "storageType" = "VSAN";
        }
        $commissionHostsAPI += $tmp2
    }

    $vcfCommissionHostConfigUI = @{
        "hostsSpec" = $commissionHostsUI
    }

    $vcfCommissionHostConfigUI | ConvertTo-Json -Depth 2 | Out-File -LiteralPath $VCFWorkloadDomainUIJSONFile
    $commissionHostsAPI | ConvertTo-Json -Depth 2 | Out-File -LiteralPath $VCFWorkloadDomainAPIJSONFile
}

if($startVCFBringup -eq 1) {
    New-LogEvent "Starting VCF Deployment Bringup ..."

    New-LogEvent "Waiting for Cloud Builder to be ready ..."
    while(1) {
        $pair = "${CloudbuilderAdminUsername}:${CloudbuilderAdminPassword}"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)

        try {
            if($PSVersionTable.PSEdition -eq "Core") {
                $requests = Invoke-WebRequest -Uri "https://$($CloudbuilderIP)/v1/sddcs" -Method GET -SkipCertificateCheck -TimeoutSec 5 -Headers @{"Authorization"="Basic $base64"}
            } else {
                $requests = Invoke-WebRequest -Uri "https://$($CloudbuilderIP)/v1/sddcs" -Method GET -TimeoutSec 5 -Headers @{"Authorization"="Basic $base64"} -SkipCertificateCheck
            }
            if($requests.StatusCode -eq 200) {
                New-LogEvent "Cloud Builder is now ready!"
                break
            }
        }
        catch {
            New-LogEvent "Cloud Builder is not ready yet, sleeping for 120 seconds ..."
            sleep 120
        }
    }
}



    <#
    New-LogEvent "Submitting VCF Bringup request ..."

    $inputJson = Get-Content -Raw $VCFManagementDomainJSONFile
    $pwd = ConvertTo-SecureString $CloudbuilderAdminPassword -AsPlainText -Force
    $cred = New-Object Management.Automation.PSCredential ($CloudbuilderAdminUsername,$pwd)
    $bringupAPIParms = @{
        Uri         = "https://${CloudbuilderIP}/v1/sddcs"
        Method      = 'POST'
        Body        = $inputJson
        ContentType = 'application/json'
        Credential = $cred
    }
    $bringupAPIReturn = Invoke-RestMethod @bringupAPIParms -SkipCertificateCheck
    New-LogEvent "Open browser to the VMware Cloud Builder UI (https://${CloudbuilderFQDN}) to monitor deployment progress ..."
}


if($startVCFBringup -eq 1 -and $uploadVCFNotifyScript -eq 1) {
    if(Test-Path $srcNotificationScript) {
        $cbVM = Get-VM -Server $viConnection $CloudbuilderFQDN

        New-LogEvent "Uploading VCF notification script $srcNotificationScript to $dstNotificationScript on Cloud Builder appliance ..."
        Copy-VMGuestFile -Server $viConnection -VM $cbVM -Source $srcNotificationScript -Destination $dstNotificationScript -LocalToGuest -GuestUser "root" -GuestPassword $CloudbuilderRootPassword | Out-Null
        Invoke-VMScript -Server $viConnection -VM $cbVM -ScriptText "chmod +x $dstNotificationScript" -GuestUser "root" -GuestPassword $CloudbuilderRootPassword -SkipCertificateCheck | Out-Null

        New-LogEvent "Configuring crontab to run notification check script every 15 minutes ..."
        Invoke-VMScript -Server $viConnection -VM $cbVM -ScriptText "echo '*/15 * * * * $dstNotificationScript' > /var/spool/cron/root" -GuestUser "root" -GuestPassword $CloudbuilderRootPassword -SkipCertificateCheck | Out-Null
    }
}
#>









# Disconnect from vCenter
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

