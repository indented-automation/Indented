function Compare-Array {
  # .SYNOPSIS
  #   Compares two arrays to determine equality.
  # .DESCRIPTION
  #   This function presents two methods of comparing arrays.
  #
  #     1. A manual loop comparison method, exiting at the first opportunity. 
  #     2. A wrapper around the .NET 4 IStructuralEquatable interface.
  #
  #   Arrays must be exactly equal for the function to return true. That is, arrays must meet the following criteria:
  #
  #     * Must use simple values (primitive types).
  #     * Must be of equal length.
  #     * Must be ordered in the same way unless using the Sort parameter.
  #     * When comparing strings, case is important.
  #     * .NET Type must be equal (UInt32 is not the same as Int32).
  #
  # .PARAMETER Object
  #   The object array to test against.
  # .PARAMETER Sort
  #   For an array to be considered equal it must also be ordered in the same way. Comparison of unordered arrays can be forced by setting this parameter.
  # .PARAMETER Subject
  #   The object array to test.
  # .INPUTS
  #   System.Array
  #   System.Object[]
  # .OUTPUTS
  #   System.Boolean
  # .EXAMPLE
  #   C:\PS>Compare-Array -Subject 1, 2, 3 -Object 1, 2, 3
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS>$a = [Byte[]](1, 2, 3)
  #   C:\PS>$b = [Byte[]](3, 2, 1)
  #   C:\PS>Compare-Array -Subject $a -Object $b
  #
  #   Returns false, elements are not ordered in the same way and types are equal.
  # .EXAMPLE
  #   C:\PS>$a = [Byte[]](1, 2, 3)
  #   C:\PS>$a = [UInt32[]](1, 2, 3)
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns false, element Types are not equal.
  # .EXAMPLE
  #   C:\PS>$a = "one", "two"
  #   C:\PS>$b = "one", "two"
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS>$a = "ONE", "TWO"
  #   C:\PS>$b = "one", "two"
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns false.
  # .EXAMPLE
  #   C:\PS>$a = 1..10000
  #   C:\PS>$b = 1..10000
  #   C:\PS>Compare-Array $a $b -ManualLoop
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS> Compare-Array @("1.2.3.4", "2.3.4.5") @("2.3.4.5", "1.2.3.4") -Sort
  #
  #   Returns true.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     02/04/2014 - Chris Dent - Created.
  
  param(
    [Parameter(Mandatory = $true)]
    [Object[]]$Subject,

    [Parameter(Mandatory = $true)]
    [Object[]]$Object,
    
    [Switch]$ManualLoop,
    
    [Switch]$Sort
  )

  if ($ManualLoop) {
    # If the arrays are not the same length they cannot be equal.
    if ($Subject.Length -ne $Object.Length) {
      return $false
    }
    
    # If Sort is set and the arrays are of equal length ensure both arrays are similarly ordered.
    if ($Sort) {
      $Subject = $Subject | Sort-Object
      $Object = $Object | Sort-Object
    }
    
    $Length = $Subject.Length
    $Equal = $true
    for ($i = 0; $i -lt $Length; $i++) {
      # Exit when the first match fails.
      if ($Subject[$i] -ne $Object[$i]) {
        return $false
      }
    }
    return $true
  } else {
    # If Sort is set and the arrays are of equal length ensure both arrays are similarly ordered.
    if ($Sort) {
      $Subject = $Subject | Sort-Object
      $Object = $Object | Sort-Object
    }

    ([Collections.IStructuralEquatable]$Subject).Equals(
      $Object,
      [Collections.StructuralComparisons]::StructuralEqualityComparer
    )
  }
}