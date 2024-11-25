

$grid = [Int64[][]]::new(1000,1000)

$rxInstruction = [RegEx]::New("(?i)(.*?) (\d{1,}),(\d{1,}) through (\d{1,}),(\d{1,})")

Write-Host "Reading Instructions"
$instructions = Get-Content $PSScriptRoot\Day6-Input.txt

$lightsOn = 0
$Instructions | ForEach-Object {
    
    $WhatToDo = $rxInstruction.Match($_)
    
    $inst = $WhatToDo.Groups[1].Value
    $x1 = [int]$WhatToDo.Groups[2].Value
    $y1 = [int]$WhatToDo.Groups[3].Value
    $x2 = [int]$WhatToDo.Groups[4].Value
    $y2 = [int]$WhatToDo.Groups[5].Value

    Write-Host "$inst $x1-$x2, $y1-$y2"

    For($x = $x1; $x -le $x2; $x++) {
        For($y = $y1; $y -le $y2; $y++) {
            
            $lightIsOn = $grid[$x][$y] -gt 0

            Switch ($inst) {
                "turn on" {
                    $grid[$x][$y]++
                    $lightsOn++
                    break
                }
                "turn off" {
                    If($lightIsOn) {
                        $grid[$x][$y]--
                        $lightsOn--
                    }
                    break
                }
                "toggle" {
                    $grid[$x][$y] = $grid[$x][$y] + 2
                    $lightsOn = $lightsOn + 2
                    break
                }
            }
        
        }
    }

}

Write-Host $lightsOn
