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

    # --- [ Start Add Alert to Google Chat ] ---
    
    # --- Create json body for Google Alert   
$messageBody = @{
    cards = @(
        @{
            header = @{
                title    = "New VM Build"
            }
            sections = @(
                @{
                    widgets = @(
                        @{
                            keyValue = @{
                                topLabel         = "VM Name:"
                                content          = "$vmname"
                                contentMultiline = $true
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "VM IP:"
                                content          = "$vmIP"
                                contentMultiline = $true
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "Created By:"
                                content          = "$username"
                                contentMultiline = $true
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "VM Image:"
                                content          = "$image"
                                contentMultiline = $true
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "vCenter Folder:"
                                content          = "$folder"
                                contentMultiline = $true
                            }
                        },
                        @{
                            keyValue = @{
                                topLabel         = "VM Flavor:"
                                content          = "$flavor"
                                contentMultiline = $true
                            }
                        }
                    )
                }
            )
        }
    )
}
    
    $jsonMessage = $messageBody | ConvertTo-Json -Depth 10
    
    # Output the JSON to verify
    #$jsonMessage

    # Define the webhook URL (replace it with your actual webhook URL)
    $webhookUrl = 'https://chat.googleapis.com/v1/spaces/AAAAvSYSmfg/messages?key=AIzaS-hack-me-&token=Vj-NoThfrmjLnkIW_i-Hack-you-tkjs2ArM7o'

    # Send the message
    $results = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonMessage -ContentType "application/json"

    #$outPut = "WebHook Date/Time: " + $results.createTime
    #Write-Host $outPut
    
    $outPut = "Done"

  return $outPut
}
