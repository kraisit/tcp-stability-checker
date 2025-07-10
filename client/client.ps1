# PowerShell TCP Client Script
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025


#Add-Type -AssemblyName System.Net.Sockets
#Add-Type -AssemblyName System.Text

$server = "192.168.1.120"   # Replace with your server's IP or hostname
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
