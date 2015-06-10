function Disconnect-Socket {
  # .SYNOPSIS
  #   Disconnect a connected TCP socket.
  # .DESCRIPTION
  #   A TCP socket which has been connected using Connect-Socket may be disconnected using this CmdLet.
  # .PARAMETER Shutdown
  #   By default, Disconnect-Socket attempts to shutdown the connection before disconnecting. This behaviour can be overridden by setting this parameter to False.
  # .PARAMETER Socket
  #   A socket created using New-Socket and connected using Connect-Socket.
  # .INPUTS
  #   System.Net.Sockets.Socket
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>$Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
  #   C:\PS>$Socket | Disconnect-Socket
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     06/01/2014 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,

    [Boolean]$Shutdown = $true
  )

  process {
    if ($Socket.ProtocolType -ne [Net.Sockets.ProtocolType]::Tcp) {
      Write-Error "Disconnect-Socket: The protocol type must be TCP to use Disconnect-Socket." -Category InvalidOperation
      return
    }

    if (-not $Socket.Connected) {
      Write-Warning "Disconnect-Socket: The socket is not connected. No action taken."
    } else {
      Write-Verbose "Disconnect-Socket: Disconnected socket from $($Socket.RemoteEndPoint)."

      if ($Shutdown) {
        $Socket.Shutdown([Net.Sockets.SocketShutdown]::Both)
      }

      # Disconnect the socket and allow reuse.
      $Socket.Disconnect($true)
    }
  }
}