Clear-Host

$dataIn = Get-Content $PSScriptRoot\day5-input.txt

$dataInx = @"
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"@ -split "`r`n"

$rxCoords = [regex]::New("(\d{1,}),(\d{1,}) -> (\d{1,}),(\d{1,})")

$lines = @()
$points = New-Object System.Collections.Hashtable

$dataIn.ForEach{
    $coords = $rxCoords.match($_)

    $lines += [PSCustomObject]@{
        "x1" = $coords.Groups[1].Value
        "y1" = $coords.Groups[2].Value
        "x2" = $coords.Groups[3].Value
        "y2" = $coords.Groups[4].Value
    }

}

$lines.ForEach{
    
    If($_.x1 -eq $_.x2) {
        # Vertical Line 
        $xVal = $_.x1
        $yStart = [Math]::Min($_.y1,$_.y2)
        $yEnd = [Math]::Max($_.y1,$_.y2)

        $($yStart..$yEnd).ForEach{
            $pointName = "$xVal,$($_)"
            $points[$pointName]++
        }
    }

    If($_.y1 -eq $_.y2) {
        # Horizontal Line
        
        $yVal = $_.y1
        $xStart = [Math]::Min($_.x1,$_.x2)
        $xEnd = [Math]::Max($_.x1,$_.x2)

        $($xStart..$xEnd).ForEach{
            $pointName = "$($_),$yVal"
            $points[$pointName]++
        }
    }

    If($_.y1 -ne $_.y2 -and $_.x1 -ne $_.x2) {
        
        # 45 Degree Line
        $xStep = If([int]$_.x1 -lt [int]$_.x2) { 1 } else { -1 }
        $yStep = If([int]$_.y1 -lt [int]$_.y2) { 1 } else { -1 }
        
        [int]$x = $_.x1 - $xStep
        [int]$y = $_.y1 - $yStep

        While ($x -ne $_.x2) {
            $x = $x + $xStep
            $y = $y + $yStep
            $pointName = "$x,$y"
            $points[$pointName]++
        } 

    }

}

$($points.GetEnumerator() | Where-Object { $_.Value -ge 2 }).count