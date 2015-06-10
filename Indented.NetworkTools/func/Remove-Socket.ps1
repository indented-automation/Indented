function Remove-Socket {
  # .SYNOPSIS
  #   Removes a socket, releasing all resources.
  # .DESCRIPTION
  #   A socket may be removed using Remove-Socket if it is no longer required.
  # .PARAMETER Socket
  #   A socket created using New-Socket.
  # .INPUTS
  #   System.Net.Sockets.Socket
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>$Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
  #   C:\PS>$Socket | Disconnect-Socket
  #   C:\PS>$Socket | Remove-Socket
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     25/11/2010 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket
  )

  process {
    # Close the socket
    $Socket.Close()
  }
}