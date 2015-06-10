function New-XPathNavigator {
  # .SYNOPSIS
  #   Create a new XPathNavigator.
  # .DESCRIPTION
  #   Create a new XPathNavigator. The XML file may be opened as read-only or write.
  # .PARAMETER FileName
  #   The XML file to open.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Xml.XPath.XPathNavigator
  # .EXAMPLE
  #   New-XPathNavigator C:\Test.xml
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     04/07/2014 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias('FullName')]
    [String]$FileName,
    
    [ValidateSet('ReadOnly', 'Write')]
    [String]$Mode = "ReadOnly"
  )

  process {
    if ($FileName -and (Test-Path $FileName)) {
      $FileName = (Get-Item $FileName).FullName

      if ($Mode -eq "ReadOnly") {
        # Open as ReadOnly
        $XmlDocument = New-Object Xml.XPath.XPathDocument($FileName)
      } else {
        $XmlDocument = New-Object Xml.XmlDocument
        $XmlDocument.Load($FileName)
      }
    } else {
      $XmlDocument = New-Object Xml.XmlDocument
    }
    
    return $XmlDocument.CreateNavigator()
  }
}