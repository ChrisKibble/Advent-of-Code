[CmdLetBinding()]Param()

$inputFile = "$PSScriptRoot\sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$Instructions = Get-Content $inputFile

[System.Collections.Generic.SortedSet[Int]]$StartIndexes = $Instructions[0].IndexOf('S')
[Int]$SplitterHits = 0

For($Row = 1; $row -lt $instructions.Count; $row++) {
    Write-Verbose "Entering Row $Row. Beams to Enter Column(s) $($StartIndexes -join ', '). I've hit $SplitterHits splitters so far."
    
    # We don't want to try and do these while we're processing this row
    # because we don't want them used until the next row starts.

    [System.Collections.Generic.SortedSet[Int]]$NewStartIndexes = @()
    [System.Collections.Generic.SortedSet[Int]]$RetiredStartIndexes = @()   

    ForEach($Beam in $StartIndexes) {
        Write-Verbose "Looking at column $Beam. "
        If($Instructions[$Row][$Beam] -eq ".") {
            Write-Verbose "Nothing here. Beam Continues."
        } ElseIf($Instructions[$Row][$Beam] -eq "^") {
            Write-Verbose "I've hit a splitter!"
            $SplitterHits++

            # Remove this column from continuing
            $RetiredStartIndexes.Add($Beam) | Out-Null
            $NewStartIndexes.Add($Beam-1) | Out-Null
            $NewStartIndexes.Add($Beam+1) | Out-Null 
        }
    }

    Write-Verbose "New Beams to Add: $($NewStartIndexes -join ', ')"
    Write-Verbose "Indexes to Retire: $($RetiredStartIndexes -join ', ')"
    
    ForEach($i in $NewStartIndexes) { $StartIndexes.Add($i) | Out-Null }
    ForEach($i in $RetiredStartIndexes) { $StartIndexes.Remove($i) | Out-Null }

}

$SplitterHits
