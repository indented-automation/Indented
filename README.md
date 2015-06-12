# Indented

A collection of somewhat hierarchical modules including:

 * Indented.Common - A shared library
 * Indented.DnsResolver - A dig-like debug capable DNS resolver.
 * Indented.NetworkTools - IP maths and socket handling CmdLets.
 * Indented.Utility - A small collection of tools which don't fit anywhere else.

Indented.Common
---------------

Compare-Array
ConvertFrom-XPathNode
ConvertTo-Byte
ConvertTo-String
ConvertTo-TimeSpanString
ConvertTo-Type
ConvertTo-Xml
Get-CommandParameters
Get-Hash
New-DynamicModuleBuilder
New-DynamicParameter
New-Enum
New-XPathNavigator
Set-XPathAttribute
Update-PropertyOrder

Indented.DnsResolver
--------------------

Add-InternalDnsCacheRecord
Get-Dns
Get-DnsServerList
Get-InternalDnsCacheRecord
Initialize-InternalDnsCache
Remove-InternalDnsCacheRecord
Update-InternalRootHints

Indented.NetworkTools
---------------------

Connect-Socket
ConvertFrom-HexIP
ConvertTo-BinaryIP
ConvertTo-DecimalIP
ConvertTo-DottedDecimalIP
ConvertTo-HexIP
ConvertTo-Mask
ConvertTo-MaskLength
ConvertTo-Subnet
Disconnect-Socket
Get-BroadcastAddress
Get-NetworkAddress
Get-NetworkRange
Get-NetworkSummary
Get-Subnets
Get-WebContent
Get-WhoIs
New-BinaryReader
New-Socket
Receive-Bytes
Remove-Socket
Send-Bytes
Test-SmtpServer
Test-SubnetMember
Test-TcpPort
Test-UdpPort

Indented.Utilty
---------------

Get-Manufacturer
Select-HIString
Update-ManufacturerList