function ConvertFrom-XPathNode {
  # .SYNOPSIS
  #   Convert from an XPathDocumentNavigator node-set to the specified type.
  # .DESCRIPTION
  #   ConvertFrom-XPathNode simplifies reading XML documents using the XPathNavigator. The node-set in the input pipeline is converted to the requested type.
  # .PARAMETER MergeHashtable
  #   An existing Hashtable may be appended to the beginning of the new hashtable.
  # .PARAMETER ToArray
  #   Convert a list of values to an array.
  # .PARAMETER ToHashtable
  #   Convert a set of values to a Hashtable. The first element in the input pipeline is treated as the key.
  # .PARAMETER ToObject
  #   Attempt to convert the XML node to an PSObject.
  # .PARAMETER ToString
  #   A single node is expected, the value is returned as a string. If the value is true or false the respective boolean value is returned instead.
  # .PARAMETER UseAttribute
  #   Use the named attribute as the key for a hashtable.
  # .PARAMETER UseTypeAttribute
  #   Look for a Type attribute on the XML node and attempt to convert the value to the specified type.
  # .PARAMETER XmlNode
  #   A XPathNodeIterator node-set selected from an XPathNavigator object.
  # .INPUTS
  #   System.Hashtable
  #   System.Xml.XPath.XPathNodeIterator
  # .OUTPUTS
  #   System.Array
  #   System.Boolean
  #   System.Collections.Specialized.OrderedDictionary
  #   System.String
  # .EXAMPLE
  #   $XPathNavigator.Select("/Node") | ConvertFrom-XPathNode -ToString
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     24/10/2014 - Chris Dent - Added support for arrays (as nested ArrayItem).
  #     22/10/2014 - Chris Dent - Added type converter.
  #     04/07/2014 - Chris Dent - Added ToObject.
  #     02/07/2014 - Chris Dent - Added boolean type conversion to the Hashtable reader.
  #     01/07/2014 - Chris Dent - Created.

  [CmdLetBinding(DefaultParameterSetName = 'ToString')]
  param(
    [Parameter(ValueFromPipeline = $true)]
    [ValidateScript( { $_.PSObject.TypeNames -contains 'MS.Internal.Xml.Cache.XPathDocumentNavigator' -or $_.PSObject.TypeNames -contains 'System.Xml.DocumentXPathNavigator' } )]
    $XmlNode,
  
    [Parameter(ParameterSetName = 'ToArray')]
    [Switch]$ToArray,

    [Parameter(ParameterSetName = 'ToHashtable')]
    [Switch]$ToHashtable,

    [Parameter(ParameterSetName = 'ToHashtable')]
    [Collections.Specialized.OrderedDictionary]$MergeHashtable,
    
    [Parameter(ParameterSetName = 'ToHashtable')]
    [String]$UseAttribute,
    
    [Parameter(ParameterSetName = 'ToObject')]
    [Switch]$ToObject,
    
    [Parameter(ParameterSetName = 'ToString')]
    [Switch]$ToString,
    
    [Switch]$UseTypeAttribute
  )

  begin {
    switch ($pscmdlet.ParameterSetName) {
      'ToArray'     { $Array = @() }
      'ToHashtable' {
        $Hashtable = [Ordered]@{}
        if ($MergeHashtable) {
          $MergeHashtable.Keys | ForEach-Object {
            $Hashtable.Add($_, $MergeHashtable[$_])
          }
        }
      }
    }
  }
  
  process {
    switch ($pscmdlet.ParameterSetName) {
      'ToArray' { 
        $Array += $XmlNode.Select('./*') | ForEach-Object {
          if ($UseTypeAttribute) {
            $Type = $_.GetAttribute("Type", "")
            ConvertTo-Type $_.Value $Type
          } else {
            ConvertTo-Type $_.Value $Type
          }
        }
      }
      'ToHashtable' {
        $Key = $null; $Values = @()
        $XmlNode.Select('./*') | ForEach-Object {
          if ($psboundparameters.ContainsKey("UseAttribute")) {
            $Key = $_.GetAttribute($UseAttribute, $null)
          }
          if (-not $Key) {
            $Key = $_.Value
          } else {
            $Values += $_
          }
        }
        if ($Values.Count -eq 1) {
          if ($UseTypeAttribute) {
            $Type = $Values.GetAttribute("Type", "")
            $Value = ConvertTo-Type $Values.Value $Type
          } else {
            $Value = ConvertTo-Type $Values.Value
          }
          $Hashtable.Add($Key, $Value)
        } else {
          if ($UseTypeAttribute) {
            $Value = $XmlNode | ConvertFrom-XPathNode -ToObject -UseTypeAttribute
          } else {
            $Value = $XmlNode | ConvertFrom-XPathNode -ToObject
          }
          $Hashtable.Add($Key, $Value)
        }
      }
      'ToObject' {
        $Object = New-Object PSObject
        $XmlNode.Select("./*") | ForEach-Object {
          $Value = $_.Value.Trim()
          if ($UseTypeAttribute) {
            $Type = $_.GetAttribute("Type", "")
            if ($Type -match '\[\]$') {
              $Value = $_.Select("./*") | ForEach-Object {
                ConvertTo-Type $_.Value ($Type -replace '\[\]$')
              }
            } else {
              $Value = ConvertTo-Type $Value $Type
            }
          } else {
            $Value = ConvertTo-Type $Value
          }
          Add-Member $_.Name -MemberType NoteProperty -Value $Value -InputObject $Object
        }
        return $Object
      }
      'ToString' {
        return (ConvertTo-Type $XmlNode.Value.Trim())
      }
    }
  }

  end {
    switch ($pscmdlet.ParameterSetName) {
      'ToArray'     { return $Array }
      'ToHashtable' { return $Hashtable }
    }
  } 
}