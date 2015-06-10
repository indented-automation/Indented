function Test-UdpPort {
  # .SYNOPSIS
  #   Attempt to whether a UDP port is willing to receive packets.
  # .DESCRIPTION
  #   Test-UdpPort has a number of limitations due to the nature of UDP:
  #
  #     * UDP is a connectionless protocol, reciept of the packet by the target cannot be guaranteed (or tested remotely).
  #     * The remote server may elect to ignore the packet even if it has been received.
  #
  #   Services such as DNS and NTP will not (or are not likely to) respond to a single byte packet. If they did the potential for amplification attacks would be quite extraordinary.
  #
  #   Such limitations make this CmdLet moderately useless in a practical context without a sniffer or some other method of logging receipt of the generated packet on the target.
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
  #   Test-UdpPort 10.0.0.1 1001
  #
  #   Send a single-byte packet to the UDP service running on port 1001 on the remote server.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     09/01/2015 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ComputerName,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [UInt16]$Port
  )
  
  if (-not ([Net.IPAddress]::TryParse($ComputerName, [Ref]$null))) {
    $DnsRecord = [Net.Dns]::GetHostEntry($ComputerName) |
      Select-Object -Expand AddressList |
      Select-Object -First 1
    $ComputerName = $DnsRecord.IPAddressToString
  }
  
  # Set up a socket with a 5 second receive timeout.
  $UdpSocket = New-Socket -ProtocolType Udp -ReceiveTimeout 5
  Send-Bytes $UdpSocket -RemoteIPAddress $ComputerName -RemotePort $Port -Data 0
  # Listen for a reply on the socket. It is unlikely we'll see one.
  try { Receive-Bytes $UdpSocket } catch { }
  if ($?) {
    return $true
  }
  return $false
}