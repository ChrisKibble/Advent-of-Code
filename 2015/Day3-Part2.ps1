$dataIn = Get-Content $PSScriptRoot\Day3-Input.txt

$board = New-Object 'Int[,]' 500,500

$santaPos1 = 0
$santaPos2 = 0

$roboPos1 = 0
$roboPos2 = 0

$board[$santapos1, $santapos2]++
$board[$robopos1, $robopos2]++

For($i = 0; $i -lt $dataIn.Length; $i++) {
    
    $data = $dataIn[$i]

    If($i % 2 -eq 0) {
        Switch($data) {
            "^" { $santaPos1++ }
            "v" { $santaPos1-- }
            "<" { $santaPos2-- }
            ">" { $santaPos2++ }   
        }
        $board[$santaPos1, $santaPos2]++
    } else {
        Switch($data) {
            "^" { $roboPos1++ }
            "v" { $roboPos1-- }
            "<" { $roboPos2-- }
            ">" { $roboPos2++ }   
        }
        $board[$roboPos1, $roboPos2]++
    }

}

Write-Host "Houses with Gifts: $($board.Where{$_ -ne 0}.count)"