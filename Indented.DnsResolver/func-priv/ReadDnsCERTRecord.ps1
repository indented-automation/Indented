function ReadDnsCERTRecord {
  # .SYNOPSIS
  #   Reads properties for an CERT record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     TYPE                      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEY TAG                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |                       |
  #    +--+--+--+--+--+--+--+--+                       |
  #    /               CERTIFICATE or CRL              /
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
  #   Indented.DnsResolver.Message.ResourceRecord.CERT
  # .LINK
  #   http://www.ietf.org/rfc/rfc4398.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.CERT")

  # Property: CertificateType
  $ResourceRecord | Add-Member CertificateType -MemberType NoteProperty -Value ([Indented.DnsResolver.CertificateType]$Reader.ReadBEUInt16())
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $Reader.ReadBEUInt16()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.DnsResolver.EncryptionAlgorithm]$Reader.ReadByte())
  # Property: Certificate
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member Certificate -MemberType NoteProperty -Value $Base64String
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.CertificateType.ToString(),
      ([UInt16]$this.KeyTag).ToString(),
      ([UInt16]$this.Algorithm).ToString(),
      $this.Certificate)
  }
  
  return $ResourceRecord
}




