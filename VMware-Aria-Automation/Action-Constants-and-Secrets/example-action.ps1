function handler($context, $inputs) {

    # ----- [ PS Variables based on Action Constants and Secrets ] -----
    $vCenterPassword = $context.getSecret($inputs.vCenterPassword)
    $vCenterFQDN     = $inputs.vCenterFQDN
    $vCenterUsername = $inputs.vCenterUsername
    
    # ----- [ Show PS Variables Values ] -----
    Write-Host "---PS Variables:"
    Write-Host "vCenterPassword: " $vCenterPassword
    Write-Host "----vCenterFQDN: " $inputs.vCenterFQDN
    Write-Host "vCenterUsername: " $inputs.vCenterUsername
  
    # ----- [ Connect to vCenter using Action Constants and Secrets ] -----
    Write-Host "Starting Connection to vCenter..."
    $connection = Connect-VIServer -Server $vCenterFQDN -User $vCenterUsername -Password $vCenterPassword -Protocol https -Force

    Write-Host "Show if vCenter Connection was successful:"
    $outPut = 'vCenter Connection: ' + $connection.IsConnected
    Write-Host $outPut

    return $inputs
}
