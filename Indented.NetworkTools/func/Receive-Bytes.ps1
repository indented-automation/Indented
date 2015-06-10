function Receive-Bytes {
  # .SYNOPSIS
  #   Receive bytes using a TCP or UDP socket.
  # .DESCRIPTION
  #   Receive-Bytes is used to accept inbound TCP or UDP packets as a client exepcting a response from a server, or as a server waiting for incoming connections.
  #
  #   Receive-Bytes will listen for bytes sent to broadcast addresses provided the socket has been created using EnableBroadcast.
  # .PARAMETER BufferSize
  #   The maximum buffer size used for each receive operation.
  # .PARAMETER Socket
  #   A socket created using New-Socket. If the ProtocolType is TCP the socket must be connected first.
  # .INPUTS
  #   System.Net.Sockets.Socket
  #   System.UInt32
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.1 -RemotePort 25
  #   C:\PS>$Bytes = Receive-Bytes $Socket
  #   C:\PS>$Bytes | ConvertTo-String
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket -ProtocolType Udp -EnableBroadcast
  #   C:\PS>$Socket | Receive-Bytes
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     25/11/2010 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,
    
    [UInt32]$BufferSize = 1024
  )

  $Buffer = New-Object Byte[] $BufferSize 

  switch ($Socket.ProtocolType) {
    ([Net.Sockets.ProtocolType]::Tcp) {
      $BytesReceived = $null; $BytesReceived = $Socket.Receive($Buffer)
      Write-Verbose "Receive-Bytes: Received $BytesReceived from $($Socket.RemoteEndPoint): Connection State: $($Socket.Connected)"

      $Response = New-Object PsObject -Property ([Ordered]@{
        BytesReceived  = $BytesReceived;
        Data           = $Buffer[0..$($BytesReceived - 1)];
        RemoteEndPoint = $Socket.RemoteEndPoint | Select-Object *;
      })
      break
    }
    ([Net.Sockets.ProtocolType]::Udp) {
      # Create an IPEndPoint to use as a reference object
      if ($Socket.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork) {
        $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint([IPAddress]::Any, 0))
      } elseif ($Socket.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkv6) {
        $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint([IPAddress]::IPv6Any, 0))
      }
      
      $BytesReceived = $null; $BytesReceived = $Socket.ReceiveFrom($Buffer, [Ref]$RemoteEndPoint)
      Write-Verbose "Receive-Bytes: Received $BytesReceived from $($RemoteEndPoint.Address.IPAddressToString)"

      $Response = New-Object PsObject -Property ([Ordered]@{
        BytesReceived  = $BytesReceived;
        Data           = $Buffer[0..$($BytesReceived - 1)];
        RemoteEndPoint = $RemoteEndPoint | Select-Object *;
      })
      break
    }
  }
  if ($Response) {
    $Response.PsObject.TypeNames.Add("Indented.Sockets.SocketResponse")
    return $Response
  }
}