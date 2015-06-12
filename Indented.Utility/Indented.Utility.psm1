#
# Module loader for Indented.Utility
#
# Author: Chris Dent
#

# Public functions
[Array]$Public = 'Get-Manufacturer',
                 'Select-HIString',
                 'Update-ManufacturerList'

if ($Public.Count -ge 1) {
  $Public | ForEach-Object {
    Import-Module "$psscriptroot\func\$_.ps1"
  }
}