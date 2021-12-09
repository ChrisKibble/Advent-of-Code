Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

Function DrawGrid {
    Param(
        [System.Collections.ArrayList]$grid
    )

    For($line = 0; $line -lt $grid.Count; $line++) {
        Write-Host $($grid[$line] -join "")
    }
}


$dataIn = @"
2199943210
3987894921
9856789892
8767896789
9899965678
"@ -split "`r`n"

$dataIn = Get-Content "$PSScriptRoot\Day9-Input.txt"

$grid = New-Object System.Collections.ArrayList
$basinMembers = New-Object System.Collections.ArrayList


# Build our grid
$dataIn.ForEach{ [void]$grid.Add($_.ToCharArray().ForEach{ [String]$_ -as [Int] }) }



$rowNumber = 0
ForEach($line in $dataIn) {
    $readings = $line
    
    For ($c = 0; $c -lt $line.Length; $c++) {
        $val = $grid[$rowNumber][$c]
        
        If([int]$val -lt 9) {
            [void]$basinMembers.Add(
                [PSCustomObject]@{
                    "Line" = $rowNumber
                    "Col" = $c
                    "Reading" = $val
                    "MemberId" = "$rowNumber,$c"
                    "BasinId" = $null
                }
            )
        }

    }

    $rowNumber++
}

# Get Next Number Not Member of Basin

#$basinStart = $basinMembers.where{ $null -eq $_.BasinId } | Select -First 1

#$basinId = New-Guid

#$basinMembers.where{ $_.MemberId -eq $basinStart.MemberId }[0].BasinId = $basinId

## Write-Host "Starting with $($basinStart.Line),$($basinStart.Col) with Value of $($basinStart.Reading)"

# Find neighbors


# Get Next Unlinked Basin Member
Do {
    $basinStart = $basinMembers.where{ $null -eq $_.BasinId } | Select -First 1
    
    # Write-Host "Processing $($basinStart.MemberId)"

    # Do any of my neighbors have a BasinId yet?
    # Write-Host "     Looking for Neighbors"
    $neighbors = $basinMembers.where{
        ($_.Col -eq $basinStart.Col -and [Math]::Abs($_.Line - $basinStart.Line) -eq 1) -or
        ($_.Line -eq $basinStart.Line -and [Math]::Abs($_.Col - $basinStart.Col) -eq 1)
    }

    # Write-Host "          My neighbors are $($neighbors.MemberId -join ",")"
    
    If($neighbors.where{$_.BasinId}.Count -gt 0) {
        # Write-Host "           My neighbors already have a basin id"
        $guid = $neighbors[0].BasinId
        # Write-Host "           Using Existing BasinId $guid"
    } else {
        # Write-Host "           None of my neighbors already have a basin id"
        $guid = New-Guid
    }
    # Write-Host "           Setting Self and All Neighbors to $guid"
    $basinMembers.Where{ $_.MemberId -eq $basinStart.MemberId -or $_.MemberId -in ($neighbors.MemberId) }.ForEach{ $_.BasinId = $guid }

    Write-Host "There are $($basinMembers.where{$Null -eq $_.BasinId}.count) members left..."

} Until ($basinMembers.where{$null -eq $_.BasinId}.Count -eq 0)


$product = 1
$($basinMembers | Group-Object BasinId | Sort Count -Descending | Select -ExpandProperty Count -First 3).ForEach{
    $product *= $_
}
$product