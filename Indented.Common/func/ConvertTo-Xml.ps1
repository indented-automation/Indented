function ConvertTo-Xml {
  # .SYNOPSIS
  #   Convert an object to a simple XML structure.
  # .DESCRIPTION
  #   Convert an existing object to a simple XML format.
  #
  #   The input object is treated as being flat. All properties are treated as strings.
  # .PARAMETER ChildNodeName
  #   The name given to the wrapper for each child node. The child node will contain each property from the object.
  # .PARAMETER IncludeTypeNames
  #   By default ConvertTo-XML creates an attribute on each property element containing the .NET type. This behaviour may be suppressed by setting IncludeTypeNames to false.
  # .PARAMETER Object
  #   The object to convert.
  # .PARAMETER RootNodeName
  #   The name of the root node (which contains all other nodes).
  # .INPUTS
  #   System.Object[]
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Get-Process | Select-Object ProcessName, StartTime, ID | ConvertTo-Xml | Out-File processes.xml
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     27/10/2014 - Chris Dent - Suppressed ASCII characters 0x00 to 0x1F in XML strings.
  #     24/10/2014 - Chris Dent - Modified DateTime to always write as a string.
  #     21/10/2014 - Chris Dent - Added Array support.
  #     04/08/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipeline = $true)]
    [Object]$Object,
    
    [String]$RootNodeName = "Objects",
    
    [String]$ChildNodeName = "Object",
    
    [Boolean]$IncludeTypeNames = $true
  )
  
  begin {
    $StringBuilder = New-Object Text.StringBuilder
  
    $XmlWriterSettings = New-Object Xml.XmlWriterSettings
    $XmlWriterSettings.Indent = $true
    
    $XmlWriter = [Xml.XmlWriter]::Create($StringBuilder, $XmlWriterSettings)
    $XmlWriter.WriteStartElement($RootNodeName)
  }
  
  process {
    $XmlWriter.WriteStartElement($ChildNodeName)
    
    $Object.PSObject.Properties | Where-Object { $_.MemberType -like '*Property' } | ForEach-Object {
      $XmlWriter.WriteStartElement($_.Name)
      if ($IncludeTypeNames) {
        if ($_.Value) {
          $Type = $_.Value.GetType().FullName
        } else {
          $Type = "System.Object"
        }
        $XmlWriter.WriteAttributeString("Type", $Type)
      }
      if ($_.Value -is [Array]) {
        $_.Value | ForEach-Object {
          $XmlWriter.WriteStartElement("ArrayItem")
          if ($_ -is [DateTime]) {
            $XmlWriter.WriteString($_.ToString("u"))
          } else {
            $XmlWriter.WriteString(($_ -replace '[\x00-\x1F]', ' '))
          }
          $XmlWriter.WriteEndElement()
        }
      } else {
        if ($_.Value -is [DateTime]) {
          $XmlWriter.WriteString($_.Value.ToString("u"))
        } else {
          $XmlWriter.WriteString(($_.Value -replace '[\x00-\x1F]', ' '))
        }
      }
      $XmlWriter.WriteEndElement()
    }
    
    $XmlWriter.WriteEndElement()
  }
  
  end {
    $XmlWriter.WriteEndElement()
    $XmlWriter.Flush()
    
    $StringBuilder.ToString()
  }
}