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

    # For debugging only
    # Add-Member -InputObject $p -MemberType NoteProperty -Name Above -Value $above
    # Add-Member -InputObject $p -MemberType NoteProperty -Name Below -Value $below
  
    If($val -lt $above -and $val -lt $below) {
        $p.Confirmed = $true
    }


}

$lowPoints.where{ $_.Confirmed -eq $true } | FT -AutoSize

$sum = 0
$lowPoints.where{ $_.Confirmed -eq $true }.ForEach{
    $sum += $_.Reading + 1
}

Write-Host $sum