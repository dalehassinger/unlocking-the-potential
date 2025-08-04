<#
.SYNOPSIS
    Retrieves VM deployment information from vRealize Automation (vRA) and exports to CSV.

.DESCRIPTION
    This script connects to vRA, retrieves all deployments, filters for vSphere machines,
    and exports the VM names and IP addresses to a CSV file.

.NOTES
    Date: 10/09/2024
    Author: Dale Hassinger
    Environment: DDC Lab
#>

# ----- Configuration Variables -----
$vraServer = "vaa.vcrocs.local"
$csvPath = "/Users/dalehassinger/Documents/GitHub/PS-TAM-Lab/VCF-Automation-Deployments.csv"

# ----- Authentication -----
Write-Host "Authenticating to vRA server: $vraServer" -ForegroundColor Green

# Build authentication URI
$authUri = "https://$vraServer/csp/gateway/am/api/login"

# Create authentication body
$authBody = @{
    username = "configadmin"
    password = "VMware1!"
    domain   = "System Domain"
} | ConvertTo-Json

# Create headers for authentication
$authHeaders = @{
    'Accept'       = '*/*'
    'Content-Type' = 'application/json'
}

try {
    # Get authentication token
    $authResponse = Invoke-RestMethod -Uri $authUri -Method Post -Headers $authHeaders -Body $authBody -SkipCertificateCheck
    
    # Create authorization header for subsequent requests
    $headers = @{
        'Accept'        = '*/*'
        'Content-Type'  = 'application/json'
        'Authorization' = "Bearer $($authResponse.cspAuthToken)"
    }
    
    Write-Host "Authentication successful" -ForegroundColor Green
}
catch {
    Write-Error "Authentication failed: $($_.Exception.Message)"
    exit 1
}

# ----- Get Deployments -----
Write-Host "Retrieving deployments..." -ForegroundColor Yellow

#$deploymentsUri = "https://$vraServer/deployment/api/deployments?page=0&size=100&sort=createdAt%2CDESC"
$deploymentsUri = "https://$vraServer/deployment/api/deployments"


try {
    $deploymentsResponse = Invoke-RestMethod -Uri $deploymentsUri -Method GET -Headers $headers -SkipCertificateCheck
    $deploymentIDs = $deploymentsResponse.content.id
    
    Write-Host "Found $($deploymentIDs.Count) deployments" -ForegroundColor Green
}
catch {
    Write-Error "Failed to retrieve deployments: $($_.Exception.Message)"
    exit 1
}

# ----- Process Deployments -----
Write-Host "Processing deployments for vSphere machines..." -ForegroundColor Yellow

# Initialize collection for better performance
$vmCollection = [System.Collections.Generic.List[PSObject]]::new()

foreach ($deploymentID in $deploymentIDs) {
    try {
        # Get deployment resources
        $resourcesUri = "https://$vraServer/deployment/api/deployments/$deploymentID/resources"
        $resourcesResponse = Invoke-RestMethod -Uri $resourcesUri -Method GET -Headers $headers -SkipCertificateCheck
        
        # Filter for vSphere machines
        $vsphereMachines = $resourcesResponse.content.properties | Where-Object { $_.componentType -eq "Cloud.vSphere.Machine" }
        
        foreach ($machine in $vsphereMachines) {
            $vmName = $machine.resourceName
            $vmIPAddress = $machine.address
            
            # Skip if either value is null or empty
            if ([string]::IsNullOrWhiteSpace($vmName) -or [string]::IsNullOrWhiteSpace($vmIPAddress)) {
                Write-Warning "Skipping machine with missing name or IP address"
                continue
            }
            
            Write-Host "Found VM: $vmName - IP: $vmIPAddress" -ForegroundColor Cyan
            
            # Create VM object and add to collection
            $vmObject = [PSCustomObject]@{
                VMName    = $vmName
                IPAddress = $vmIPAddress
            }
            
            $vmCollection.Add($vmObject)
        }
    }
    catch {
        Write-Warning "Failed to process deployment $deploymentID : $($_.Exception.Message)"
        continue
    }
}

# ----- Export Results -----
if ($vmCollection.Count -gt 0) {
    try {
        Write-Host "Exporting $($vmCollection.Count) VMs to CSV..." -ForegroundColor Yellow
        
        $vmCollection | Export-Csv -Path $csvPath -NoTypeInformation -Force
        
        Write-Host "VM data successfully exported to: $csvPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to export CSV: $($_.Exception.Message)"
        exit 1
    }
}
else {
    Write-Warning "No vSphere machines found in deployments"
}

Write-Host "Script completed successfully" -ForegroundColor Green
