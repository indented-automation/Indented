function New-Socket {
  # .SYNOPSIS
  #   Creates a new network socket to use to send and receive packets over a network.
  # .DESCRIPTION
  #   New-Socket creates an instance of System.Net.Sockets.Socket for use with Send-Bytes and Receive-Bytes.
  # .PARAMETER EnableBroadcast
  #   Allows a UDP socket to send and receive datagrams from the directed or undirected broadcast IP address.
  # .PARAMETER LocalIPAddress
  #   If configuring a server port (to listen for requests) an IP address may be defined. By default the Socket is created to listen on all available addresses.
  # .PARAMETER LocalPort
  #   If configuring a server port (to listen for requests) the local port number must be defined.
  # .PARAMETER NoTimeout
  #   By default, send and receive timeout values are set for all operations. These values can be overridden to allow configuration of a socket which will never stop either attempting to send or attempting to receive.
  # .PARAMETER ProtocolType
  #   ProtocolType must be either TCP or UDP. This parameter also sets the SocketType to Stream for TCP and Datagram for UDP.
  # .PARAMETER ReceiveTimeout
  #   A timeout for individual Receive operations performed with this socket. The default value is 5 seconds; this CmdLet allows the value to be set between 1 and 30 seconds.
  # .PARAMETER SendTimeout
  #   A timeout for individual Send operations performed with this socket. The default value is 5 seconds; this CmdLet allows the value to be set between 1 and 30 seconds.
  # .INPUTS
  #   System.Net.Sockets.ProtocolType
  #   System.Net.IPAddress
  #   System.UInt16
  #   System.Int32
  # .OUTPUTS
  #   System.Net.Sockets.Socket
  # .EXAMPLE
  #   New-Socket -LocalPort 25
  #
  #   Configure a socket to listen using TCP/25 (as a network server) on all locally configured IP addresses.
  # .EXAMPLE
  #   New-Socket -ProtocolType Udp
  #
  #   Configure a socket for sending UDP datagrams (as a network client).
  # .EXAMPLE
  #   New-Socket -LocalPort 23 -LocalIPAddress 10.0.0.1
  #
  #   Configure a socket to listen using TCP/23 (as a network server) on the IP address 10.0.0.1 (the IP address must exist and be bound to an interface).
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     25/11/2010 - Chris Dent - Created.
  
  [CmdLetBinding(DefaultParameterSetName = 'ClientSocket')]
  param(
    [ValidateSet("Tcp", "Udp")]
    [Net.Sockets.ProtocolType]$ProtocolType = "Tcp",
    
    [Parameter(ParameterSetName = 'ServerSocket')]
    [IPAddress]$LocalIPAddress = [IPAddress]::Any,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ServerSocket')]
    [UInt16]$LocalPort,

    [Parameter(ParameterSetName = 'ClientSocket')]
    [Switch]$EnableBroadcast,
   
    [Switch]$IPv6,
   
    [Switch]$NoTimeout,
    
    [ValidateRange(1, 30)]
    [Int32]$ReceiveTimeOut = 5,
    
    [ValidateRange(1, 30)]
    [Int32]$SendTimeOut = 5
  )
  
  switch ($ProtocolType) {
    ([Net.Sockets.ProtocolType]::Tcp) { $SocketType = [Net.Sockets.SocketType]::Stream; break }
    ([Net.Sockets.ProtocolType]::Udp) { $SocketType = [Net.Sockets.SocketType]::Dgram; break } 
  }

  $AddressFamily = [Net.Sockets.AddressFamily]::InterNetwork

  if ($IPv6) {
    $AddressFamily = [Net.Sockets.AddressFamily]::Internetworkv6
    # If LocalIPAddress has not been explicitly defined, and IPv6 is expected, change to all IPv6 addresses.
    if ($LocalIPAddress -eq [IPAddress]::Any) {
      $LocalIPAddress = [IPAddress]::IPv6Any
    }
  }

  $Socket = New-Object Net.Sockets.Socket(
    $AddressFamily,
    $SocketType,
    $ProtocolType
  )

  if ($EnableBroadcast) {
    if ($ProtocolType -eq [Net.Sockets.ProtocolType]::Udp) {
      $Socket.EnableBroadcast = $true
    } else {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "EnableBroadcast cannot be set for TCP sockets."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
  }

  # Bind a local end-point to listen for inbound requests.
  if ($pscmdlet.ParameterSetName -eq 'ServerSocket') {
    $LocalEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($LocalIPAddress, $LocalPort))
    $Socket.Bind($LocalEndPoint)
  }

  # Set timeout values if applicable.
  if (-not $NoTimeout) {
    $Socket.SendTimeOut = $SendTimeOut * 1000
    $Socket.ReceiveTimeOut = $ReceiveTimeOut * 1000
  }

  return $Socket
}