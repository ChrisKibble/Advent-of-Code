Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
turn on 0,0 through 10,10
toggle 5,5 through 15,15
turn off 13,13 through 14,14
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day6-Input.txt

$lightsOn = New-Object System.Collections.ArrayList

$Instruction = [RegEx]::New("(?i)(.*?) (\d{1,}),(\d{1,}) through (\d{1,}),(\d{1,})")

$dataIn.ForEach{

    $WhatToDo = $Instruction.Match($_)

    $inst = $WhatToDo.Groups[1]
    $x1 = [int]$WhatToDo.Groups[2].Value
    $y1 = [int]$WhatToDo.Groups[3].Value
    $x2 = [int]$WhatToDo.Groups[4].Value
    $y2 = [int]$WhatToDo.Groups[5].Value

    Write-Host $_

    For($x = $x1; $x -le $x2; $x++) {
        For($y = $y1; $y -le $y2; $y++) {

            $coord = "$x,$y"
            
            $coordIndex = $lightsOn.IndexOf($coord)
            $on = $coordIndex -ge 0
            
            Switch($inst.Value) {

                "turn on" {
                    If(-Not($on)) {
                        [Void]$lightsOn.Add($coord)
                    }
                }

                "turn off" {
                    if($on) {
                        [Void]$lightsOn.RemoveAt($coordIndex)
                    }
                }

                "toggle" {
                    If($on) {
                        [Void]$lightsOn.RemoveAt($coordIndex)
                    } else {
                        [Void]$lightsOn.Add($coord)
                    }
                }

            } # ==> End Switch


        } # ==> End ForLoop Y
    } # ==> End ForLoop X
    
}