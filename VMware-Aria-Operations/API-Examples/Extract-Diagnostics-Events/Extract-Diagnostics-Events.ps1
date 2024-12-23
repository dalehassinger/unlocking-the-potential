# Import the ImportExcel module (requires prior installation)
Import-Module ImportExcel

# ----- Configuration and Credentials (Replace with secure methods in production) -----
$opsURL      = "https://vao.vcrocs.local" # Your VCF Operations URL
$opsUsername = "admin"
$opsPassword = "VMware1!" # Use a secure vault or secret manager in production
$authSource  = "local"

# ----- Acquire Aria Operations Token -----
$uri = "$opsURL/suite-api/api/auth/token/acquire?_no_links=true"

# Create authentication body
$bodyHashtable = @{
    username   = $opsUsername
    authSource = $authSource
    password   = $opsPassword
}

# Convert body to JSON
$body = $bodyHashtable | ConvertTo-Json

# Request token
$token = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
    "accept" = "application/json"
    "Content-Type" = "application/json"
} -Body $body -SkipCertificateCheck

$authorization = "OpsToken " + $token.token

# ----- Retrieve Diagnostic Events -----
$uri = "$opsURL/suite-api/internal/events?active=true&diagnosticSubType=HEALTH&page=0&pageSize=1000&type=DIAGNOSTIC&_no_links=true"

$results = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    "accept" = "application/json"
    "X-Ops-API-use-unsupported" = "true"
    "Authorization" = $authorization
} -SkipCertificateCheck

$OPSDiagData = $results.events

# ----- Prepare Excel Output -----
$excelFilePath = "/Users/hdale/github/PS-TAM-Lab/aria-operations-diag-data.xlsx"
$sheetName     = "Diagnostic-Data"

# Clear existing data in the worksheet
Export-Excel -Path $excelFilePath -WorksheetName $sheetName -ClearSheet

# ----- Process Events and Export Data -----
Try {
    foreach($OPSDiagEvent in $OPSDiagData){
        # Extract resource ID and clean up message content
        $resourceId     = $OPSDiagEvent.resourceId
        $messageContent = $OPSDiagEvent.message -replace "[:_]", " "

        # Remove GUID patterns from messages
        $regex = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
        $messageContent = $messageContent -replace $regex, "" | ForEach-Object { $_.TrimStart() }

        # Process Rule ID and generate Event Link
        $ruleID = $OPSDiagEvent.details | Where-Object { $_.key -eq "ruleId" } | Select-Object -ExpandProperty value
        $eventLink = ""

        if ($ruleID -match "KB_(\d{5,7})$") {
            $KBNumber  = $matches[1]
            $eventLink = "https://knowledge.broadcom.com/external/article?legacyId=$KBNumber"
        } elseif ($ruleID -match "CVE_\d{4}_\d{5}") {
            $CVENumber = $matches[0] -replace "_", "-"
            $eventLink = "https://support.broadcom.com/web/ecx/search?searchString=$CVENumber"
        } elseif ($ruleID -match "VMSA_(\d{4})(\d{2})") {
            $CVENumber = "VMSA-$($matches[1])-00$($matches[2])"
            $eventLink = "https://www.vmware.com/security/advisories/$CVENumber.html"
        } else {
            $eventLink = "NA"
        }

        # Fetch Resource Details
        $uri = $opsURL + '/suite-api/api/resources/' + $resourceId + '?_no_links=true'
        $IDresults = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            "accept" = "application/json"
            "Authorization" = $authorization
        } -SkipCertificateCheck

        # Prepare data for export
        $newData = @(
            [PSCustomObject]@{
                EventID=$OPSDiagEvent.eventId;
                EventType=$OPSDiagEvent.eventType;
                EventSubType=$OPSDiagEvent.diagnosticSubType;
                Severity=$OPSDiagEvent.severity;
                ResourceName=$IDresults.resourceKey.name;
                AdapterKind=$IDresults.resourceKey.adapterKindKey;
                ResourceKind=$IDresults.resourceKey.resourceKindKey;
                Message=$messageContent;
                Event_Link=$eventLink
            }
        )

        # Append data to Excel sheet
        $newData | Export-Excel -Path $excelFilePath -WorksheetName $sheetName -Append
    }
} Catch {
    Write-Error "An error occurred: $_"
}

# ----- Email Report with Excel Attachment -----
$fromEmail = "dale.hassinger@gmail.com"
$toEmail   = "dale.hassinger@vcrocs.info"
$subject   = "VCF Operations Diagnostic Data"

# Build email body
$body = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>vCROCS Automation</title><style>body {font-family: Arial;}</style></head><body><p>Diagnostic Data attached.</p><p>Created By: vCROCS Automation</p></body></html>'

$smtpServer  = "smtp.gmail.com"
$smtpPort    = 587
$appPassword = "kl-HackMe-tl"

$emailMessage = New-Object system.net.mail.mailmessage
$emailMessage.From = $fromEmail
$emailMessage.To.Add($toEmail)
$emailMessage.Subject = $subject
$emailMessage.Body = $body
$emailMessage.IsBodyHtml = $true

if (Test-Path $excelFilePath) {
    $attachment = New-Object System.Net.Mail.Attachment($excelFilePath)
    $emailMessage.Attachments.Add($attachment)
} else {
    Write-Host "Attachment not found: $excelFilePath"
    exit 1
}

$smtpClient = New-Object system.net.mail.smtpclient($smtpServer, $smtpPort)
$smtpClient.EnableSsl = $true
$smtpClient.Credentials = New-Object System.Net.NetworkCredential($fromEmail, $appPassword)

try {
    $smtpClient.Send($emailMessage)
    Write-Host "Email sent successfully."
} catch {
    Write-Host "Failed to send email: $_"
}
$smtpClient.Dispose()
$attachment.Dispose()
