function ConvertTo-Byte {
  # .SYNOPSIS
  #   Converts a value to a byte array.
  # .DESCRIPTION
  #   ConvertTo-Byte acts as a wrapper for a number of .NET methods which return byte arrays.
  # .PARAMETER BigEndian
  #   If a multi-byte value is being returned this parameter can be used to reverse the byte order. By default, the least significant byte is returned first.
  #
  #   The BigEndian parameter is only effective when a numeric value is passed as the Value.
  # .PARAMETER Unicode
  #   Treat text strings as Unicode instead of ASCII.
  # .PARAMETER Value
  #   The value to convert. If a string value is passed it is treated as ASCII text and converted. If a numeric value is entered the type is tested an BitConverter.GetBytes is used.
  # .INPUTS
  #   System.Object
  # .OUTPUTS
  #   System.Byte[]
  # .EXAMPLE
  #   "The cow jumped over the moon" | ConvertTo-Byte
  # .EXAMPLE
  #   123456 | ConvertTo-Byte
  # .EXAMPLE
  #   [UInt16]60000 | ConvertTo-Byte -BigEndian
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     13/01/2015 - Chris Dent - Added Unicode option.
  #     25/11/2010 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Value,

    [Switch]$BigEndian,

    [Switch]$Unicode
  )
  
  process {
    switch -Regex ($Value.GetType().Name) {
      'Byte|U?Int(16|32|64)' { 
        $Bytes = [BitConverter]::GetBytes($Value)
        if ($BigEndian) {
            [Array]::Reverse($Bytes)
        }
        return $Bytes
      }
      default {
        if ($Unicode) {
          return [Text.Encoding]::Unicode.GetBytes([String]$Value)
        } else {
          return [Text.Encoding]::ASCII.GetBytes([String]$Value)
        }
      }
    }
  }
}