function Get-Hash {
  # .SYNOPSIS
  #   Get a hash for the requested object.
  # .DESCRIPTION
  #   Generate a hash using .NET cryptographic service providers from the passed string, file or byte array.
  # .PARAMETER Algorithm
  #   The hashing algorithm to be used. By default, Get-Hash generates an MD5 hash.
  #
  #   Available algorithms are MD5, SHA1, SHA256, SHA384 and SHA512.
  # .PARAMETER ByteArray
  #   Generate a hash from the byte array.
  # .PARAMETER FileName
  #   Generate a hash of the file.
  # .PARAMETER String
  #   Generate a hash from the specified string.
  # .INPUTS
  #   System.Byte[]
  #   System.String
  # .OUTPUTS
  #   System.Byte[]
  #   System.String
  # .EXAMPLE
  #   Get-ChildItem C:\Windows | Get-Hash
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     01/05/2015 - Chris Dent - BugFix: Open file stream.
  #     22/04/2014 - Chris Dent - Created.
  
  [CmdLetBinding(DefaultParameterSetName = 'String')]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ParameterSetName = 'String')]
    [String]$String,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'FileName')]
    [ValidateScript( { Test-Path $_ -PathType Leaf } )]
    [Alias('FullName')]
    [String]$FileName,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByteArray')]
    [Byte[]]$ByteArray,

    [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
    [String]$Algorithm = "MD5",
    
    [Switch]$AsString
  )

  begin {
    $CryptoServiceProvider = switch ($Algorithm) {
      "MD5"    { New-Object Security.Cryptography.MD5CryptoServiceProvider; break }
      "SHA1"   { New-Object Security.Cryptography.SHA1CryptoServiceProvider; break }
      "SHA256" { New-Object Security.Cryptography.SHA256CryptoServiceProvider; break }
      "SHA384" { New-Object Security.Cryptography.SHA384CryptoServiceProvider; break }
      "SHA512" { New-Object Security.Cryptography.SHA512CryptoServiceProvider; break }
    }
  }

  process {
    if ($pscmdlet.ParameterSetName -eq 'String') {
      $ByteArray = ConvertTo-Byte $String
    } elseif ($pscmdlet.ParameterSetName -eq 'FileName') {
      # Ensure the full path to the file is available
      $FullName = Get-Item $FileName | Select-Object -ExpandProperty FullName
      
      $FileStream = New-Object IO.FileStream($FullName, "Open", "Read", "Read")
      $ByteArray = New-Object Byte[] $FileStream.Length
      $null = $FileStream.Read($ByteArray, 0, $FileStream.Length)
      $FileStream.Close()
    }
    
    $HashValue = $CryptoServiceProvider.ComputeHash($ByteArray)
    
    if ($AsString) {
      ConvertTo-String $HashValue -Hexadecimal
    } else {
      $HashValue
    }
  }
  
  end {
    $CryptoServiceProvider.Dispose()
  }
}