function Get-CommandParameters {
  # .SYNOPSIS
  #   Get the parameters used by a command, excluding common parameters.
  # .DESCRIPTION
  #   Get-CommandParameters is used to retrieve the list of CmdLet-specific parameters to simplify parameter passing operations.
  # .PARAMETER Name
  #   The name of the CmdLet or Function.
  # .PARAMETER ParameterNamesOnly
  #   Return parameter names as an array of strings instead of parameter metadata.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Management.Automation.ParameterMetadata[]
  # .EXAMPLE
  #   Get-CommandParameters Get-DSObject
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     23/07/2014 - Chris Dent - Added ShouldProcess parameters.
  #     24/06/2014 - Chris Dent - Created.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Get-Command $_ } )]
    [String]$Name,
    
    [Switch]$ParameterNamesOnly
  )

  $CommonParameters = ([Management.Automation.Internal.CommonParameters]).GetProperties() | Select-Object -ExpandProperty Name
  $ShouldProcessParameters = ([Management.Automation.Internal.ShouldProcessParameters]).GetProperties() | Select-Object -ExpandProperty Name
  
  $ParameterHashtable = (Get-Command $Name).Parameters
  $Parameters = $ParameterHashtable.Keys |
    Where-Object { $_ -notin $CommonParameters -and $_ -notin $ShouldProcessParameters } |
    ForEach-Object {
      $ParameterHashtable[$_]
    }
  
  if ($ParameterNamesOnly) {
    return $Parameters | Select-Object -ExpandProperty Name
  } else {
    return $Parameters
  }
}
