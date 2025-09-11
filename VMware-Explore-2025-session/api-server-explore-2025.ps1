# API Server for Home Lab Use and a Nice way to see how PowerShell can be used.
# Created By: Dale Hassinger

param(
    [int]$port = 8081
)

# Ensure required modules are installed before proceeding
$requiredModules = @("powershell-yaml", "VMware.PowerCLI")
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "$module is not installed. Install it using 'Install-Module $module'." -ForegroundColor Red
        exit
    }
}

# Read YAML configuration
$cfgFile = "Home-Lab-Config.yaml"
$cfg = Get-Content -Path $cfgFile -Raw | ConvertFrom-Yaml

$cancelled = $false
$null = Register-EngineEvent -SourceIdentifier ConsoleBreak -Action {
    #Write-Host "`nCtrl+C detected. Stopping server..."
    New-LogEvent -message "`nCtrl+C detected. Stopping server..." -level "warn"
    $global:cancelled = $true
}


Function New-LogEvent {
    param(
        [string]$message,
        [string]$level #= "info"
    )
    
    $timeStamp = Get-Date -Format "MM-dd-yyyy HH:mm:ss"

    switch ($level.ToLower()) {
        "info" {
            Write-Host "[$timeStamp] $message" -ForegroundColor Green
        }
        "warn" {
            Write-Host "[$timeStamp] $message" -ForegroundColor Red
        }
        default {
            Write-Host "[$timeStamp] $message" -ForegroundColor Yellow
        }
    } # End switch

} # End Function



function Get-ApiResponse {
    param (
        [string]$method,
        [string]$path
    )

    # Split the route and query string from the path
    $route, $queryString = $path -split '\?', 2
    $params = @{}
    if ($queryString) {
        $pairs = $queryString -split '&'
        foreach ($pair in $pairs) {
            $key, $value = $pair -split '=', 2
            $params[$key] = $value
        }
    }

    switch ("$method $route") {
        "GET /hello" {
            $name = $params["name"]
            if (-not $name) {
                $name = "vCrocs"
            }
            return @{
                StatusCode  = "200 OK"
                ContentType = "application/json"
                Body        = "{ `"message`": `"Hello, $name from PowerShell API`" }"
            }
        }
        "GET /status" {
            return @{
                StatusCode = "200 OK"
                ContentType = "application/json"
                Body = '{ "status": "ok", "time": "' + (Get-Date).ToString("o") + '" }'
            }
        }
        "GET /vms" {
            # Connect to vCenter using configuration values from $cfg
            $vCenter = Connect-VIServer -Server $cfg.vCenter.server -User $cfg.vCenter.username -Password $cfg.vCenter.password -Protocol https -Force

            # Retrieve, sort, and convert the VM names to JSON
            $vms = Get-VM | Where-Object { $_.Name -notlike "vCLS-*" } | Select-Object Name | Sort-Object Name
            $return = $vms | ConvertTo-Json

            # Disconnect from vCenter
            Disconnect-VIServer -Server * -Confirm:$false

            # Return a proper JSON response with the "results" key containing the JSON array of VMs
            return @{
                StatusCode  = "200 OK"
                ContentType = "application/json"
                Body        = "{""results"":$return}"
            }
        }
        "GET /tiered" {
            
            # Get VM Tiered Memory Usage
            # ESXi Hosts need to allow SSH with a Password
            # Connect to vCenter
            $hostsToMatch = @("192.168.6.101", "192.168.6.103", "192.168.6.104")
            $vCenter = Connect-VIServer -Server $cfg.vCenter.server -User $cfg.vCenter.username -Password $cfg.vCenter.password -Protocol https -Force

            # Get all ESXi hosts in the vCenter
            $esxiHosts = Get-VMHost | Where-Object {$hostsToMatch -contains $_.Name}

            # Create an empty array to store combined results
            $combinedResults = @()

            # Loop through each host
            foreach ($esxiHost in $esxiHosts) {
                
                # Define ESXi SSH connection details
                $server = $esxiHost.Name

                # Define ESXi SSH connection details
                $username = $cfg.Host101.username #"root"
                $password = $cfg.Host101.password #"VMware1!"
                New-LogEvent -message ("Connecting to Host Name: " + $server) -level "info"
                #Write-Host "Connect to Host Name:" $server

                # Check if sshpass is installed and available in the PATH.
                if (-not (Get-Command sshpass -ErrorAction SilentlyContinue)) {
                    Write-Error "sshpass is not installed or not in your PATH. Please install sshpass and try again."
                    exit 1
                } # end if

                $vmCommand = "esxcli --formatter csv vm process list | cut -d ',' -f 2,5"
                $args_vm = @(
                    "-p", $password,
                    "ssh",
                    "-o", "ConnectTimeout=10",
                    "-o", "PreferredAuthentications=password",
                    "-o", "PubkeyAuthentication=no",
                    "-o", "StrictHostKeyChecking=no",
                    "$username@$server",
                    $vmCommand
                )
                
                # Execute sshpass with proper argument splitting
                $vmOutput = & sshpass @args_vm
                
                # Parse CSV output into objects (assuming output is CSV)
                $VMXCartelID = $vmOutput | ConvertFrom-Csv

                # Execute the second SSH command using sshpass to get memory statistics
                $memCommand = 'memstats -r vmtier-stats -u mb -s name:memSize:active:tier0Consumed:tier1Consumed'
                $args_mem = @("-p", $password, "ssh", "-l", $username, $server, $memCommand)
                $memOutput = & sshpass @args_mem

                # Process the memory statistics output
                $lines = $memOutput -split "`n" | ForEach-Object { $_.Trim() } | Where-Object {
                    $_ -notmatch '^-{2,}|Total|Start|No.|VIRTUAL|Unit|Selected'
                }

                # Regex pattern for memory statistics
                $pattern = '^(?<name>\S+)\s+(?<memSize>\d+)\s+(?<active>\d+)\s+(?<tier0Consumed>\d+)\s+(?<tier1Consumed>\d+)$'

                # Array to store parsed memory stats
                $tieredMEM = @()

                # Parse the memory stats
                foreach ($line in $lines) {
                    if ($line -match $pattern) {
                        $tieredMEM += [pscustomobject]@{
                            Name         = $matches['name']
                            MemSizeMB    = [int]$matches['memSize']
                            ActiveMB     = [int]$matches['active']
                            "Tier0-RAM"  = [int]$matches['tier0Consumed']
                            "Tier1-NVMe" = [int]$matches['tier1Consumed']
                        }
                    }
                } # end foreach

                # Remove 'vm.' prefix from each VM Name
                $tieredMEM | ForEach-Object { $_.Name = $_.Name -replace '^vm\.', '' }

                # Create a hashtable for mapping VMX Cartel IDs to Display Names
                $vmNameMap = @{}
                foreach ($entry in $VMXCartelID) {
                    $vmNameMap[$entry.VMXCartelID] = $entry.DisplayName
                } # end foreach

                # Replace the Name field in $tieredMEM with the corresponding DisplayName
                foreach ($vm in $tieredMEM) {
                    if ($vmNameMap.ContainsKey($vm.Name)) {
                        $vm.Name = $vmNameMap[$vm.Name]
                    }
                } # end foreach

                # Filter out rows where the Name starts with "vCLS-"
                $tieredMEM = $tieredMEM | Where-Object { $_.Name -notlike "vCLS-*" }

                # Append the results from this host to the combined results array
                $combinedResults += $tieredMEM
            } # end foreach

            # Output the combined results as JSON
            $return = $combinedResults | ConvertTo-Json

            # Return a proper JSON response with the "results" key containing the JSON array of VMs
            return @{
                StatusCode  = "200 OK"
                ContentType = "application/json"
                Body        = "{""results"":$return}"
            }
        }
        default {
            return @{
                StatusCode = "200 OK"
                ContentType = "application/json"
                Body = '{ "results": "Default API reply" }'
            }
        }
    }
}

