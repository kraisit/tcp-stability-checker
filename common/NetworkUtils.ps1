# PowerShell Network Utilities Module
# License: MIT (see LICENSE file)
# Author: Kraisit, 2025

function Test-PortNumber {
    <#
    .SYNOPSIS
    Validates if a port number is within the valid range (1-65535)
    
    .DESCRIPTION
    Checks if the provided port number is a valid integer between 1 and 65535.
    Port 0 is reserved and not allowed for general use.
    
    .PARAMETER Port
    The port number to validate
    
    .PARAMETER AllowZero
    Allow port 0 (reserved port) - default is false
    
    .EXAMPLE
    Test-PortNumber -Port 8080
    Returns $true
    
    .EXAMPLE
    Test-PortNumber -Port 70000
    Returns $false
    
    .EXAMPLE
    Test-PortNumber -Port 0 -AllowZero
    Returns $true
    #>
    param(
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [switch]$AllowZero
    )
    
    $minPort = if ($AllowZero) { 0 } else { 1 }
    $maxPort = 65535
    
    if ($Port -lt $minPort -or $Port -gt $maxPort) {
        return $false
    }
    
    return $true
}

function Assert-ValidPort {
    <#
    .SYNOPSIS
    Validates port number and exits with error message if invalid
    
    .DESCRIPTION
    Validates the port number and displays an error message and exits if invalid.
    This is a convenience function for command-line scripts.
    
    .PARAMETER Port
    The port number to validate
    
    .PARAMETER AllowZero
    Allow port 0 (reserved port) - default is false
    
    .PARAMETER ScriptName
    Name of the calling script for error messages
    #>
    param(
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [switch]$AllowZero,
        
        [Parameter(Mandatory=$false)]
        [string]$ScriptName = "Script"
    )
    
    if (-not (Test-PortNumber -Port $Port -AllowZero:$AllowZero)) {
        $minPort = if ($AllowZero) { 0 } else { 1 }
        Write-Host "Error: Invalid port number '$Port'" -ForegroundColor Red
        Write-Host "Port must be an integer between $minPort and 65535" -ForegroundColor Red
        Write-Host ""
        Write-Host "Use '$ScriptName -Help' for usage information" -ForegroundColor Yellow
        exit 1
    }
}

# Functions will be available through dot-sourcing