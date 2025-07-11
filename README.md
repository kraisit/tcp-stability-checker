## PowerShell TCP Client/Listener Script Using .NET Classes

This program establishs and maintains a persistent TCP connection on Windows using PowerShell with .NET classes `System.Net.Sockets.TcpClient`. After a client program connects to a server, sends periodic messages, and automatically handles disconnects and reconnections.


### How It Works

- **Connection Establishment:** The script attempts to connect to the server using `TcpClient.Connect`.
- **Keep-Alive Loop:** It sends a message every 10 seconds. If the connection drops, it tries to reconnect every 5 seconds.
- **Error Handling:** Any exceptions during communication trigger a reconnect attempt.

### Customization

- Change `$server` and `$port` to match your environment.
- Adjust the `Start-Sleep` intervals for your needs.
- You can expand the script to log results to a file for later analysis.

### Notes

- These scripts are for demonstration and basic monitoring. For production, consider adding more robust error handling and logging.
- Administrative privileges may be required to run listeners on ports below 1024.
- Ensure your firewall allows traffic on the chosen port.

This approach provides a persistent TCP connection for monitoring network stability and handling disconnects automatically using native PowerShell and .NET capabilities.