try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)

    try {
        $listener.Start()
        New-LogEvent -message "API server started on port $port..." -level "info"
    } catch {
        Write-Host "Failed to start listener: $_"
        return
    }

    while (-not $cancelled) {
        if ($listener.Pending()) {
            $client = $listener.AcceptTcpClient()
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $writer = [System.IO.StreamWriter]::new($stream)
            $writer.AutoFlush = $true

            $requestLine = $reader.ReadLine()
            New-LogEvent -message "Received: $requestLine" -level "info"

            if ($requestLine -match '^(GET|POST|PUT|DELETE) (/[^ ]*)') {
                $method = $matches[1]
                $path = $matches[2]

                $apiResponse = Get-ApiResponse -method $method -path $path
                $body = $apiResponse.Body
                $response = @"
HTTP/1.1 $($apiResponse.StatusCode)
Content-Type: $($apiResponse.ContentType)
Content-Length: $($body.Length)

$body
"@

                $writer.Write($response)
                if ($body.Length -ge 50) {
                    $shortBody = $body.Substring(0,50) + "..."
                } 
                else { 
                    $shortBody = $body
                }
                $outPut = "Returned: $shortBody"
                New-LogEvent -message $outPut -level "info"

            }

            $reader.Close()
            $writer.Close()
            $client.Close()
            New-LogEvent -message "Client disconnected"
        } else {
            Start-Sleep -Milliseconds 100
        }
    }
}
finally {
    $listener.Stop()
    New-LogEvent -message "Server stopped." -level "warn"
    Unregister-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
    Remove-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
} # End Finally


<#
curl http://192.168.6.76:8081/hello
curl http://192.168.6.76:8081/status
curl http://192.168.6.76:8081/vms
curl http://192.168.6.76:8081/tiered
#>
