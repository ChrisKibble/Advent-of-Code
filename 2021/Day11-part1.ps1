Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$realData = @"
6318185732
1122687135
5173237676
8754362612
5718474666
8443654137
1247634346
1446514585
6717288267
1727871228
"@ -split "`r`n"

$sampleData = @"
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
"@ -split "`r`n"

$dataIn = $sampleData

$grid = @{}
$flashCount = 0

Function DrawGrid {
    For($row = 0; $row -lt $dataIn.Count; $row++) {
        For($col = 0; $col -lt $dataIn[0].Length; $col++) {
            $posName = "$row`x$col"
            Write-Host $grid.where{ $_.Position -eq $posName }.Value -NoNewline
        }    
        Write-Host ""
    }    
}

$grid = For($row = 0; $row -lt $dataIn.Count; $row++) {
    For($col = 0; $col -lt $dataIn[0].Length; $col++) {
        $posName = "$row`x$col"
        $posVal = [string]$($dataIn[$row][$col]) -as [int]
        [PSCustomObject]@{
            "Position" = $posName
            "Value" = $posVal
        }
    }    
}

For($i = 1; $i -le 100; $i++) {
    
    # Every position increases 1
    $grid.ForEach{$_.Value++}

    # Every Number Greater than nine will flash, set to zero, and increases all the neighbors
    # each cell can only flash once per step.
    $flashers = New-Object System.Collections.ArrayList
    
    While ($grid.Where({$_.Value -gt 9}, 'first')) {
        
        $grid.where{ $_.Value -gt 9 }.ForEach{
            $thisKey = $_.Position
            $_.Value = 0
            
            # Write-Host "$thisKey Flashed"
            
            [Void]$flashers.Add($thisKey)

            $row = [int]$thisKey.substring(0, $thisKey.IndexOf("x"))
            $col = [int]$thisKey.Substring($thisKey.IndexOf("x") + 1)

            $neighbors = @()
            For($x = -1; $x -le 1; $x++) {
                For($y = -1; $y -le 1; $y++) {
                    $neighbors += "$($row+$x)x$($col+$y)"
                }
            } 

            $neighbors = $neighbors.where{ $_ -ne $thisKey -and $_ -in $grid.position -and $_ -notin $flashers }

            $grid.where{$_.position -in $neighbors}.ForEach{ $_.Value++ }
        }

    }
    
    $flashCount += $flashers.Count

}


$flashCount | Out-Host