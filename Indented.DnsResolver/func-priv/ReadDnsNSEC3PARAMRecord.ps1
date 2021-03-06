function ReadDnsNSEC3PARAMRecord {
  # .SYNOPSIS
  #   Reads properties for an NSEC3PARAM record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       HASH ALG        |         FLAGS         |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   ITERATIONS                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       SALT LEN        |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                      SALT                     /
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
  #   Indented.DnsResolver.Message.ResourceRecord.NSEC3PARAM
  # .LINK
  #   http://www.ietf.org/rfc/rfc5155.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.NSEC3PARAM")

  # Property: HashAlgorithm
  $ResourceRecord | Add-Member HashAlgorithm -MemberType NoteProperty -Value ([Indented.DnsResolver.NSEC3HashAlgorithm]$BinaryReader.ReadByte())
  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Iterations
  $ResourceRecord | Add-Member Iterations -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SaltLength
  $ResourceRecord | Add-Member SaltLength -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Salt
  $HexString = ""
  if ($ResouceRecord.SaltLength -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.SaltLength)
    $HexString = ConvertTo-String $Bytes -Hexadecimal
  }
  $ResourceRecord | Add-Member Salt -MemberType NoteProperty -Value $HexString
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      ([Byte]$this.HashAlgorithm).ToString(),
      $this.Flags.ToString(),
      $this.Iterations.ToString(),
      $this.Salt)
  }
  
  return $ResourceRecord
}




