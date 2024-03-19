function handler($context, $inputs) {

    # Build PowerShell variables
    if(!$inputs.resourceNames){
        $vmName = "NA"
    }else{
        $vmName = $inputs.resourceNames
    }
    if(!$inputs.customProperties.image){
        $image = "NA"
    }else{
        $image = $inputs.customProperties.image
    }
    if(!$inputs.customProperties.flavor){
        $flavor = "NA"
    }else{
        $flavor = $inputs.customProperties.flavor
    }
    if(!$inputs.customProperties.folderName){
        $folder = "NA"
    }else{
        $folder = $inputs.customProperties.folderName
    }
    if(!$inputs.customProperties.vmIP){
        $vmIP = "NA"
    }else{
        $vmIP = $inputs.customProperties.vmIP
    }
    if(!$inputs.__metadata.userName){
        $userName = "NA"
    }else{
        $userName = $inputs.__metadata.userName
    }
    
    Write-Host "--vmName:"$vmName
    Write-Host "---image:"$image
    Write-Host "--flavor:"$flavor
    Write-Host "--folder:"$folder
    Write-Host "userName:"$userName
    Write-Host "----vmIP:"$vmIP

    # --- [ Start Add Alert to Teams Channel ] ---
    
    # Define the webhook URL
    $webhookUrl = 'https://vcrocs.webhook.office.com/webhookb2/ac73a8c3-59a2-4df2-b6bd-82ce2fbd4572@015-hack-me-gWebhook/b41cd4d2fcbd4531892b8a4626340212/92-hack-u-9251-65db25f05419'

    # --- Create the message card
$messageCard = @{
    "@type"    = "MessageCard"
    "@context" = "http://schema.org/extensions"
    "summary"  = "Issue 176715375"
    "sections" = @(
        @{
            "activityTitle"    = "vRA Automated VM Build:"
            "facts"            = @(
                @{
                    "name"  = "VM Name:"
                    "value" = "$vmName"
                },
                @{
                    "name"  = "VM IP:"
                    "value" = "$vmIP"
                },
                @{
                    "name"  = "Created By:"
                    "value" = "$userName"
                },
                @{
                    "name"  = "VM Image:"
                    "value" = "$image"
                },
                @{
                    "name"  = "vCenter Folder:"
                    "value" = "$folder"
                },
                @{
                    "name"  = "VM Flavor:"
                    "value" = "$flavor"
                }
            )
            "markdown" = $true
        }
    )
} | ConvertTo-Json -Depth 10

    # Send the message card
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $messageCard

    $outPut = "Done"
    return $outPut
}
