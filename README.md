# PowerShell TCP Client/Server with Response Time Monitoring

A PowerShell-based TCP client/server application that establishes persistent connections and measures network response times. Built using .NET classes for reliable network communication with automatic reconnection handling.

## Features

- **Response Time Measurement:** Real-time ping-pong communication with millisecond precision
- **Flexible Configuration:** Command-line parameters for server IP and port settings
- **Automatic Reconnection:** Handles network disconnects with automatic retry logic
- **Port Validation:** Built-in validation for port numbers (1-65535)
- **Shared Utilities:** Modular design with reusable network validation functions
- **Help Documentation:** Built-in help system for both client and server

## Quick Start

### Start the Server
```powershell
# Use default port (9000)
.\server\server.ps1

# Use custom port
.\server\server.ps1 -Port 8080
```

### Connect the Client
```powershell
# Connect to default server (192.168.1.120:9000)
.\client\client.ps1

# Connect to custom server and port
.\client\client.ps1 -Server localhost -Port 8080

# Connect to different IP, keep default port
.\client\client.ps1 -Server 10.0.0.1
```

## Usage

### Server Script (`server/server.ps1`)
```powershell
Usage: .\server.ps1 [-Port <port>] [-Help]

Parameters:
  -Port      Port number to listen on (1-65535, default: 9000)
  -Help      Show help message

Examples:
  .\server.ps1
  .\server.ps1 -Port 8080
  .\server.ps1 -Port 3000
```

### Client Script (`client/client.ps1`)
```powershell
Usage: .\client.ps1 [-Server <hostname/ip>] [-Port <port>] [-Help]

Parameters:
  -Server    Target server hostname or IP address (default: 192.168.1.120)
  -Port      Target server port number (1-65535, default: 9000)
  -Help      Show help message

Examples:
  .\client.ps1
  .\client.ps1 -Server localhost -Port 8080
  .\client.ps1 -Server 10.0.0.1
```

## How It Works

- **Connection Establishment:** Client connects to server using `TcpClient.Connect`
- **Ping-Pong Protocol:** Client sends timestamped PING messages, server responds with PONG
- **Response Time Calculation:** Measures round-trip time with high precision (milliseconds)
- **Keep-Alive Loop:** Sends ping every 10 seconds with 5-second timeout for responses
- **Auto-Reconnection:** Automatically reconnects every 5 seconds if connection is lost
- **Port Validation:** Validates port numbers are within valid range (1-65535)

## Project Structure

```
├── client/
│   └── client.ps1          # TCP client with response time measurement
├── server/
│   └── server.ps1          # TCP server with ping-pong response
├── common/
│   └── NetworkUtils.ps1    # Shared network validation utilities
├── README.md
└── LICENSE
```

## Sample Output

### Server Output
```
Server started - Listening on port 9000...
Client connected from 192.168.1.100:52341
Received: PING:638123456789012345
Sent: PONG:638123456789012345
```

### Client Output
```
Connecting to server: localhost on port: 9000
Connected to localhost on port 9000
Sent ping at 14:30:15.123
Received pong - Response time: 2.45 ms
Sent ping at 14:30:25.456
Received pong - Response time: 1.87 ms
```

## Error Handling

- **Invalid Port Numbers:** Displays clear error messages for ports outside 1-65535 range
- **Connection Failures:** Automatic retry with status messages
- **Network Timeouts:** 5-second timeout for ping responses with timeout notifications
- **Graceful Disconnection:** Proper cleanup of network resources

## Notes

- Administrative privileges may be required for ports below 1024
- Ensure firewall allows traffic on the chosen port
- Scripts use native PowerShell and .NET capabilities for cross-platform compatibility
- Response times include network latency plus server processing time
- For production use, consider adding logging and more robust error handling

## License

MIT License - see LICENSE file for details.
