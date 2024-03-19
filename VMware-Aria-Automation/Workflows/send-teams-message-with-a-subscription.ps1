function Handler($context, $inputs) {

    # Build PowerShell variables
    if(!$inputs.inputProperties.resourceNames){
        $vmName = "NA"
    }else{
        $vmName = $inputs.inputProperties.resourceNames
    }
    if(!$inputs.inputProperties.customProperties.image){
        $image = "NA"
    }else{
        $image = $inputs.inputProperties.customProperties.image
    }
    if(!$inputs.inputProperties.customProperties.flavor){
        $flavor = "NA"
    }else{
        $flavor = $inputs.inputProperties.customProperties.flavor
    }
    if(!$inputs.inputProperties.customProperties.folderName){
        $folder = "NA"
    }else{
        $folder = $inputs.inputProperties.customProperties.folderName
    }
    if(!$inputs.inputProperties.customProperties.vmIP){
        $vmIP = "NA"
    }else{
        $vmIP = $inputs.inputProperties.customProperties.vmIP
    }
    if(!$inputs.__metadata_userName){
        $userName = "NA"
    }else{
        $userName = $inputs.__metadata_userName
    }
    
    Write-Host "--vmName:"$vmName
    Write-Host "---image:"$image
    Write-Host "--flavor:"$flavor
    Write-Host "--folder:"$folder
    Write-Host "userName:"$userName
    Write-Host "----vmIP:"$vmIP


    # Define the webhook URL
    $webhookUrl = 'https://vcrocs.webhook.office.com/webhookb2/ac73a8c3-59a2-4df2-b6bd-82ce2fbd4572dfgdfgdgdgdgdfgdg6b7b44adb/IncomingWebhook/b41cd4d2fcbd4531892b8a462634dgdgdgddgdffdfgdggd-4590-9251-65db25f05419'

# Create the message card
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

    $output=@{status = 'done'}

    return $output
}
