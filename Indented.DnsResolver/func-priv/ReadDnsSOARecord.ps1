function ReadDnsSOARecord {
  # .SYNOPSIS
  #   Reads properties for an SOA record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     MNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     RNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    SERIAL                     |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    REFRESH                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     RETRY                     |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    EXPIRE                     |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    MINIMUM                    |
  #    |                                               |
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
  #   Indented.DnsResolver.Message.ResourceRecord.SOA
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.SOA")

  # Property: NameServer
  $ResourceRecord | Add-Member NameServer -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: ResponsiblePerson
  $ResourceRecord | Add-Member ResponsiblePerson -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: Serial
  $ResourceRecord | Add-Member Serial -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Refresh
  $ResourceRecord | Add-Member Refresh -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Retry
  $ResourceRecord | Add-Member Retry -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Expire
  $ResourceRecord | Add-Member Expire -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: MinimumTTL
  $ResourceRecord | Add-Member MinimumTTL -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} (`n" +
                     "    {2} ; serial`n" +
                     "    {3} ; refresh ({4})`n" +
                     "    {5} ; retry ({6})`n" +
                     "    {7} ; expire ({8})`n" +
                     "    {9} ; minimum ttl ({10})`n" +
                     ")",
      $this.NameServer,
      $this.ResponsiblePerson,
      $this.Serial.ToString().PadRight(10, ' '),
      $this.Refresh.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Refresh),
      $this.Retry.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Retry),
      $this.Expire.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Expire),
      $this.MinimumTTL.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Refresh))
  }

  return $ResourceRecord
}




