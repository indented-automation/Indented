function Update-ManufacturerList {
  # .SYNOPSIS
  #   Updates the cached manufacturer list maintained by the IEEE.
  # .DESCRIPTION
  #   Update-ManufacturerList attempts to download the assigned list of MAC address prefixes using Get-WebContent.
  #    
  #   The return is converted into an XML format to act as the cache file for Get-Manufacturer.
  # .PARAMETER Source
  #    By default, the manufacturer list is downloaded from http://standards.ieee.org/develop/regauth/oui/oui.txt. An alternate source may be specified if required.
  # .INPUTS
  #   System.String
  # .EXAMPLE
  #   Update-ManufacturerList
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     02/04/2015 - Chris Dent - Refactored.
  #     08/05/2013 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [String]$Source = "http://standards-oui.ieee.org/oui.txt"
  )
 
  $Writer = New-Object IO.StreamWriter("$psscriptroot\..\var\oui.xml")
  $Writer.WriteLine("<?xml version='1.0'?>")
  $Writer.WriteLine("<Manufacturers>")
  
  Get-WebContent $Source -UseSystemProxy |
    ForEach-Object {
      switch -regex ($_) {
        '^\s*([0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2})\s+\(hex\)[\s\t]*(.+)$' {
          $OUI = $matches[1]
          $Organisation = $matches[2]
          break
        }
        '^\s*([0-9A-F]{6})\s+\(base 16\)[\s\t]*(.+)$' { 
          $CompanyID = $matches[1]
          [Array]$Address = $matches[2]
          break
        }
        '^\s+(\S+.+)$' {
          $Address += $matches[1]
          break
        }
        '^\s*$' {
          if ($OUI -and $Organisation) {
            $Writer.WriteLine("<Manufacturer>")
            $Writer.WriteLine("<OUI>$OUI</OUI>")
            $Writer.WriteLine("<Organization><![CDATA[$Organisation]]></Organization>")
            $Writer.WriteLine("<CompanyId>$CompanyID</CompanyId>")
            $Writer.WriteLine("<Address><![CDATA[$($Address -join ', ')]]></Address>")
            $Writer.WriteLine("</Manufacturer>")
          }
          $OUI = $null; $Organisation = $null; $CompanyID = $null; $Address = $null
        }
      }
    }
    
  $Writer.WriteLine("</Manufacturers>")
  $Writer.Close()
}