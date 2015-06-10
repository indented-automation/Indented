#
# Module loader for Indented.Common
#
# Author: Chris Dent
#

# Public functions
$Public = 'Compare-Array',
          'ConvertFrom-XPathNode',
          'ConvertTo-Byte',
          'ConvertTo-String',
          'ConvertTo-TimeSpanString',
          'ConvertTo-Type',
          'ConvertTo-Xml',
          'Get-CommandParameters',
          'Get-Hash',
          'New-DynamicModuleBuilder',
          'New-DynamicParameter',
          'New-Enum',
          'New-XPathNavigator',
          'Set-XPathAttribute',
          'Update-PropertyOrder'

$Public | ForEach-Object {
  Import-Module "$psscriptroot\func\$_.ps1"
}