<#
.SYNOPSIS
Collects ESXi hardware and software details from one or more hosts and writes per-host logs.

.DESCRIPTION
Uses Posh-SSH to open an SSH session to each ESXi host, executes a set of inventory
commands, and saves the commands plus their output to a timestamped log file under
the specified output directory. Existing logs for a host are replaced on each run.

.PARAMETER Hosts
One or more ESXi hostnames or IP addresses to query.

.PARAMETER Username
SSH username used to authenticate to each ESXi host.

.PARAMETER Password
SSH password corresponding to the Username.

.PARAMETER OutputDir
Directory where log files will be written (one file per host).

.EXAMPLE
PS> .\\collect-esxi-info.ps1 -Hosts 192.168.6.101,192.168.6.102 -Username root -Password VMware1! -OutputDir outputs

.NOTES
Requires the Posh-SSH module to be installed and available in the session.
#>

param(
    [string[]]$Hosts = @("192.168.6.101"),
    [string]$Username = "root",
    [string]$Password = "VMware1!",
    [string]$OutputDir = "collect-esx-outputs"
)

# Accept comma-separated host strings (e.g., "h1,h2") by normalizing to an array early.
if ($Hosts.Count -eq 1 -and $Hosts[0] -match ',') {
    $Hosts = $Hosts[0].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

# Early validation hook for PowerShell availability.
Get-Command -Name Import-Module -ErrorAction Stop | Out-Null

# Ensure Posh-SSH is present so we can open SSH sessions to ESXi hosts.
Import-Module Posh-SSH -ErrorAction Stop

# Build a reusable credential object from the supplied username/password.
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)

# Create the output directory once; suppress errors if it already exists.
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# Warn early if running on a Posh-SSH build that dropped legacy key exchanges some older ESXi versions still need.
$poshSshVersion = (Get-Module Posh-SSH).Version
if ($poshSshVersion.Major -ge 3) {
    Write-Warning "Posh-SSH $poshSshVersion may not negotiate with legacy ESXi SSH stacks. If you hit 'Key exchange negotiation failed', install Posh-SSH 2.3.0: Install-Module Posh-SSH -RequiredVersion 2.3.0"
}

foreach ($esxiHost in $Hosts) {
    # For each host, start with a fresh log file that captures all collected details.
    $logPath = Join-Path $OutputDir "$($esxiHost)-esxi-details.txt"
    Remove-Item $logPath -ErrorAction SilentlyContinue

    # Establish SSH session (accepting unknown host keys) using the provided credential.
    try {
        $session = New-SSHSession `
            -ComputerName $esxiHost `
            -Credential $credential `
            -AcceptKey `
            -Force `
            -ErrorAction Stop
    } catch {
        Write-Warning "SSH session to $esxiHost failed: $($_.Exception.Message)"
        continue
    }

    try {
        # Stamp the log with collection time and host identifier.
        Add-Content $logPath ("Collected {0:yyyy-MM-dd HH:mm:ss} from {1}" -f (Get-Date), $esxiHost)
        Add-Content $logPath ""

        # Wrapper to run a remote command, mirror the command into the log, and append its output.
        function Invoke-EsxiCommand([string]$command) {
            Add-Content $logPath ">>> $command"
            $result = Invoke-SSHCommand -SessionId $session.SessionId -Command $command -ErrorAction Stop
            if ($result.Output) {
                Add-Content $logPath $result.Output
            } else {
                Add-Content $logPath "(no output)"
            }
            Add-Content $logPath ""
            return $result.Output
        }

        # Basic host/version, BIOS/CPU, and memory inventory.
        Invoke-EsxiCommand "vmware -vl"
        Invoke-EsxiCommand "vsish -e get /hardware/bios/dmiInfo"
        Invoke-EsxiCommand "vsish -e get /hardware/cpu/cpuModelName"
        Invoke-EsxiCommand "vsish -e get /hardware/cpu/cpuInfo"
        Invoke-EsxiCommand "vsish -e get /memory/comprehensive"

        # Capture storage adapter summary and deep lists.
        $scsiSummary = Invoke-EsxiCommand "esxcfg-scsidevs -a"
        Invoke-EsxiCommand "esxcfg-scsidevs -A"
        Invoke-EsxiCommand "esxcfg-scsidevs -c"

        # Capture NIC inventory and later derive driver names.
        $networkList = Invoke-EsxiCommand "esxcli network nic list"

        # Quick PCI dump around Ethernet devices for vendor/context.
        Invoke-EsxiCommand "lspci -v | grep -i Ethernet -A2"

        # Run lspci filtered by each storage driver discovered above.
        $storageDrivers = $scsiSummary |
            Where-Object { $_ -and $_ -notmatch '^HBA' } |
            ForEach-Object {
                $parts = ($_ -split '\s+')
                if ($parts.Count -ge 2) { $parts[1] }
            } |
            Where-Object { $_ } |
            Sort-Object -Unique

        foreach ($driver in $storageDrivers) {
            # Show PCI entries tied to each storage driver.
            Invoke-EsxiCommand "lspci -p | grep -i $driver"
        }

        # Run lspci filtered by each network driver discovered above.
        $nicDrivers = $networkList |
            Where-Object { $_ -and $_ -notmatch '^Name' -and $_ -notmatch '^---' } |
            ForEach-Object {
                $parts = ($_ -split '\s+')
                if ($parts.Count -ge 3) { $parts[2] }
            } |
            Where-Object { $_ } |
            Sort-Object -Unique

        foreach ($driver in $nicDrivers) {
            # Show PCI entries tied to each network driver.
            Invoke-EsxiCommand "lspci -p | grep -i $driver"
        }

        # Adapter inventory and full SCSI device list.
        Invoke-EsxiCommand "esxcli storage core adapter list"
        Invoke-EsxiCommand "esxcfg-scsidevs -l"
    }
    finally {
        # Always cleanly close the SSH session before moving to the next host.
        if ($session -and $session.SessionId) {
            Remove-SSHSession -SessionId $session.SessionId | Out-Null
            $session = $null
        }
    }
}
