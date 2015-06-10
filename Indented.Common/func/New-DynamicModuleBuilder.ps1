function New-DynamicModuleBuilder {
  # .SYNOPSIS
  #   Creates a new assembly and a dynamic module within the current AppDomain.
  # .DESCRIPTION
  #   Prepares a System.Reflection.Emit.ModuleBuilder class to allow construction of dynamic types. The ModuleBuilder is created to allow the creation of multiple types under a single assembly.
  # .PARAMETER AssemblyName
  #   A name for the in-memory assembly.
  # .PARAMETER UseGlobalVariable
  #   By default, this function stores the requested ModuleBuilder in a global variable called Indented_ModuleBuilder. This leaves the ModuleBuilder object accessible to New-Enum without needing an explicit assignment operation.
  # .INPUTS
  #   System.Reflection.AssemblyName
  # .OUTPUTS
  #   System.Reflection.Emit.ModuleBuilder
  # .EXAMPLE
  #   New-DynamicModuleBuilder "Example.Assembly"
  # .LINK
  #   http://www.indented.co.uk/indented-common/
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     17/08/2013 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Reflection.AssemblyName]$AssemblyName,
    
    [Boolean]$UseGlobalVariable = $true,
    
    [Switch]$PassThru
  )
  
  $AppDomain = [AppDomain]::CurrentDomain

  # Multiple assemblies of the same name can exist. This check aborts if the assembly name exists on the assumption
  # that this is undesirable.
  $AssemblyRegEx = "^$($AssemblyName.Name -replace '\.', '\.'),"
  if ($AppDomain.GetAssemblies() |
    Where-Object { 
      $_.IsDynamic -and $_.Fullname -match $AssemblyRegEx }) {

    Write-Error "New-DynamicModuleBuilder: Dynamic assembly $($AssemblyName.Name) already exists."
    return
  }
  
  # Create a dynamic assembly in the current AppDomain
  $AssemblyBuilder = $AppDomain.DefineDynamicAssembly(
    $AssemblyName, 
    [Reflection.Emit.AssemblyBuilderAccess]::Run
  )

  $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule($AssemblyName.Name)
  if ($UseGlobalVariable) {
    # Create a transient dynamic module within the new assembly
    New-Variable Indented_ModuleBuilder -Scope Global -Value $ModuleBuilder
    if ($PassThru) {
      $ModuleBuilder
    }
  } else {
    return $ModuleBuilder
  }
}