Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day15-Input.txt

#5x to the right

$map = @()
For($rowNumber = 0; $rowNumber -lt $dataIn.length; $rowNumber++) {
    $thisRow = $dataIn[$rowNumber]
    [string]$newRow = $thisRow
    For($i = 1; $i -lt 5; $i++) {
        $thisRow.ToCharArray().ForEach{
            [Int]$newInt = [String]$_ -as [int]
            $newInt += $i
            If($newInt -gt 9) { $newInt = $newInt - 9 }
            $newRow += [string]$newInt
        }
    }
    $map += $newRow
}

$dataIn = $map

$newRows = @()
For($i = 1; $i -lt 5; $i++) {
    For($rowNumber = 0; $rowNumber -lt $dataIn.Length; $rowNumber++) {
        $thisRow = $dataIn[$rowNumber]
        [string]$newRow = ""
        
        $thisRow.ToCharArray().ForEach{
            [Int]$newInt = [String]$_ -as [int]
            $newInt += $i
            If($newInt -gt 9) { $newInt = $newInt - 9 }
            $newRow += [string]$newInt
        }
        
        $newRows += $newRow
    }
}

$dataIn = $map + $newRows

$points = @{}
$visited = @{}

For($rowNumber = 0; $rowNumber -lt $dataIn.length; $rowNumber++) {
    For($charNumber = 0; $charNumber -lt $dataIn[0].length; $charNumber++) {
        $coord = "$rowNumber`x$charNumber"
        $points.$coord = [Int]::MaxValue
        $visited.$coord = 0
    }
}

$points.'0x0' = 0

$pointQueue = [System.Collections.Generic.PriorityQueue[object, int]]::new()
$pointQueue.Enqueue("0x0", 0)

Write-Host "Starting Queue Parsing"

While($pointQueue.Count -gt 0) {

    # Get my next point
    $currentPoint = $pointQueue.Dequeue()

    If($visited.$currentPoint -eq 1) {
        continue
    }

    $startDistance = $points.$currentPoint
   
    $x = [Int]$currentPoint.substring(0, $currentPoint.IndexOf('x'))
    $y = [Int]$currentPoint.substring($currentPoint.IndexOf('x') + 1)

    $neighbors = @()
    If($x -gt 0) { $neighbors += "$($x-1)x$y" } # Neighbor Left
    If($y -gt 0) { $neighbors += "$x`x$($y-1)" } # Neighbor Up

    If($x -lt $dataIn[0].length-1) { $neighbors += "$($x+1)x$y" } # Neighbor Right
    If($y -lt $dataIn.length-1) { $neighbors += "$x`x$($y+1)" } # Neighbor Left

    # Write-Host "I am at $currentPoint ($x,$y). My cost is $startDistance."

    ForEach($neighbor in $neighbors) {
        If($points.$neighbor) {
            $nx = [Int]$neighbor.substring(0,$neighbor.IndexOf("x"))
            $ny = [Int]$neighbor.substring($neighbor.IndexOf("x")+1)
            $nVal = [String]$dataIn[$nx][$ny] -as [int]
            $nValTotal = $nVal + $startDistance
            # Write-Host "  My neighbor at $neighbor ($nx,$ny) has a distance of $($points.$neighbor)."
            # Write-Host "  The real distance for my neighbor is $nVal (for a total distance from 0x0 of $nValTotal)"
            $neighborCost = [Math]::Min($nValTotal, $points.$neighbor)
            $points.$neighbor = $neighborCost
            $pointQueue.Enqueue($neighbor, $neighborCost)
        }
    }

    $visited.$currentPoint = 1
}

$lastPos = "$($dataIn[0].length-1)x$($dataIn.length-1)"

Write-Host "Shortest Path = $($points.$lastPos)"
