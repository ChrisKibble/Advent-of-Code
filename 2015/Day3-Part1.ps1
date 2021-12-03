$dataIn = Get-Content $PSScriptRoot\Day3-Input.txt

$board = New-Object 'Int[,]' 500,500

$pos1 = 0
$pos2 = 0

$board[$pos1, $pos2]++

ForEach($data in $dataIn.ToCharArray()) {
    
    Switch($data) {
        "^" { $pos1++ }
        "v" { $pos1-- }
        "<" { $pos2-- }
        ">" { $pos2++ }   
    }
    
    $board[$pos1, $pos2]++
}

$board.where{$_ -ne 0}.count
