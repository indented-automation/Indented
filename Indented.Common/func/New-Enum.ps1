function New-Enum {
  # .SYNOPSIS
  #   Creates a new enum (System.Enum) from a hashtable using an existing dynamic module.
  # .DESCRIPTION
  #   New-Enum dynamically creates an enum with the specified name (and namespace).
  #
  #   A hashtable is used to populate the enum. All values passed in via the hashtable must be able to convert to the enum type.
  # 
  #   The enum is created, but not returned by this function.
  # .PARAMETER Members
  #   A hashtable describing the members of the enum.
  # .PARAMETER ModuleBuilder
  #   A dynamic module within a dynamic assembly, created by New-DynamicModuleBuilder. By default, the function uses the global variable Indented_ModuleBuilder, populated if New-DynamicModuleBuilder is executed with UseGlobalVariable set to true (the default value).
  # .PARAMETER Name
  #   A name for the enum, a namespace may be included.
  # .PARAMETER SetFlagsAttribute
  #   Optionally sets the System.FlagsAttribute on the enum, indicating the enum can be treated as a bit field. Note that the enum members must support this attribute.
  # .PARAMETER Type
  #   A .NET value type, by default Int32 is used. The type name is passed as a string and converted to a Type by the function.
  # .INPUTS
  #   System.Reflection.Emit.ModuleBuilder
  #   System.String
  #   System.HashTable
  #   System.Type
  # .EXAMPLE
  #   C:\PS>New-DynamicModuleBuilder "Example"
  #   C:\PS>$EnumMembers = @{cat=1;dog=2;tortoise=4;rabbit=8}
  #   C:\PS>New-Enum -Name "Example.Pets" -SetFlagsAttribute -Members $EnumMembers
  #   C:\PS>[Example.Pets]10
  #
  #   Creates a new enumeration in memory, then returns values "dog" and "rabbit".
  # .EXAMPLE
  #   C:\PS>$Builder = New-DynamicModuleBuilder "Example" -UseGlobalVariable $false
  #   C:\PS>New-Enum -ModuleBuilder $Builder -Name "Example.Byte" `
  #   >> -Type "Byte" -Members @{one=1;two=2}
  #   >>
  #   C:\PS>[Example.Byte]2
  #
  #   Uses a user-defined variable to store the created dynamic module. The example returns the value "two".
  # .EXAMPLE
  #   C:\PS>New-DynamicModuleBuilder "Example"
  #   C:\PS>New-Enum -Name "Example.NumbersLow" -Members @{One=1; Two=2}
  #   C:\PS>New-Enum -Name "Example.NumbersHigh" -Members @{OneHundred=100; TwoHundred=200}
  #   C:\PS>[UInt32][Example.NumbersLow]::One + [UInt32][Example.NumbersHigh]::OneHundred
  #
  #   Multiple Enumerations can be built within the same dynamic assembly, a module builder only needs to be created once.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     17/08/2013 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Reflection.Emit.ModuleBuilder]$ModuleBuilder = $Indented_ModuleBuilder,
    
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidatePattern('^(\w+\.)*\w+$')]
    [String]$Name,

    [Type]$Type = "Int32",

    [Alias('Flags')]
    [Switch]$SetFlagsAttribute,

    [Parameter(Mandatory = $true)]
    [HashTable]$Members
  )
 
  # This function cannot overwrite or append to existing types. 
  # Abort if a type of the same name is found and return a more friendly error than ValidateScript would.
  if ($Name -as [Type]) {
    Write-Error "New-Enum: Type $Name already exists"
    return
  }
 
  # Begin defining a public System.Enum
  $EnumBuilder = $ModuleBuilder.DefineEnum(
    $Name,
    [Reflection.TypeAttributes]::Public,
    $Type)
  if ($?) {
    if ($SetFlagsAttribute) {
      $EnumBuilder.SetCustomAttribute(
        [FlagsAttribute].GetConstructor([Type]::EmptyTypes),
        @()
      )
    }
    $Members.Keys | ForEach-Object {
      $null = $EnumBuilder.DefineLiteral($_, [Convert]::ChangeType($Members[$_], $Type))
    }
    $Enum = $EnumBuilder.CreateType()
  }
}