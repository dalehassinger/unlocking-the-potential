# Web Server Zoom Status and Auto-Refreshing Web Page
# Created By: Dale Hassinger

param(
    [int]$port = 8080  # Define the port the web server will listen on
)

# Target to ping and file path to store the latest ping result
# Set the Zoom Status API URL
#$global:target = "192.168.4.1"
$global:statusFile = "/Users/dalehassinger/Documents/GitHub/PS-TAM-Lab/franky-latest-status.txt"
Set-Content -Path $global:statusFile -Value "Initializing..."  # Initialize the ping file with default text

# Control flag to gracefully stop the server on Ctrl+C
$cancelled = $false
$null = Register-EngineEvent -SourceIdentifier ConsoleBreak -Action {
    Write-Host "`nCtrl+C detected. Stopping server..."
    $global:cancelled = $true
}

try {
    # Create and start the TCP listener
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
    try {
        $listener.Start()
        Write-Host "Server started, listening on port $port..."
    } catch {
        Write-Host "Failed to start listener: $_"
        return
    }

    # Main loop to handle incoming connections
    while (-not $cancelled) {
        if ($listener.Pending()) {
            # Accept incoming client
            $client = $listener.AcceptTcpClient()
            Write-Host "Client connected: $($client.Client.RemoteEndPoint)"

            # Prepare reader and writer for HTTP response
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $writer = [System.IO.StreamWriter]::new($stream)
            $writer.AutoFlush = $true

            # Read HTTP request (first line)
            $request = $reader.ReadLine()
            Write-Host "Received: $request"

            # --- Start Zoom Status Section ---

            # Try to read last status message from file
            $statusMessage = if (Test-Path $global:statusFile) {
                Get-Content $global:statusFile -Raw
            } else {
                "No Zoom Status available."
            }

            # Get current date/time for display
            $currentDateTime = Get-Date -Format "dddd, MMMM dd, yyyy hh:mm:ss tt"

            # Set the Zoom Status API URL
            $url = "https://status.zoom.us/api/v2/summary.json"

            # Make the web request and parse the JSON response
            $response = Invoke-RestMethod -Uri $url -Method Get

            # Loop through each component and find "Zoom Meetings"
            foreach ($component in $response.components) {
                if ($component.name -eq "Zoom Meetings") {
                    #Write-Output "Zoom Meetings status: $($component.status)"
                    $message = "Zoom Meetings status: $($component.status)"
                    Set-Content -Path $global:statusFile -Value $message

                    break
                }
            }

            # --- Build HTML Response ---

            $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PowerShell Zoom Status</title>
    <meta http-equiv="refresh" content="60"> <!-- Auto-refresh every 60 seconds -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0; padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f8fafc;
            display: flex; justify-content: center; align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
            width: 90%; max-width: 600px;
        }
        h1 { font-size: 1.8rem; margin-bottom: 10px; color: #2d3748; }
        .datetime, .ping-result {
            font-size: 1rem;
            margin-top: 10px;
            color: #4a5568;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Status of Zoom component: "Zoom Meetings"</h1>
        <div class="datetime">Date and Time: $currentDateTime</div>
        <div class="ping-result">$statusMessage</div>
    </div>
</body>
</html>
"@

            # Send HTTP response with the HTML content
            $response = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=UTF-8`r`n`r`n$htmlContent"
            Write-Host "Sending response..."
            $writer.WriteLine($response)

            # Clean up client connection
            $reader.Close()
            $writer.Close()
            $client.Close()
            Write-Host "Client disconnected"
        } else {
            # Sleep briefly to reduce CPU usage
            Start-Sleep -Milliseconds 100
        }
    }
}
finally {
    # Stop listener when server is cancelled
    if ($listener -and $listener.Server.Connected -eq $false) {
        $listener.Stop()
        Write-Host "Server stopped."
    }

    # Delete the ping file on shutdown
    if (Test-Path $global:statusFile) {
        Remove-Item $global:statusFile -Force -ErrorAction SilentlyContinue
    }

    # Clean up Ctrl+C event registration
    Unregister-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
    Remove-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
}

