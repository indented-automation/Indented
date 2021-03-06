function ReadDnsKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an KEY record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     FLAGS                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        PROTOCOL       |       ALGORITHM       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  PUBLIC KEY                   /
  #    /                                               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   The flags field takes the following format, discussed in RFC 2535 3.1.2:
  #
  #      0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5
  #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  #    |  A/C  | Z | XT| Z | Z | NAMTYP| Z | Z | Z | Z |      SIG      |
  #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
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
  #   Indented.DnsResolver.Message.ResourceRecord.KEY
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc2931.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.KEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ($BinaryReader.ReadBEUInt16())
  # Property: Authentication/Confidentiality (bit 0 and 1 of Flags)
  $ResourceRecord | Add-Member AuthenticationConfidentiality -MemberType ScriptProperty -Value {
    [Indented.DnsResolver.KEYAC]([Byte]($this.Flags -shr 14))
  }
  # Property: Flags extension (bit 3)
  if (($Flags -band 0x1000) -eq 0x1000) {
    $ResourceRecord | Add-Member FlagsExtension -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  }
  # Property: NameType (bit 6 and 7)
  $ResourceRecord | Add-Member NameType -MemberType ScriptProperty -Value {
    [Indented.DnsResolver.KEYNameType]([Byte](($Flags -band 0x0300) -shr 9))
  }
  # Property: SignatoryField (bit 12 and 15)
  $ResourceRecord | Add-Member SignatoryField -MemberType ScriptProperty -Value {
    [Boolean]($this.Flags -band 0x000F)
  }
  # Property: Protocol
  $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([Indented.DnsResolver.KEYProtocol]$BinaryReader.ReadByte())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.DnsResolver.EncryptionAlgorithm]$BinaryReader.ReadByte())
  
  if ($ResourceRecord.AuthenticationConfidentiality -ne [Indented.DnsResolver.KEYAC]::NoKey) {
    # Property: PublicKey
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
    $Base64String = ConvertTo-String $Bytes -Base64
    $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String
  }

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} ( {3} )",
      $this.Flags,
      ([Byte]$this.Protocol).ToString(),
      ([Byte]$this.Algorithm).ToString(),
      $this.PublicKey)
  }
  
  return $ResourceRecord
}




