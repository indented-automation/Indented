function ReadDnsTSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an TSIG record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   ALGORITHM                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   TIMESIGNED                  |
  #    |                                               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     FUDGE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    MACSIZE                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      MAC                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  ORIGINALID                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ERROR                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   OTHERSIZE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   OTHERDATA                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.DnsResolver.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader 
  # .OUTPUTS
  #   Indented.DnsResolver.Message.ResourceRecord.TSIG
  # .LINK
  #   http://www.ietf.org/rfc/rfc2845.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.TSIG")
  
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: TimeSigned
  $ResourceRecord | Add-Member TimeSigned -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt48()))
  # Property: Fudge
  $ResourceRecord | Add-Member Fudge -MemberType NoteProperty -Value ((New-TimeSpan -Seconds ($BinaryReader.ReadBEUInt16())).TotalMinutes)
  # Property: MACSize
  $ResourceRecord | Add-Member KeySize -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: MAC
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.KeySize)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  # Property: Error
  $ResourceRecord | Add-Member Expiration -MemberType NoteProperty -Value ([Indented.DnsResolver.RCode]$BinaryReader.ReadBEUInt16())
  # Property: OtherSize
  $ResourceRecord | Add-Member OtherSize -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()

  if ($ResourceRecord.OtherSize -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.OtherSize)
    $HexString = ConvertTo-String $Bytes -Hexadecimal
  }

  # Property: OtherData
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3} {4}",
      $this.Algorithm,
      $this.TimeSigned,
      $this.Fudge,
      $this.MAC,
      $this.OtherData)
  }
  
  return $ResourceRecord
}




