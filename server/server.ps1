# PowerShell TCP Server Script
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025

#Add-Type -AssemblyName System.Net.Sockets

$port = 9000                # Replace with your desired port number

$listener = [System.Net.Sockets.TcpListener]::new($port)
$listener.Start()
Write-Host "Listening on port $port..."
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
