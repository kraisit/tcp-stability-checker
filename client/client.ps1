# PowerShell TCP Client Script
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025

param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.1.120",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Import shared network utilities
. "$PSScriptRoot\common\NetworkUtils.ps1"

# Show help if requested
if ($Help) {
    Write-Host "PowerShell TCP Client - Ping Response Time Tester"
    Write-Host ""
    Write-Host "Usage: .\client.ps1 [-Server <hostname/ip>] [-Port <port>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Server    Target server hostname or IP address (default: 192.168.1.120)"
    Write-Host "  -Port      Target server port number (1-65535, default: 9000)"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\client.ps1"
    Write-Host "  .\client.ps1 -Server localhost -Port 8080"
    Write-Host "  .\client.ps1 -Server 10.0.0.1"
    exit 0
}

# Validate port number
Assert-ValidPort -Port $Port -ScriptName ".\client.ps1"

#Add-Type -AssemblyName System.Net.Sockets
#Add-Type -AssemblyName System.Text

Write-Host "Connecting to server: $Server on port: $Port"

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

function Test-ConnectionStability {
    param(
        [System.Net.Sockets.TcpClient]$client,
        [string]$server,
        [int]$port
    )
    while ($true) {
        if ($null -eq $client -or -not $client.Connected) {
            Write-Host "Connection lost. Attempting to reconnect..."
            $client = Connect-TcpClient -server $server -port $port
            Start-Sleep -Seconds 5
            continue
        }
        try {
            $stream = $client.GetStream()
            $reader = New-Object System.IO.StreamReader($stream)
            
            if ($stream.CanWrite) {
                # Send ping with timestamp
                $startTime = Get-Date
                $message = "PING:$($startTime.Ticks)"
                $buffer = [System.Text.Encoding]::ASCII.GetBytes($message + "`n")
                $stream.Write($buffer, 0, $buffer.Length)
                Write-Host "Sent ping at $($startTime.ToString('HH:mm:ss.fff'))"
                
                # Wait for pong response with timeout
                $timeout = 5000 # 5 seconds timeout
                $client.ReceiveTimeout = $timeout
                
                try {
                    if ($stream.DataAvailable -or $reader.Peek() -ge 0) {
                        $response = $reader.ReadLine()
                        $endTime = Get-Date
                        
                        if ($response -and $response.StartsWith("PONG:")) {
                            $sentTicks = $response.Split(':')[1]
                            $responseTime = ($endTime.Ticks - [long]$sentTicks) / 10000 # Convert to milliseconds
                            Write-Host "Received pong - Response time: $($responseTime.ToString('F2')) ms"
                        }
                    }
                }
                catch {
                    Write-Host "Timeout waiting for pong response"
                }
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
$client = Connect-TcpClient -server $Server -port $Port
Test-ConnectionStability -client $client -server $Server -port $Port
