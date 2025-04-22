# Web Server for Home Lab Use and a Nice way to see how PowerShell can be used.
# Created By: Dale Hassinger

param(
    [int]$port = 8080  # Define a port parameter with a default value of 8080
)

# Flag for cancellation, used to control when to stop the server
$cancelled = $false

# Register an event handler for Ctrl+C (ConsoleBreak)
# When triggered, it sets the $cancelled flag to true so the server can stop gracefully
$null = Register-EngineEvent -SourceIdentifier ConsoleBreak -Action {
    Write-Host "`nCtrl+C detected. Stopping server..."
    $global:cancelled = $true
}

try {
    # Create a new TCP listener that listens on any IP address and the specified port
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)

    try {
        # Start the TCP listener
        $listener.Start()
        Write-Host "Server started, listening on port $port..."
    } catch {
        # Handle failure to start the listener
        Write-Host "Failed to start listener: $_"
        return
    }

    # Main loop to keep the server running until cancelled
    while (-not $cancelled) {
        # Check if a client is attempting to connect
        if ($listener.Pending()) {
            # Accept the incoming TCP client connection
            $client = $listener.AcceptTcpClient()
            Write-Host "Client connected: $($client.Client.RemoteEndPoint)"

            # Get the network stream and setup reader/writer for communication
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $writer = [System.IO.StreamWriter]::new($stream)
            $writer.AutoFlush = $true  # Ensure output is flushed immediately

            # Read the first line of the HTTP request from the client
            $request = $reader.ReadLine()
            Write-Host "Received: $request"

            # Get the current date and time to include in the HTML response
            $currentDateTime = Get-Date -Format "dddd, MMMM dd, yyyy hh:mm:ss tt"

            # Define the HTML content to return as the response
            $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PowerShell Web Example</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(120deg, #f0f2f5, #e2e8f0);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #ffffff;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            max-width: 600px;
            width: 90%;
            text-align: center;
        }
        h1 {
            color: #1a202c;
            font-size: 2rem;
            margin-bottom: 20px;
        }
        .datetime {
            font-size: 1.2rem;
            color: #4a5568;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to a VMUG Connect Example</h1>
        <div class="datetime">Current Date and Time: $currentDateTime</div>
    </div>
</body>
</html>
"@

            # Combine HTTP headers and the HTML content into a full HTTP response
            $response = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=UTF-8`r`n`r`n$htmlContent"
            Write-Host "Sending response..."

            # Send the response back to the client
            $writer.WriteLine($response)

            # Clean up the network resources
            $reader.Close()
            $writer.Close()
            $client.Close()
            Write-Host "Client disconnected"
        } else {
            # Sleep briefly to reduce CPU usage while waiting for new connections
            Start-Sleep -Milliseconds 100
        }
    }
}
finally {
    # Stop the listener if it exists and isn't already connected
    if ($listener -and $listener.Server.Connected -eq $false) {
        $listener.Stop()
        Write-Host "Server stopped."
    }

    # Clean up the registered Ctrl+C event
    Unregister-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
    Remove-Event -SourceIdentifier ConsoleBreak -ErrorAction SilentlyContinue
}
