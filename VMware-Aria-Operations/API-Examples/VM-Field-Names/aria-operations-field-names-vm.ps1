# --- Set Aria Operations connection details
$opsURL      = "https://vao.vcrocs.local"
$opsUsername = "admin"
$opsPassword = "VMware1!"
$vmName      = "DC-02"
$authSource  = "local"

# --- Acquire authentication token from Aria Operations
$uri = "$opsURL/suite-api/api/auth/token/acquire?_no_links=true"

# --- Construct request body for authentication
$bodyHashtable = @{
    username   = $opsUsername
    authSource = $authSource
    password   = $opsPassword
}

# --- Convert authentication body to JSON
$body = $bodyHashtable | ConvertTo-Json

# --- Send authentication request and capture the token
$token = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
    "accept"        = "application/json"
    "Content-Type"  = "application/json"
} -Body $body -SkipCertificateCheck

# --- Format token for use in authorization headers
$authorization = "OpsToken " + $token.token

# --- Build API URI to retrieve the resource ID for the target VM
$uri = "$opsURL/suite-api/api/resources?name=$vmName&page=0&pageSize=1000&_no_links=true"

# --- Request resources matching the given VM name
$identifier = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    "accept"        = "application/json"
    "Authorization" = $authorization
} -SkipCertificateCheck

# --- Extract resource list and convert to JSON, then back to object for filtering
$identifier = $identifier.resourceList
$json       = $identifier | ConvertTo-Json -Depth 10
$data       = $json | ConvertFrom-Json

# --- Filter to get the VM resource where resourceKindKey is "VirtualMachine"
$targetResourceKindKey = "VirtualMachine"
$matchedObject = $data | Where-Object { $_.resourceKey.resourceKindKey -eq $targetResourceKindKey }

# --- If the VM is found, extract its identifier
if ($matchedObject) {
    $vmIdentifier = $($matchedObject.identifier)
} else {
    Write-Output "No VirtualMachine resourceKindKey found"
}

# --- Build API URI to retrieve the VM's property fields
$uri = "$opsURL/suite-api/api/resources/properties?resourceId=$vmIdentifier&_no_links=true"

# --- Get the VM's property field names and values
$resourcePropertiesList = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    "accept"        = "application/json"
    "Authorization" = $authorization
} -SkipCertificateCheck

# --- Output property fields to console
$outPut = $resourcePropertiesList.resourcePropertiesList.property
Write-Output $outPut

# --- Export sorted VM property fields to a CSV file
$resourcePropertiesList.resourcePropertiesList.property |
    Sort-Object Name |
    ConvertTo-Csv -NoTypeInformation |
    Out-File -FilePath "/Users/hdale/github/unlocking-the-potential/VMware-Aria-Operations/API-Examples/VM-Field-Names/aria-operations-vm-api-properties.csv"
# --- End of script


