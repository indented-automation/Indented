function Update-PropertyOrder {
  # .SYNOPSIS
  #   Update the order of properties on an object.
  # .DESCRIPTION
  #   Update-PropertyOrder attempts to re-order the properties on an object into alphabetical order.
  #
  #   This function strips methods from the object. Type names are copied.
  # .PARAMETER Object
  #   The object to re-order.
  # .INPUTS
  #   System.Object
  # .OUTPUTS
  #   System.Management.Automation.PSObject
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #    04/12/2014 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipeline = $true)]
    $Object
  )
  
  process {
    $OrderedObject = New-Object PSObject
    $Object | Get-Member -MemberType *Property* | Sort-Object Name | ForEach-Object {
      $Member = $_
      switch ($_.MemberType) {
        'AliasProperty'  { $OrderedObject | Add-Member $Member.Name -MemberType AliasProperty -Value $Object.PSObject.Properties[$Member.Name].ReferencedMemberName; break }
        'ScriptProperty' { $OrderedObject | Add-Member $Member.Name -MemberType ScriptProperty -Value $Object.PSObject.Properties[$Member.Name].GetterScript; break }
        default          { $OrderedObject | Add-Member $Member.Name -MemberType NoteProperty -Value $Object.$($Member.Name) }
      }
    }
    $Object.PSObject.TypeNames | Where-Object { $_ -notin $OrderedObject.PSObject.TypeNames } | ForEach-Object {
      $OrderedObject.PSObject.TypeNames.Add($_)
    }
    $OrderedObject
  }
}