$opsURL      = "https://vao-ent.corp.local"
$opsUsername = "admin"
$opsPassword = "VMware1!"
$hostName    = "esxi8-04.corp.local"
$authSource  = "local"


# ----- Get Aria Operations token
$uri = "$opsURL/suite-api/api/auth/token/acquire?_no_links=true"
#$uri

# --- Create body
$bodyHashtable = @{
    username = $opsUsername
    authSource = $authSource
    password = $opsPassword
}

# --- Convert the hashtable to a JSON string
$body = $bodyHashtable | ConvertTo-Json

$token = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
    "accept" = "application/json"
    "Content-Type" = "application/json"
} -Body $body -SkipCertificateCheck

#$token.token

$authorization = "OpsToken " + $token.token
#$authorization

# ----- Get the VM Operations identifier
$uri = "$opsURL/suite-api/api/resources?name=$hostName&page=0&pageSize=1000&_no_links=true"
#$uri

$identifier = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    "accept" = "application/json"
    "Authorization" = $authorization
} -SkipCertificateCheck

#$identifier
$identifier = $identifier.resourceList
$json = $identifier | ConvertTo-Json -Depth 10
#$json

# Convert the JSON string to a PowerShell object
$data = $json | ConvertFrom-Json
#$data

# Search for the object where resourceKindKey is "VirtualMachine"
$targetResourceKindKey = "Hostsystem"
$matchedObject = $data | Where-Object { $_.resourceKey.resourceKindKey -eq $targetResourceKindKey }

# If a matching object is found, output the identifier
if ($matchedObject) {
    $vmIdentifier = $($matchedObject.identifier)
    #Write-Output $($matchedObject.identifier)
} # End If
else {
    Write-Output "No VirtualMachine resourceKindKey found"
} # End Else




# ----- Get Field Names and Values
$uri = "$opsURL/suite-api/api/resources/properties?resourceId=$vmidentifier&_no_links=true"
#$uri

$resourcePropertiesList = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    "accept" = "application/json"
    "Authorization" = $authorization
} -SkipCertificateCheck

$outPut = $resourcePropertiesList.resourcePropertiesList.property
Write-Output $outPut
