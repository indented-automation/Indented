function ReadDnsMessageHeader {
  # .SYNOPSIS
  #   Reads a DNS message header from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      ID                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    QDCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ANCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    NSCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ARCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS message.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader
  # .OUTPUTS
  #   Indented.DnsResolver.Message.Header

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )

  $DnsMessageHeader = NewDnsMessageHeader

  # Property: ID
  $DnsMessageHeader.ID = $BinaryReader.ReadBEUInt16()

  $Flags = $BinaryReader.ReadBEUInt16()

  # Property: QR
  $DnsMessageHeader.QR = [Indented.DnsResolver.QR]($Flags -band 0x8000)
  # Property: OpCode
  $DnsMessageHeader.OpCode = [Indented.DnsResolver.OpCode]($Flags -band 0x7800)
  # Property: Flags
  $DnsMessageHeader.Flags = [Indented.DnsResolver.Flags]($Flags -band 0x07F0)
  # Property: RCode
  $DnsMessageHeader.RCode = [Indented.DnsResolver.RCode]($Flags -band 0x000F)
  # Property: QDCount
  $DnsMessageHeader.QDCount = $BinaryReader.ReadBEUInt16()
  # Property: ANCount
  $DnsMessageHeader.ANCount = $BinaryReader.ReadBEUInt16()
  # Property: NSCount
  $DnsMessageHeader.NSCount = $BinaryReader.ReadBEUInt16()
  # Property: ARCount
  $DnsMessageHeader.ARCount = $BinaryReader.ReadBEUInt16()

  return $DnsMessageHeader
}
