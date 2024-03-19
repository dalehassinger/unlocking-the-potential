function Handler($context, $inputs) {

    # Build PowerShell variables
    if(!$inputs.vmName){
        $vmName = "NA"
    }else{
        $vmName = $inputs.vmName
    }
    if(!$inputs.snapName){
        $snapName = "NA"
    }else{
        $snapName = $inputs.snapName
    }
    if(!$inputs.snapDescription){
        $snapDescription = "NA"
    }else{
        $snapDescription = $inputs.snapDescription
    }

    Write-Host "---------vmName:"$vmName
    Write-Host "-------snapName:"$snapName
    Write-Host "snapDescription:"$snapDescription

    # Define the webhook URL
    $webhookUrl = 'https://vcrocs.webhook.office.com/webhookb2/ac73a8c3-59asdfsfdsgrtgh4572@015568c1-bbe7-4050-add6-6f3wrrtfgreertadb/IncomingWebhook/b41cd4d2fcsdfstyrtyrtsdtfsd26340212/925be554-9960sdfsdfsdf251-65db25f05419'

# Create the message card
$messageCard = @{
    "@type"    = "MessageCard"
    "@context" = "http://schema.org/extensions"
    "summary"  = "Issue 176715375"
    "sections" = @(
        @{
            "activityTitle"    = "VM SNAP Shot:"
            "facts"            = @(
                @{
                    "name"  = "VM Name:"
                    "value" = "$vmName"
                },
                @{
                    "name"  = "Snap Name:"
                    "value" = "$snapName"
                },
                @{
                    "name"  = "Snap Description:"
                    "value" = "$snapDescription"
                }
            )
            "markdown" = $true
        }
    )
} | ConvertTo-Json -Depth 10

    # Send the message card
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $messageCard

    # Use this section to add the code to do whatever day 2 process you want to run
    # --- Start the Code


    # --- end the Code

    $output=@{status = 'done'}

    return $output
}
