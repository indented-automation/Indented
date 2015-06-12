function Get-Manufacturer {
  # .SYNOPSIS
  #   Get the manufacturer associated with a MAC address.
  # .DESCRIPTION
  #   Get-Manufacturer attempts to find a manufacturer for a given MAC address. The list of manufacturers is cached locally in XML format, the function Update-ManufacturerList is used to populate and update the cached list.
  # .PARAMETER MACAddress
  #   A partial or full MAC address, with or without delimiters. Accepted delimiters are ., - and :.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Object
  # .EXAMPLE
  #   Get-Manufacturer 00:00:00:00:00:01
  # .EXAMPLE
  #   Get-Manufacturer 000000000001
  # .EXAMPLE
  #   Get-Manufacturer 00-00-00
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     02/04/2015 - Chris Dent - Updated to use Indented.Common XPath CmdLets.
  #     08/05/2013 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeLine = $true, ValueFromPipelineByPropertyname = $true)]
    [ValidatePattern('^([0-9A-Z]{2}[.\-:]?){2,5}([0-9A-Z]{2})')]
    [String]$MACAddress
  )
  
  process {
    $MACAddress -match '([0-9A-Z]{2})[.\-:]?([0-9A-Z]{2})[.\-:]?([0-9A-Z]{2})' | Out-Null
    $OUI = [String]::Format("{0}-{1}-{2}", $matches[1], $matches[2], $matches[3]).ToUpper()
  
    $FilePath = "$psscriptroot\..\var\oui.xml"
    
    if (Test-Path $FilePath) {
      $XPathNavigator = New-XPathNavigator $FilePath
      
      $XPathNavigator.Select("/Manufacturers/Manufacturer[OUI='$OUI']") |
        ForEach-Object {
          $_ | ConvertFrom-XPathNode -ToObject
        }
    } else {
      Write-Warning "Get-Manufacturer: The manufacturer list does not exist. Run Update-ManufacturerList to create."
    }
  }
}