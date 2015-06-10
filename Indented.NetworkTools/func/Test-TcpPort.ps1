function Test-TcpPort {
  # .SYNOPSIS
  #   Test a TCP Port using System.Net.Sockets.TcpClient.
  # .DESCRIPTION
  #   Test-TcpPort establishes a TCP connection to the sepecified port then immediately closes the connection, returning whether or not the connection succeeded.
  #       
  #   This function fully opens TCP connections (3-way handshake), it does not half-open connections.
  # .PARAMETER ComputerName
  #   An host name or IP address for the target system.
  # .PARAMETER Port
  #   The port number to connect to (between 1 and 655535).
  # .INPUTS
  #   System.String
  #   System.UInt16
  # .OUTPUTS
  #   System.Boolean
  # .EXAMPLE
  #   Test-TcpPort 10.0.0.1 3389
  #
  #   Opens a TCP connection to 10.0.0.1 using port 3389.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     25/11/2010 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ComputerName,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [UInt16]$Port
  )

  $TcpClient = New-Object Net.Sockets.TcpClient
  try { $TcpClient.Connect($ComputerName, $Port) } catch { }
  if ($?) {
    $TcpClient.Close()
    return $true
  }
  return $false
}