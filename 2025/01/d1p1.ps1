[CmdLetBinding()]Param()

# $instructions = Get-Content $PSScriptRoot\sample.txt
$instructions = Get-Content $PSScriptRoot\input.txt

$dialPosition = 50
$zeroCount = 0

Write-Verbose " - The dial starts by pointing at $dialPosition"
ForEach($move in $instructions) {
    
    $direction = $move.substring(0,1)
    $notDirection = $move.substring(1)

    [Int]$change = $notDirection % 100
    
    If($direction -eq "L") { $Change = $Change * -1 }
    $dialPosition += $Change

    If($dialPosition -lt 0) {
        $dialPosition = 100 + $dialPosition
    } ElseIf($dialPosition -gt 99) {
        $dialPosition = $dialPosition - 100
    }
    
    If($dialPosition -eq 0) {
        $zeroCount ++
    }

    Write-Verbose "- The dial is rotated $move to point at $dialPosition"
}

Write-Output "The dial hit position zero $zeroCount times."