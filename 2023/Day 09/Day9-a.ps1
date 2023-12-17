

Function Get-PuzzleInput {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String[]]$PuzzleInput
    )

    [Int]$paddedValues = 0

    ForEach($PuzzleLine in $PuzzleInput) {
        Write-Verbose "Processing $PuzzleLine"
        [System.Collections.Generic.List[Int]]$PuzzleNumbers = $PuzzleLine -split '\s'
        [System.Collections.Generic.List[Object]]$PuzzleOutput = $PuzzleNumbers
        While(($PuzzleNumbers | Where-Object { $_ -ne 0}).Count -gt 0) {
            $PuzzleNumbers = Get-NextSet $PuzzleNumbers
            Write-Verbose "  Returned Numbers are $($PuzzleNumbers -join ',')"
            $PuzzleOutput.Add($PuzzleNumbers) | Out-Null
        }
        
        # Add Final Line Padding
        Write-Verbose "Padding Final Line"
        $PuzzleOutput[-1].Add(0) | Out-Null
        Write-Verbose "Final Line is now $($puzzleOutput[-1] -join ',')"

        Write-Verbose "Puzzle Line Processed"
        For($index = $PuzzleOutput.Count-2; $index -ge 0; $index--) {
            Write-Verbose "  Need to add padding to index $index ($($PuzzleOutput[$index] -join ','))"
            $belowNumber = $puzzleOutput[$index+1][-1]
            $leftNumber = $puzzleOutput[$index][-1]
            [Int]$padNumber = $belowNumber + $leftNumber
            Write-Verbose "    Adding $belowNumber and $leftNumber = $padNumber"
            $puzzleOutput[$index].Add($padNumber) | Out-Null
            Write-Verbose "    New Output for index $index is ($($PuzzleOutput[$index] -join ','))"
        }

        $paddedValues += $PuzzleOutput[0][-1]

    }

    Return $paddedValues
   
}

Function Get-NextSet {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]    
        [Int[]]$NumberSet
    )

    Write-Verbose "  Numbers are $($NumberSet -join ',')"
    [Int[]]$NewSet = For($index = 1; $index -lt $NumberSet.Count; $index++) {
        $NumberSet[$index] - $NumberSet[$index-1]
    }

    $NewSet

}
$x = Get-Content $PSScriptRoot\Input.txt
$PuzzleOutput = Get-PuzzleInput $x -Verbose

Write-Host ">> $PuzzleOutput <<"