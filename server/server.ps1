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
. "$PSScriptRoot\..\common\NetworkUtils.ps1"

# Show help if requested
if ($Help) {
    Write-Host "PowerShell TCP Server - Ping Response Server"
    Write-Host ""
    Write-Host "Usage: .\server\server.ps1 [-Port <port>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Port      Port number to listen on (1-65535, default: 9000)"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\server\server.ps1"
    Write-Host "  .\server\server.ps1 -Port 8080"
    Write-Host "  .\server\server.ps1 -Port 3000"
    exit 0
}

# Validate port number
Assert-ValidPort -Port $Port -ScriptName ".\server.ps1"

# Setup cancellation token for Ctrl+C handling
$cancelSource = New-Object System.Threading.CancellationTokenSource
$cancelToken = $cancelSource.Token

# Register Ctrl+C handler
[Console]::TreatControlCAsInput = $false
$null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
    $global:cancelSource.Cancel()
    $event.Cancel = $true
}

try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
    # Enable port reuse to avoid "address in use" errors
    $listener.Server.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    $listener.Start()
    Write-Host "Server started - Listening on port $Port... (Press Ctrl+C to stop)"
    
    while (-not $cancelToken.IsCancellationRequested) {
        try {
            # Set up an async task to accept clients with timeout
            $acceptTask = $listener.AcceptTcpClientAsync()
            while (-not $acceptTask.Wait(1000)) { # 1 second timeout
                if ($cancelToken.IsCancellationRequested) {
                    Write-Host "Stopping server..."
                    return
                }
            }
            $client = $acceptTask.Result
            if ($null -eq $client) { continue }
            
            $stream = $client.GetStream()
            if ($null -eq $stream) { 
                $client.Close()
                continue 
            }
            
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
            
            if ($null -ne $client) {
                $client.Close()
                Write-Host "Client connection closed"
            }
        }
        catch {
            Write-Host "Error in main server loop: $_"
            Start-Sleep -Seconds 1
        }
    }
}
finally {
    if ($null -ne $listener) {
        $listener.Stop()
        Write-Host "Server stopped"
    }
    # Clean up event handler and cancellation token
    Get-EventSubscriber | Where-Object { $_.SourceObject -eq [Console] } | Unregister-Event
    $cancelSource.Dispose()
}
