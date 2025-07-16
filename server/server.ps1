# PowerShell TCP Server Script
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Import shared network utilities
. "$PSScriptRoot\common\NetworkUtils.ps1"

# Show help if requested
if ($Help) {
    Write-Host "PowerShell TCP Server - Ping Response Server"
    Write-Host ""
    Write-Host "Usage: .\server.ps1 [-Port <port>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Port      Port number to listen on (1-65535, default: 9000)"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\server.ps1"
    Write-Host "  .\server.ps1 -Port 8080"
    Write-Host "  .\server.ps1 -Port 3000"
    exit 0
}

# Validate port number
Assert-ValidPort -Port $Port -ScriptName ".\server.ps1"

#Add-Type -AssemblyName System.Net.Sockets

$listener = [System.Net.Sockets.TcpListener]::new($Port)
$listener.Start()
Write-Host "Server started - Listening on port $Port..."
while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true
    
    Write-Host "Client connected from $($client.Client.RemoteEndPoint)"
    
    while ($client.Connected) {
        try {
            if ($stream.DataAvailable) {
                $line = $reader.ReadLine()
                Write-Host "Received: $line"
                
                # If it's a ping, send back a pong with the same timestamp
                if ($line -and $line.StartsWith("PING:")) {
                    $timestamp = $line.Split(':')[1]
                    $pongMessage = "PONG:$timestamp"
                    $writer.WriteLine($pongMessage)
                    Write-Host "Sent: $pongMessage"
                }
            }
            Start-Sleep -Milliseconds 100
        }
        catch {
            Write-Host "Client disconnected: $_"
            break
        }
    }
    $client.Close()
    Write-Host "Client connection closed"
}
