# Define the Salt Master server
$saltMaster = 'vaac.corp.local'
Write-Host "Connecting to: $saltMaster..."

# Define the minion
$minionName = 'win-19-183'
Write-Host "Making config changes to: $minionName..."

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


# ----- [ Start State Apply ] -----
Write-Host 'Applying State to minion...'
$stateName = 'states.WindowsServerABXBuild'
#$stateName = 'WindowsServerABXBuild'

# Create The API call Body
$apiBody = @{
    resource = "cmd"
    method = "route_cmd"
    kwarg = @{
        cmd = "local"
        fun = "state.apply"
        tgt = @{
            "*" = @{
                tgt_type = "compound"
                tgt = $minionName
            }
        }
        arg = @{
            arg = @($stateName)
        }
    }
} | ConvertTo-Json -Depth 10
#$apiBody

$apiResponse = Invoke-RestMethod -Uri "https://$saltMaster/rpc" -Method Post -Headers $loginHeaders -Body $apiBody -SkipCertificateCheck
Write-Host "State request JID: $($apiResponse.ret)"

Start-Sleep -Seconds 15

# wait until job results = 'completed_all_successful'
do {
    # Get Job Results By JID
    $jid = $apiResponse.ret
    $jobStatusBody = @{
        resource = "cmd"
        method = "get_cmds"
        kwarg = @{
            jid = $jid
        }
    } | ConvertTo-Json
    
    $jobStatusResponse = Invoke-RestMethod -Uri "https://$saltMaster/rpc" -Method Post -Headers $loginHeaders -Body $jobStatusBody -SkipCertificateCheck
    Write-Output "Job $jid Status: $($jobStatusResponse.ret.results.state)"

    if($jobStatusResponse.ret.results.state -ne 'completed_all_successful'){
        Start-Sleep -Seconds 15
    } # End If

} while ($jobStatusResponse.ret.results.state -like '*completed*')
#} while ($jobStatusResponse.ret.results.state -ne 'completed_all_successful')

# Get Full Job Results Details By JID
$jobStatusBody = @{
    resource = "ret"
    method = "get_returns"
    kwarg = @{
        jid = $jid
    }
} | ConvertTo-Json

$jobStatusResponse = Invoke-RestMethod -Uri "https://$saltMaster/rpc" -Method Post -Headers $loginHeaders -Body $jobStatusBody -SkipCertificateCheck

$fullResults = $jobStatusResponse.ret.results.full_ret | Select-Object id, success, fun | Sort-Object id
Write-Host $fullResults

if ($jobStatusResponse.ret.results.has_errors -eq 'True') {
    Write-Output "Please Review the Build! There were failures applying the State!"
    #In PROD DO Something!
} # End if



# ----- [ End State Apply ] -----
