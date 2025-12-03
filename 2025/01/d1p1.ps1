[CmdLetBinding()]Param()

# $instructions = Get-Content $PSScriptRoot\sample.txt
$instructions = Get-Content $PSScriptRoot\input.txt

$dialPosition = 50
$zeroCount = 0

Write-Verbose " - The dial starts by pointing at $dialPosition"
ForEach($move in $instructions) {
    
    $direction = $move.substring(0,1)
    $notDirection = $move.substring(1)
    
    if($notDirection.Length -gt 2) {
        [Int]$change = $notDirection.Substring($notDirection.Length-2) # Only grab the last two characters because we don't care how many 1000s or 100s it rolls because it'd end up in the same spot.
    } Else {
        [Int]$change = $notDirection
    }
    
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