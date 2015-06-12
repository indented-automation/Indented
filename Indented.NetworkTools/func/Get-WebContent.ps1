function Get-WebContent {
  # .SYNOPSIS
  #   Get web content from a remote system.
  # .DESCRIPTION
  #   Attempt to get content from a remote web server.
  #
  #   Get-WebContent can ignore SSL errors or may be used to debug SSL connections.
  # .PARAMETER DebugSSL
  #   Return the content found at the URL as well as the HTTP response and any certificates.
  # .PARAMETER FileName
  #   Save the received content to the specified file.
  # .PARAMETER IgnoreSSLErrors
  #   Ignore SSL errors when using an HTTPS connection.
  # .PARAMETER URL
  #   The URL to receive content from.
  # .PARAMETER UseDefaultCredentials
  #   Pass the credentials of the current user with the request.
  # .PARAMETER UseSystemProxy
  #   Use IEs proxy settings and use default network credentials to authenticate against the proxy.
  # .INPUTS
  #   System.URI
  # .OUTPUTS
  #   Indented.Web.Response
  #   System.String
  # .EXAMPLE
  #   Get-WebContent "http://localhost"
  #
  #   Get web content from the specified URL (raw HTML).
  # .EXAMPLE
  #   Get-WebContent "https://someserver" -IgnoreSSLErrors
  #
  #   Get the content from https://someserver, ignore any SSL errors that occur.
  # .EXAMPLE
  #   Get-WebContent "https://www.google.co.uk" -DebugSSL | Select-Object -ExpandProperty SSLInformation
  #
  #   Get the content from www.google.co.uk and display the SSL information.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     01/05/2015 - Chris Dent - Added proxy control.
  #     31/03/2015 - Chris Dent - Overhauled.
  #     08/05/2013 - Chris Dent - Created.

  [CmdLetBinding(DefaultParameterSetName = 'IgnoreSSLErrors')]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [URI]$URL,
    
    [String]$FileName,

    [Parameter(ParameterSetName='IgnoreSSLErrors')]
    [Switch]$IgnoreSSLErrors,

    [Parameter(ParameterSetName='DebugSSL')]
    [Switch]$DebugSSL,
    
    [Switch]$UseDefaultCredentials,
    
    [Switch]$UseSystemProxy
  )

  $WebRequest = [Net.WebRequest]::Create($URL)
  $WebRequest.UseDefaultCredentials = $UseDefaultCredentials
  if ($DebugSSL) {
    # Immediately close the TCP connection. The intent is to debug SSL so SSL must be negotiated each time this is called.
    $WebRequest.KeepAlive = $false
    # Prevent caching of any content.
    $WebRequest.CachePolicy = New-Object Net.Cache.HttpRequestCachePolicy([Net.Cache.HttpRequestCacheLevel]::NoCacheNoStore)
  }
  if ($UseSystemProxy) {
    $WebRequest.Proxy = [Net.WebRequest]::GetSystemWebProxy()
    $WebRequest.Proxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials
  }
 
  $ServerCertificateValidationCallback = [Net.ServicePointManager]::ServerCertificateValidationCallback
  
  if ($IgnoreSSLErrors) {
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
  } elseif ($DebugSSL) {
    New-Variable SSLInformation -Scope Script -Force
    
    # Accept certificates regardless of errors, but make the certificate available as a variable.
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {
      param(
        [Object]$Sender,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [Security.Cryptography.X509Certificates.X509Chain]$Chain,
        [Net.Security.SslPolicyErrors]$PolicyErrors
      )
      
      # Using Select-Object here to instantiate new versions of each of these in memory. Some object type information will be lost.
      $Script:SSLInformation = New-Object PSObject -Property ([Ordered]@{
        Certificate  = $Certificate | Select-Object *
        Chain        = $Chain | Select-Object *
        PolicyErrors = $PolicyErrors
      })
      
      # Always accept the SSL connection regardless of the state of the certificate.
      return $true
    }
  }

  try {
    $HttpWebResponse = $WebRequest.GetResponse()
  } catch {
    $HttpWebResponse = $_.Exception.InnerException.Response
  }
  if ($HttpWebResponse.ContentType -like 'text/*') {
    $StreamReader = New-Object IO.StreamReader($HttpWebResponse.GetResponseStream(), [Text.Encoding]::UTF8)
    $WebContent = $StreamReader.ReadToEnd()
  } else {
    $Stream = $HttpWebResponse.GetResponseStream()
    $Buffer = New-Object Byte[] 100KB
    $WebContent = @()
    do {
      $Count = $Stream.Read($Buffer, 0, 100KB)
      $WebContent += $Buffer[0..$($Count - 1)]
    } until ($Count -le 0)
  }

  if ($psboundparameters.ContainsKey('FileName')) {
    if ($HttpWebResponse.ContentType -like 'text\*') {
      $WebContent | Set-Content $FileName
    } else {
      $WebContent | Set-Content $FileName -Encoding Byte
    }
  }  

  if ($IgnoreSSLErrors -or -not $DebugSSL) {
    if (-not $psboundparameters.ContainsKey('FileName')) {
      $WebContent
    }
  } else {
    New-Object PSObject -Property ([Ordered]@{
      WebContent     = $WebContent
      HttpResponse   = $HttpWebResponse
      SSLInformation = $Script:SSLInformation
    })
  }
  
  [Net.ServicePointManager]::ServerCertificateValidationCallback = $ServerCertificateValidationCallback
}