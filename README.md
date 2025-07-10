## PowerShell TCP Client/Listener Script Using .NET Classes

To establish and maintain a persistent TCP connection on Windows, you can use PowerShell with .NET classes such as `System.Net.Sockets.TcpClient`. This approach allows you to create a client that connects to a server, sends periodic messages, and automatically handles disconnects and reconnections.

### Example: PowerShell TCP Client Script

Below is a sample PowerShell script that:

- Connects to a specified server and port.
- Sends a "ping" message at regular intervals.
- Detects connection drops and attempts to reconnect.
- Logs connection status and errors.

```powershell
# PowerShell TCP Client Script

$server = "192.168.1.100"   # Replace with your server's IP or hostname
$port = 9000                # Replace with your server's port

function Connect-TcpClient {
    param(
        [string]$server,
        [int]$port
    )
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $client.Connect($server, $port)
        Write-Host "Connected to $server on port $port"
        return $client
    }
    catch {
        Write-Host "Failed to connect: $_"
        return $null
    }
}

function Maintain-Connection {
    param(
        [System.Net.Sockets.TcpClient]$client,
        [string]$server,
        [int]$port
    )
    while ($true) {
        if ($client -eq $null -or -not $client.Connected) {
            Write-Host "Connection lost. Attempting to reconnect..."
            $client = Connect-TcpClient -server $server -port $port
            Start-Sleep -Seconds 5
            continue
        }
        try {
            $stream = $client.GetStream()
            if ($stream.CanWrite) {
                $message = "Ping at $(Get-Date)"
                $buffer = [System.Text.Encoding]::ASCII.GetBytes($message)
                $stream.Write($buffer, 0, $buffer.Length)
                Write-Host "Sent: $message"
            }
            Start-Sleep -Seconds 10
        }
        catch {
            Write-Host "Error during communication: $_"
            $client.Close()
            $client = $null
        }
    }
}

# Main script
$client = Connect-TcpClient -server $server -port $port
Maintain-Connection -client $client -server $server -port $port
```

### How It Works

- **Connection Establishment:** The script attempts to connect to the server using `TcpClient.Connect`.
- **Keep-Alive Loop:** It sends a message every 10 seconds. If the connection drops, it tries to reconnect every 5 seconds.
- **Error Handling:** Any exceptions during communication trigger a reconnect attempt.

### Customization

- Change `$server` and `$port` to match your environment.
- Adjust the `Start-Sleep` intervals for your needs.
- You can expand the script to log results to a file for later analysis.

### Listener Example (Server Side)

If you need a simple TCP listener (server) for testing, you can use the following PowerShell snippet:

```powershell
# PowerShell TCP Server Script

$listener = [System.Net.Sockets.TcpListener]9000
$listener.Start()
Write-Host "Listening on port 9000..."
while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    while ($client.Connected) {
        if ($stream.DataAvailable) {
            $line = $reader.ReadLine()
            Write-Host "Received: $line"
        }
        Start-Sleep -Milliseconds 500
    }
    $client.Close()
}
```

### Notes

- These scripts are for demonstration and basic monitoring. For production, consider adding more robust error handling and logging.
- Administrative privileges may be required to run listeners on ports below 1024.
- Ensure your firewall allows traffic on the chosen port.

This approach provides a persistent TCP connection for monitoring network stability and handling disconnects automatically using native PowerShell and .NET capabilities.
