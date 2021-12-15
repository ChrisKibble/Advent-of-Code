Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
2199943210
3987894921
9856789892
8767896789
9899965678
"@ -split "`r`n"

$dataIn = Get-Content "$PSScriptRoot\Day09-Input.txt"

$grid = New-Object System.Collections.ArrayList
$lowPoints = New-Object System.Collections.ArrayList

$dataIn.ForEach{
    [void]$grid.Add($_.ToCharArray())
}


# Find horizonal possibilities

$rowNumber = 0

ForEach($line in $dataIn) {
    $readings = $line.ToCharArray()
    
    #$readings

    For($i = 0; $i -lt $readings.Length; $i++) {
        
        $x = $false
        if($i -eq 0 -and $readings[$i] -lt $readings[$i+1] ) { 
            # Left most column
            $x = $true 
        } elseif( $i -eq $($readings.Length-1) -and $readings[$i] -lt $readings[$i-1]) {
            $x = $true
            # Right Most column
        } else {
            # Somewhere middle
            if($readings[$i] -lt $readings[$i-1] -and $readings[$i] -lt $readings[$i+1]) {
                $x = $true
            }
        }

        if($x) { 
            [Void]$lowPoints.Add(
                [PSCustomObject]@{
                    "Line" = $rowNumber
                    "Column" = $i
                    "Reading" = [String]$readings[$i] -as [Int]  # Converts Char to Int
                    "Confirmed" = $false
                }
            )
        }
    
    }
    
    $rowNumber++
}

# Remove possibilities that don't match vertically

ForEach($p in $lowPoints) {
    
    $line = $p.Line
    $col = $p.Column
    $val = $p.Reading

    If($line -eq 0) {
        # Top Line, nothing above
        $above = [Int]10
        $below = [String]$grid[$line+1][$col] -as [Int]
    } elseif ($line -eq $grid.Count-1) {
        # Bottom line, nothing below
        $above = [String]$($grid[$line-1][$col]) -as [Int]
        $below = [Int]10
    } else {
        $above = [String]$($grid[$line-1][$col]) -as [Int]
        $below = [String]$($grid[$line+1][$col]) -as [Int]
    }
 
    If($val -lt $above -and $val -lt $below) {
        $p.Confirmed = $true
    }


}

$lowPoints = $lowPoints.where{ $_.Confirmed -eq $true } | Select Line, Column, Reading, @{Name="FoundNeighbors"; Expression={$false}}, @{Name="Source"; Expression={""}}

$groups = New-Object System.Collections.ArrayList

$totalLows = $lowPoints.Count
$lows = 0

ForEach($point in $lowPoints) {
    
    $lows++
    # Write-Host "Looking at $lows of $totalLows"

    [System.Collections.ArrayList]$allPoints = @($point)

    Do {
        $thisPoint = $allPoints.where({$_.FoundNeighbors -eq $false},'first')

        # Write-Host "Looking at $($thisPoint.line)x$($thisPoint.column)"
    
        # Look up
        If($thisPoint.Line -ne 0) {
            $newLine = $thisPoint.line - 1
            $newCol = $thisPoint.column
            If(-Not($allPoints.where{$_.Line -eq $newLine -and $_.Column -eq $newCol})) {
                # Write-Host "   Adding Up $newLine`x$newCol"
                [Void]$allPoints.Add([PSCustomObject]@{ 
                    "Line" = $newLine
                    "Column" = $newCol
                    "Reading" = [String]$($grid[$newLine][$newCol]) -as [Int]
                    "FoundNeighbors" = $false
                    # "Source" = "$($thisPoint.line)x$($thisPoint.Column)"
                })
            }
        }

        # Look Down
        If($thisPoint.line -ne $grid.Count - 1) {
            $newLine = $thisPoint.line + 1
            $newCol = $thisPoint.column
            If(-Not($allPoints.where{$_.Line -eq $newLine -and $_.Column -eq $newCol})) {
                # Write-Host "   Adding Down $newLine`x$newCol"
                [Void]$allPoints.Add([PSCustomObject]@{ 
                    "Line" = $newLine
                    "Column" = $newCol
                    "Reading" = [String]$($grid[$newLine][$newCol]) -as [Int]
                    "FoundNeighbors" = $false
                    # "Source" = "$($thisPoint.line)x$($thisPoint.Column)"
                })
            }
        }

        # Look Left
        If($thisPoint.column -ne 0) {
            $newLine = $thisPoint.line
            $newCol = $thisPoint.column - 1
            If(-Not($allPoints.where{$_.Line -eq $newLine -and $_.Column -eq $newCol})) {
                # Write-Host "   Adding Left $newLine`x$newCol"
                [Void]$allPoints.Add([PSCustomObject]@{ 
                    "Line" = $newLine
                    "Column" = $newCol
                    "Reading" = [String]$($grid[$newLine][$newCol]) -as [Int]
                    "FoundNeighbors" = $false
                    # "Source" = "$($thisPoint.line)x$($thisPoint.Column)"
                })
            }
        }

        # Look Right
        If($thisPoint.column -ne $grid[0].Count - 1) {
            $newLine = $thisPoint.line
            $newCol = $thisPoint.column + 1
            If(-Not($allPoints.where{$_.Line -eq $newLine -and $_.Column -eq $newCol})) {
                # Write-Host "   Adding Right $newLine`x$newCol"
                [Void]$allPoints.Add([PSCustomObject]@{ 
                    "Line" = $newLine
                    "Column" = $newCol
                    "Reading" = [String]$($grid[$newLine][$newCol]) -as [Int]
                    "FoundNeighbors" = $false
                    # "Source" = "$($thisPoint.line)x$($thisPoint.Column)"
                })
            }
        }
        
        $allPoints = $allPoints.where{ $_.Reading -ne 9 }

        $allPoints.where({$_.Line -eq $thisPoint.line -and $_.Column -eq $thisPoint.Column},'first')[0].FoundNeighbors = $true
           
    } Until (-Not($allPoints.where({$_.FoundNeighbors -eq $false},'first')))

    [Void]$groups.Add($allPoints.Count)

}

$product = 1
$groups | Sort -Descending | Select -First 3 | % { $product *= $_ }
$product | Out-Host