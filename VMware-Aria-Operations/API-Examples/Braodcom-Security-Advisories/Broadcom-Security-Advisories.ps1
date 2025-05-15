# --- Define headers for the HTTP POST request
$headers = @{
    "accept"        = "application/json"
    "content-type"  = "application/json"
}

# --- Define the request payload for Broadcom Security Advisory API
$payload = @{
    "pageNumber" = 0       # Starting page number
    "pageSize"   = 50      # Number of results per page
    "searchVal"  = ""      # Empty search term returns all results
    "segment"    = "VC"    # Segment filter (e.g., VC for VMware Cloud)
}

# --- Convert the payload hashtable to JSON
$body = $payload | ConvertTo-Json

# --- Send POST request to retrieve security advisory list
$requests = Invoke-WebRequest -Uri "https://support.broadcom.com/web/ecx/security-advisory/-/securityadvisory/getSecurityAdvisoryList" `
    -Method POST -Headers $headers -Body $body

# --- If the request is successful (HTTP 200), parse the result
if ($requests.StatusCode -eq 200) {
    $results = ($requests.Content | ConvertFrom-Json).data.list
}

# --- Display the retrieved list in a formatted table
$results | Format-Table * -AutoSize

