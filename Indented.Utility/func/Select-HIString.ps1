function Select-HIString {
  # .SYNOPSIS
  #   Select a matching string from an alphabetically sorted file.
  # .DESCRIPTION
  #   Select-HIString is a specialised binary (Half Interval) searcher designed to find matches in sorted ASCII encoded text files.
  # .PARAMETER FileName
  #   The name of the file to search.
  # .PARAMETER String
  #   The string to find. The string is treated as a regular expression and must match the beginning of the line.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Select-HIString -String abc -FileName File.txt
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/08/2014 - Chris Dent - First release.

  param(
    [Parameter(Mandatory = $true)]
    [String]$String,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ } )]
    [String]$FileName
  )
  
  $FileName = (Get-Item $FileName).FullName
  $FileStream = New-Object IO.FileStream($FileName, [IO.FileMode]::Open)
  $BinaryReader = New-Object IO.BinaryReader($FileStream)
  
  $Length = $BinaryReader.BaseStream.Length
  $Position = $Length / 2

  [Int64]$HalfInterval = $Length / 2
  $Position = $Length - $HalfInterval

  while ($Position -gt 1 -and $Position -lt $Length -and $Position -ne $LastPosition) {
    $LastPosition = $Position
    $HalfInterval = $HalfInterval / 2

    $BinaryReader.BaseStream.Seek($Position, [IO.SeekOrigin]::Begin) | Out-Null
    
    # Track back to the start of the line
    while ($true) {
      $Character = $BinaryReader.ReadByte()
      if ($BinaryReader.BaseStream.Position -eq 1) {
        $BinaryReader.BaseStream.Seek(-1, [IO.SeekOrigin]::Current) | Out-Null
        break
      } elseif ($Character -eq [Byte][Char]"`n") {
        break
      } else {
        $BinaryReader.BaseStream.Seek(-2, [IO.SeekOrigin]::Current) | Out-Null
      }
    }
    
    # Read the line
    $Characters = @()
    if ($BinaryReader.BaseStream.Position -lt $BinaryReader.BaseStream.Length) {
      do {
        $Characters += [Char][Int]$BinaryReader.ReadByte()
      } until ($Characters[-1] -eq [Char]"`n" -or $BinaryReader.BaseStream.Position -eq $BinaryReader.BaseStream.Length)
      $Line = (New-Object String (,[Char[]]$Characters)).Trim()
    } else {
      # End of file
      $FileStream.Close()
      return $null
    }

    if ($Line -match "^$String") {
      # Close the file stream and return the match immediately
      $FileStream.Close()
      return $Line
    } elseif ($Line -lt $String) {
      $Position = $Position + $HalfInterval
    } elseif ($Line -gt $String) {
      $Position = $Position - $HalfInterval
    }
  }
  
  # Close the file stream if no matches are found.
  $FileStream.Close()
}