# PowerShell TCP Server Script
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025

#Add-Type -AssemblyName System.Net.Sockets

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
