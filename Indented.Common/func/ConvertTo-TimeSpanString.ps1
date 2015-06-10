function ConvertTo-TimeSpanString {
  # .SYNOPSIS
  #   Converts a number of seconds to a string.
  # .DESCRIPTION
  #   ConvertTo-TimeSpanString accepts values in seconds then uses integer division to represent that time as a string.
  #
  #   ConvertTo-TimeSpanString accepts UInt32 values, overcoming the Int32 type limitation built into New-TimeSpan.
  #
  #   The format below is used, omitting any values of 0:
  #
  #   # weeks # days # hours # minutes # seconds
  #
  # .PARAMETER Seconds
  #   A number of seconds as an unsigned 32-bit integer. The maximum value is 4294967295 ([UInt32]::MaxValue).
  # .INPUTS
  #   System.UInt32
  # .OUTPUTS
  #   System.String  
  # .EXAMPLE
  #   ConvertTo-TimeSpanString 28800
  # .EXAMPLE
  #   [UInt32]::MaxValue | ConvertTo-TimeSpanString
  # .EXAMPLE
  #   86400, 700210 | ConvertTo-TimeSpanString
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     15/10/2013 - Chris Dent - Forked from source module.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
    [UInt32]$Seconds
  )

  begin {
    # Time periods described in seconds
    $Formats = [Ordered]@{
      week = 604800;
      day = 86400;
      hour = 3600;
      minute = 60;
      second = 1;
    }
  }
  
  process {
    $Values = $Formats.Keys | ForEach-Object {
      $Key = $_

      # Calculate the remainder prior to integer division
      $Remainder = $Seconds % $Formats[$Key]
      $Value = ($Seconds - $Remainder) / $Formats[$Key]
      # Decrement the original value
      $Seconds = $Remainder
      
      if ($Value) {
        # if the value is greater than 1, make the key name plural
        if ($Value -gt 1) { $Key = "$($Key)s" }
        
        "$Value $Key"
      }
    }
    return "$Values"
  }
}