Clear-Host

$dataIn = Get-Content $PSScriptRoot\day05-input.txt

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

$lines.where{ $_.x1 -eq $_.x2 -or $_.y1 -eq $_.y2 } | ForEach{
    
    If($_.x1 -eq $_.x2) {
        $xVal = $_.x1
        $yStart = [Math]::Min($_.y1,$_.y2)
        $yEnd = [Math]::Max($_.y1,$_.y2)

        $($yStart..$yEnd).ForEach{
            $pointName = "$xVal,$($_)"
            $points[$pointName]++
        }
    }

    If($_.y1 -eq $_.y2) {
        $yVal = $_.y1
        $xStart = [Math]::Min($_.x1,$_.x2)
        $xEnd = [Math]::Max($_.x1,$_.x2)

        $($xStart..$xEnd).ForEach{
            $pointName = "$($_),$yVal"
            $points[$pointName]++
        }
    }

}

$($points.GetEnumerator() | Where-Object { $_.Value -ge 2 }).count