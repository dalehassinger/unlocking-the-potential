# Define the Salt Master server
$saltMaster = 'vaac.corp.local'
Write-Host "--Connecting to: $saltMaster"

$minionName = 'LINUX-U-171'
Write-Host "Deleting Key: $minionName..."

# Set SaltStack Connection Variables
$saltUsername = 'root'
$saltPassword = 'VMware1!'
$salt_userpass = $saltUsername + ":" + $saltPassword
$base64Encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($salt_Userpass))
$saltBase64Auth = "Basic $base64Encoded"

# Setup headers to connect and receive a X-Xsrftoken
$xsrfTokenHeaders = @{
    "Authorization" = $saltBase64Auth
}

$xsrfTokenRequest = Invoke-WebRequest -Uri "https://$saltMaster/version" -Method Get -Headers $xsrfTokenHeaders -SkipCertificateCheck -MaximumRetryCount 1000 -RetryIntervalSec 60
$xsrfToken = ($xsrfTokenRequest.Headers.'Set-Cookie' -split ";" -split '_xsrf=')[1]
#Write-Host "xsrfToken: $xsrfToken"

# Login with X-Xsrftoken to receive JWT bearer token
$loginHeaders = @{
    "X-Xsrftoken" = $xsrfToken
    "Authorization" = $saltBase64Auth
    "Content-Type" = "application/json"
    "Cookie" = "_xsrf=$xsrfToken"
}

$loginBody = @{
    password = $saltPassword
    username = $saltUsername
    config_name = "internal"
    token_type = "jwt"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "https://$saltMaster/account/login" -Method Post -Headers $loginHeaders -Body $loginBody -SkipCertificateCheck
#Write-Host "Login Response: $($loginResponse | Out-String)"

# Update headers with JWT bearer token for Authorization
$loginHeaders["Authorization"] = "Bearer $($loginResponse.jwt)"

# ----- [ Create The API call Body ] -----
$apiBody = '{"resource":"minions","method":"set_minion_key_state","kwarg":{"minions":[["salt","' + $minionName + '"]],"state":"delete"}}'
#$apiBody

$apiResponse = Invoke-RestMethod -Uri "https://$saltMaster/rpc" -Method Post -Headers $loginHeaders -Body $apiBody -SkipCertificateCheck
#$apiResponse
#$apiResponse.error.message

# ----- [ Display the JID or error ] -----
if($null -ne $apiResponse.error.message){
    Write-Host "Error: "$apiResponse.error.message
} # End If
else{
    Write-Host "Request Job ID: $($apiResponse.ret.task_ids)"
} # End Else
