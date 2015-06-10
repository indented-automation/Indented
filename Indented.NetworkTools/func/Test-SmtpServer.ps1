function Test-SmtpServer {
  # .SYNOPSIS
  #   Test SMTP by executing a simple SMTP conversation.
  # .DESCRIPTION
  #   Test-SmtpServer attemps to send an e-mail message using the specific SMTP server.
  # .PARAMETER From
  #   A sender address.
  # .PARAMETER IPAddress
  #   The server to connect to.
  # .PARAMETER Port
  #   The TCP Port to use. By default, Port 25 is used.
  # .PARAMETER To
  #   The recipient of the test e-mail.
  # .INPUTS
  #   System.Net.IPAddress
  #   System.String
  #   System.UInt32
  # .OUTPUTS
  #   System.Object
  # .EXAMPLE
  #   Test-SmtpServer -IPAddress 1.2.3.4 -To "me@domain.example" -From "me@domain.example"
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     15/04/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IPAddress]$IPAddress,
    
    [UInt16]$Port = 25,

    [Parameter(Mandatory = $true)]
    [String]$To,
    
    [Parameter(Mandatory = $true)]
    [String]$From
  )

  $CommandList = "helo there", "mail from: <$From>", "rcpt to: <$To>", "data", "Subject: Test message from Test-Smtp: $(Get-Date)`r`n."

  $Socket = New-Socket
  try {
    Connect-Socket $Socket -RemoteIPAddress $IPAddress -RemotePort $Port
  } catch [Net.Sockets.SocketException] {
    $ErrorRecord = New-Object Management.Automation.ErrorRecord(
      (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
      "Connection to $IPAddress failed",
      [Management.Automation.ErrorCategory]::ConnectionError,
      $Socket)
    $pscmdlet.ThrowTerminatingError($ErrorRecord)
  }
  
  New-Object PsObject -Property ([Ordered]@{
    Operation = "RECEIVE";
    Data = (Receive-Bytes $Socket | ConvertTo-String);
  })

  # Send the remaining commands (terminated with CRLF, `r`n) and get the response
  $CommandList | ForEach-Object {
    New-Object PsObject -Property ([Ordered]@{
      Operation = "SEND";
      Data = $_;
    })
 
    Send-Bytes $Socket -Data (ConvertTo-Byte "$_`r`n")

    New-Object PsObject -Property ([Ordered]@{
      Operation = "RECEIVE";
      Data = (Receive-Bytes $Socket | ConvertTo-String);
    })
  }
  Disconnect-Socket $Socket
  Remove-Socket $Socket
}