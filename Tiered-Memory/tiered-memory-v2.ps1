# Import the Posh-SSH module
Import-Module Posh-SSH

# Define server details (It's recommended to handle credentials securely, e.g., use a secure vault)
#$server = "192.168.6.103"
$server = "192.168.6.104"

$username = "root"
$password = "VMware1!"  # Consider using Get-Credential or Secure store for passwords

# Convert the password to a SecureString and create a PSCredential object
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Establish an SSH session (Accept the SSH key automatically, but ensure this is acceptable in your security model)
$sshSession = New-SSHSession -ComputerName $server -Credential $credential -AcceptKey

# Define and execute the first SSH command to get the VMXCartelIDs and Display Names
$vmCommand = "esxcli --formatter csv vm process list | cut -d ',' -f 2,5"
$vmResult = Invoke-SSHCommand -SessionId $sshSession.SessionId -Command $vmCommand

# Convert the CSV result into PowerShell objects
$VMXCartelID = $vmResult.Output | ConvertFrom-Csv

# Define and execute the second SSH command to get memory statistics
$memCommand = 'memstats -r vmtier-stats -u mb -s name:memSize:active:tier0Consumed:tier1Consumed'
$memResult = Invoke-SSHCommand -SessionId $sshSession.SessionId -Command $memCommand

# Process the memory statistics output, filter unwanted lines, and remove leading/trailing whitespace
$lines = $memResult.Output -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { 
    $_ -notmatch '^-{2,}|Total|Start|No.|VIRTUAL|Unit|Selected' 
}

# Define regex pattern for parsing the memory statistics rows
$pattern = '^(?<name>\S+)\s+(?<memSize>\d+)\s+(?<active>\d+)\s+(?<tier0Consumed>\d+)\s+(?<tier1Consumed>\d+)$'

# Initialize an array to store parsed memory statistics
$tieredMEM = @()

# Parse each line using the regex pattern and create a custom object for valid lines
foreach ($line in $lines) {
    if ($line -match $pattern) {
        $tieredMEM += [pscustomobject]@{
            Name          = $matches['name']
            MemSizeMB     = [int]$matches['memSize']
            ActiveMB      = [int]$matches['active']
            Tier0Consumed = [int]$matches['tier0Consumed']
            Tier1Consumed = [int]$matches['tier1Consumed']
        }
    }
}

# Remove 'vm.' prefix from each VM Name
$tieredMEM | ForEach-Object { $_.Name = $_.Name -replace '^vm\.', '' }

# Create a hashtable for easy mapping of VMXCartelIDs to Display Names
$vmNameMap = @{}
foreach ($entry in $VMXCartelID) {
    $vmNameMap[$entry.VMXCartelID] = $entry.DisplayName
}

# Replace the Name field in $tieredMEM with the corresponding DisplayName
foreach ($vm in $tieredMEM) {
    if ($vmNameMap.ContainsKey($vm.Name)) {
        $vm.Name = $vmNameMap[$vm.Name]
    }
}

# Filter out rows where the Name starts with "vCLS-"
$tieredMEM = $tieredMEM | Where-Object { $_.Name -notlike "vCLS-*" }

# Display the result in a table format (or export as needed)
$tieredMEM | Format-Table -AutoSize

# Close the SSH session
$removeSSH = Remove-SSHSession -SessionId $sshSession.SessionId