function Get-WhoIs {
  # .SYNOPSIS
  #   Get a WhoIs record using servers published via whois-servers.net.
  # .DESCRIPTION
  #   For IP lookups, Get-WhoIs uses whois.arin.net as a starting point, chasing referrals within the record to get to an authoritative answer.
  # 
  #   For name lookups, Get-WhoIs uses the whois-servers.net service to attempt to locate a whois server for the top level domain (TLD).
  #      
  #   Get-WhoIs connects directly to whois servers using TCP/43.
  # .PARAMETER Name
  #   The name or IP address to locate the WhoIs record for.
  # .PARAMETER WhoIsServer
  #   A WhoIs server to use for the query. Dynamically populated, but can be overridden.
  # .PARAMETER Command
  #   A command to execute on the WhoIs server if the server requires a command prefixing before the query.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Get-WhoIs indented.co.uk
  # .EXAMPLE
  #   Get-WhoIs 10.0.0.1
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     15/01/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]$Name,
    
    [String]$WhoIsServer,

    [String]$Command
  )
 
  if (-not $WhoIsServer) {
    if ([IPAddress]::TryParse($Name, [Ref]$null) -or $Name.EndsWith("arpa")) {
      $WhoIsServer = $WhoIsServerName = "whois.arin.net"
      $Command = "n "
    } else {
      $WhoIsServer = $WhoIsServerName = "$($Name.Split('.')[-1]).whois-servers.net"
    }
  }
  if (-not ([Net.IPAddress]::TryParse($WhoIsServer, [Ref]$null))) {
    $WhoIsServerRecord = [Net.Dns]::GetHostEntry($WhoIsServer) |
      Select-Object -Expand AddressList |
      Select-Object -First 1
    $WhoIsServer = $WhoIsServerRecord.IPAddressToString
  }
  
  if ($WhoIsServer) {
    Write-Verbose "Get-WhoIs: Asking $WhoIsServerName ($WhoIsServer) for $Name using command $Command$Name"

    $Socket = New-Socket
    try {
      Connect-Socket $Socket -RemoteIPAddress $WhoIsServer -RemotePort 43
    } catch [Net.Sockets.SocketException] {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
        "Connection to $IPAddress failed",
        [Management.Automation.ErrorCategory]::ConnectionError,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
    
    Send-Bytes $Socket -Data ("$Command$Name`r`n" | ConvertTo-Byte)
    
    $ReceivedData = @()
    do {
      $ReceivedData += Receive-Bytes $Socket -BufferSize 4096
      Write-Verbose "Get-WhoIs: Received $($ReceivedData[-1].BytesReceived) bytes from $($ReceivedData[-1].RemoteEndPoint.Address)"
    } until ($ReceivedData[-1].BytesReceived -eq 0)

    $WhoIsRecord = ConvertTo-String ($ReceivedData | Select-Object -ExpandProperty Data)
    if ($WhoIsRecord -match 'ReferralServer: whois://(.+):') {
      Write-Verbose "Get-WhoIs: Following referral for $Name to $($matches[1])"
      Get-WhoIs $Name -WhoIsServer $matches[1]
    } else {
      $WhoIsRecord
    }
    Disconnect-Socket $Socket
    Remove-Socket $Socket
  }
}