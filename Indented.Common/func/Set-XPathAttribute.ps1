function Set-XPathAttribute {
  # .SYNOPSIS
  #   Set an attribute using the XPathNavigator object.
  # .DESCRIPTION
  #   Set-XPathAttribute expects an XML node iterator, the name of an attribute and the new value.
  #
  #   The XML node holding the attribute must be selected before requesting a change using Set-XPathAttribute.
  # .PARAMETER AttributeName
  #   The name of the attribute to set.
  # .PARAMETER Value
  #   The value to set.
  # .PARAMETER XmlNode
  #   An XmlNode selected using an XPathNavigator which may be created using New-XPathNavigator.
  # .INPUTS
  #   System.String
  #   System.Xml.XPath.XPathNavigator
  # .EXAMPLE
  #   $XPathNavigator = New-XPathNavigator file.xml
  #   $XmlNode = $XPathNavigator.Select("/SomeRoot/SomeElement")
  #   Set-XPathAttribute -AttributeName "Test" -Value "NewValue" -XmlNode $XmlNode
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     09/12/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('Name')]
    [String]$AttributeName,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Value,

    [Parameter(ValueFromPipeline = $true)]
    [ValidateScript( { $_.PSObject.TypeNames -contains 'MS.Internal.Xml.Cache.XPathDocumentNavigator' -or $_.PSObject.TypeNames -contains 'System.Xml.DocumentXPathNavigator' } )]
    $XmlNode
  )
  
  process {
    $XPathNavigator = $XmlNode.CreateNavigator()

    if ($XPathNavigator.GetAttribute($AttributeName, "") -ne $Value) {
      if ($XPathNavigator.MoveToAttribute($AttributeName, "")) {
        $XPathNavigator.SetValue($Value)
        $XPathNavigator.MoveToParent() | Out-Null
      } else {
        $XPathNavigator.CreateAttribute("", $AttributeName, "", $Value)
      }
    }
  }
}