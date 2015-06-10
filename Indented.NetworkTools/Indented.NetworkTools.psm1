#
# Module loader for Indented.NetworkTools
#
# Author: Chris Dent
#
# Change log:
#   02/04/2015 - Chris Dent - Refactored.
#   05/07/2012 - Chris Dent - Created.


# Static enumerations
[Array]$Enum = @()

if ($Enum.Count -ge 1) {
  New-Variable NetworkToolsModuleBuilder -Value (New-DynamicModuleBuilder Indented.NetworkTools -UseGlobalVariable $false) -Scope Script
  $Enum | ForEach-Object {
    Import-Module "$psscriptroot\enum\$_.ps1"
  }
}

# Private functions
[Array]$Private = 'ConvertToNetworkObject'

if ($Private.Count -ge 1) {
  $Private | ForEach-Object {
    Import-Module "$psscriptroot\func-priv\$_.ps1"
  }
}

# Public functions
[Array]$Public = 'Connect-Socket',
                 'ConvertFrom-HexIP',
                 'ConvertTo-BinaryIP',
                 'ConvertTo-DecimalIP',
                 'ConvertTo-DottedDecimalIP',
                 'ConvertTo-HexIP',
                 'ConvertTo-Mask',
                 'ConvertTo-MaskLength',
                 'ConvertTo-Subnet',
                 'Disconnect-Socket',
                 'Get-BroadcastAddress',
                 'Get-NetworkAddress',
                 'Get-NetworkRange',
                 'Get-NetworkSummary',
                 'Get-Subnets',
                 'Get-WhoIs',
                 'New-BinaryReader',
                 'New-Socket',
                 'Receive-Bytes',
                 'Remove-Socket',
                 'Send-Bytes',
                 'Test-SmtpServer',
                 'Test-SubnetMember',
                 'Test-TcpPort',
                 'Test-UdpPort'

if ($Public.Count -ge 1) {
  $Public | ForEach-Object {
    Import-Module "$psscriptroot\func\$_.ps1"
  }
}