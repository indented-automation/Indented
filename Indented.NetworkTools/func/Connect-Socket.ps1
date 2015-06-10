function Connect-Socket {
  # .SYNOPSIS
  #   Connect a TCP socket to a remote IP address and port.
  # .DESCRIPTION
  #   If a TCP socket is being used as a network client it must first connect to a server before Send-Bytes and Receive-Bytes can be used.
  # .PARAMETER RemoteIPAddress
  #   The remote IP address to connect to.
  # .PARAMETER RemotePort
  #   The remote port to connect to.
  # .PARAMETER Socket
  #   A socket created using New-Socket.
  # .INPUTS
  #   System.Net.IPAddress
  #   System.Net.Sockets.Socket
  #   System.UInt16
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     06/01/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,
    
    [Parameter(Mandatory = $true)]
    [Alias('IPAddress')]
    [IPAddress]$RemoteIPAddress,

    [Parameter(Mandatory = $true)]
    [Alias('Port')]
    [UInt16]$RemotePort
  )

  process {
    if ($Socket.ProtocolType -ne [Net.Sockets.ProtocolType]::Tcp) {
      Write-Error "Connect-Socket: The protocol type must be TCP to use Connect-Socket." -Category InvalidOperation -ErrorAction Stop
    }

    $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($RemoteIPAddress, $RemotePort))

    if ($Socket.Connected) {
      Write-Warning "Connect-Socket: The socket is connected to $($Socket.RemoteEndPoint). No action taken."
    } else {
      $Socket.Connect($RemoteEndPoint)
    }
  }
}