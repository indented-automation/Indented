function ConvertTo-Type {
  # .SYNOPSIS
  #   Convert a value to a named type.
  # .DESCRIPTION
  #   Attempt to convert a value to a named type. If the type name cannot be resolved to a type the original value is returned unmodified.
  # .PARAMETER Value
  #   The value to convert.
  # .PARAMETER
  #   The type to convert to.
  # .INPUTS
  #   System.Object
  #   System.String
  # .OUTPUTS
  #   System.Object
  # .EXAMPLE
  #   ConvertTo-Type "01/01/2014" -Type DateTime
  #
  #   Explicit conversion of a datetime string to a DateTime type.
  # .EXAMPLE
  #   ConvertTo-Type "1" -Type UInt32
  #
  #   Explicit conversion of a string to an unsigned 32-bit integer.
  # .EXAMPLE
  #   ConvertTo-Type true
  #
  #   Implicit conversion of the string true to a Boolean.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     19/11/2014 - Chris Dent - BugFix: ErrorAction SilentlyContinue does not work for Invoke-Expression.
  #     10/11/2014 - Chris Dent - Added type casting.
  #     22/10/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Object]$Value,
    
    [String]$Type
  )

  if ($Type -as [Type] -eq [DateTime]) {
    try { return (Get-Date $Value) } catch { }
    if (-not $?) {
      try { return [Convert]::ChangeType($Value, [DateTime]) } catch { }
    }
  } elseif ($Type -as [Type] -eq [Net.IPEndPoint]) {
    try { return (New-Object Net.IPEndPoint([IPAddress]($Value -replace ':.+$'), ($Value -replace '^.+:'))) } catch { }
  } elseif ($Type -as [Type]) {
    try { return [Convert]::ChangeType($Value, ($Type -as [Type])) } catch { }
    if (-not $?) {
      try { return (Invoke-Expression "[$(($Type -as [Type]).FullName)]'$Value'") } catch { }
    }
  } elseif ($Value -match '^(true|false)$') {
    return [Convert]::ToBoolean($Value)
  }
  return $Value
}