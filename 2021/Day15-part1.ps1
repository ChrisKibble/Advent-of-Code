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

$points = @{}
$visited = @{}
$paths = @{}

For($rowNumber = 0; $rowNumber -lt $dataIn.length; $rowNumber++) {
    For($charNumber = 0; $charNumber -lt $dataIn[0].length; $charNumber++) {
        $coord = "$rowNumber`x$charNumber"
        $points.$coord = [Int]::MaxValue
    }
}

$points.'0x0' = 0
$currentNode = "0x0"
$paths.'0x0' = '0x0'

$lastPos = "$($dataIn[0].length-1)x$($dataIn.length-1)"

$i = 0
Do {

    $i = $i +1 
    Write-Host "I am at $currentNode and I've visited $($visited.count) nodes"
    
    $startDistance = $points.$currentNode
    # # # Write-Host "Distance Value at this node is $startDistance"

    $x = [Int]$currentNode.substring(0,$currentNode.IndexOf("x"))
    $y = [Int]$currentNode.substring($currentNode.IndexOf("x")+1)

    $moveOptions = @()
    If($x -gt 0) { $moveOptions += "$($x-1)x$y" }
    If($x -lt $dataIn[0].length-1) { $moveOptions += "$($x+1)x$y" }
    If($y -gt 0) { $moveOptions += "$x`x$($y-1)" }        
    If($y -lt $dataIn.length-1) { $moveOptions += "$x`x$($y+1)" }

    # $moveOptions = $moveOptions.where{$_ -notin $visited.Keys}

    # Write-Host "My Neighbors are $($moveOptions -join " and ")"

    ForEach($neighbor in $moveOptions) {
        if($points.$neighbor) {
            $nx = [Int]$neighbor.substring(0,$neighbor.IndexOf("x"))
            $ny = [Int]$neighbor.substring($neighbor.IndexOf("x")+1)
            $nVal = [String]$dataIn[$nx][$ny] -as [int]
            $nVal += $startDistance
        }
    }

    $visited."$x`x$y" = $points."$x`x$y"
    # Write-Host "$x`x$y is now visited."
    $points.Remove("$x`x$y")
    
    $currentNode = $points.GetEnumerator() | Sort-Object Value | Select -First 1 -ExpandProperty Name
    # Write-Host "Moving to $currentNode"

    # if($i -eq 2) { break }
} Until (-Not($currentNode))

Write-Host "Shortest Path = $($visited.$lastPos)"

