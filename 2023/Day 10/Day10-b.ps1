Set-StrictMode -Version 2.0

#$VerbosePreference = 'Continue'
$VerbosePreference = 'Ignore'

Clear-Host
Get-Date
Write-Host "---"

$global:legend = @(
    [PSCustomObject]@{ Key = '.'; Item = ' '; ConnectsTo = @(); }
    [PSCustomObject]@{ Key = '7'; Item = '┐'; ConnectsTo = @('Down', 'Left');  }
    [PSCustomObject]@{ Key = 'J'; Item = '┘'; ConnectsTo = @('Up', 'Left');  }
    [PSCustomObject]@{ Key = '-'; Item = '─'; ConnectsTo = @('Left',  'Right'); }
    [PSCustomObject]@{ Key = '|'; Item = '│'; ConnectsTo = @('Up', 'Down'); }
    [PSCustomObject]@{ Key = 'F'; Item = '┌'; ConnectsTo = @('Right', 'Down'); }
    [PSCustomObject]@{ Key = 'L'; Item = '└'; ConnectsTo = @('Up', 'Right'); }
    [PSCustomObject]@{ Key = 'S'; Item = '☺'; ConnectsTo = @('Up', 'Right', 'Down', 'Left'); }   
)


$opposites = @{
    Down = 'Up'
    Up = 'Down'
    Left = 'Right'
    Right = 'Left'
}

Function Get-NextPosition {

    [CmdLetBinding()]
    Param(
        [Int]$Row,
        [Int]$Col,
        [String]$Direction
    )

    Write-Verbose "[Get-NextPosition] I am at $Row,$Col and want to move $Direction"

    Switch($Direction) {
        "Up" { $pos = @{ Row = $Row - 1; Col = $Col} }
        "Down" { $pos = @{ Row = $Row + 1; Col = $Col} }
        "Left" { $pos = @{ Row = $Row; Col = $Col - 1} }
        "Right" { $pos = @{ Row = $Row; Col = $Col + 1} }       
    }
    
    $TouchedPositions.Add($pos) | Out-Null

    Return $pos

}

Function Get-AvailableMoves {

    [CmdLetBinding()]
    Param(
        [Int]$Row,
        [Int]$Column,
        [String]$IgnoreMove = '',
        $Map
    )

    $thisTile = $map[$Row][$Column]
    Write-Verbose "[Get-AvailableMoves] I am at position $Row,$Column on a $thisTile tile."

    If($thisTile -eq 'S') {
        $possibleDirections = @('Up','Down','Left','Right')
    } Else {
        $possibleDirections = $legend.Where{ $_.Item -eq $thisTile }.ConnectsTo
    }

    Write-Verbose "[Get-AvailableMoves]   From this tile I could possibly move $($possibleDirections -join ',')"

    $Movements = @()

    # Tile Up
    If($Row -gt 0 -and $possibleDirections -contains 'Up') { 
        $Up = $map[$row-1][$column]
        If( $legend.Where{ $_.Item -eq $Up -and $_.ConnectsTo -contains "Down" } ) { $movements += "Up" }
    }

    # Tile Down
    If($Row -lt $map.count -and $possibleDirections -contains 'Down') {
        $Down = $map[$row+1][$Column] 
        If( $legend.Where{ $_.Item -eq $Down -and $_.ConnectsTo -contains "Up" } ) { $movements += "Down" }
    }
    
    # Tile Left
    If($Column -gt 0 -and $possibleDirections -contains 'Left') { 
        $Left = $map[$row][$column-1]
        If( $legend.Where{ $_.Item -eq $Left -and $_.ConnectsTo -contains "Right" } ) { $movements += "Left" }
    }

    # Tile Right
    If($Column -lt $map[0].length -and $possibleDirections -contains 'Right') { 
        $Right = $map[$row][$column+1]
        If( $legend.Where{ $_.Item -eq $Right -and $_.ConnectsTo -contains "Left" } ) { $movements += "Right" }
    }
    
    $Movements = $Movements | Where-Object { $_ -notin $IgnoreMove }
    Write-Verbose "[Get-AvailableMoves]   Tiles that will accept me that aren't where I came from are $($Movements -join ',')"

    Return $Movements
    

}

[System.Collections.Generic.List[Object]]$global:TouchedPositions = @()

$rawMap = Get-Content $PSScriptRoot\Input.txt
$rawMap = Get-Content $PSScriptRoot\Sample2.txt

$startLineIndex = $rawMap.IndexOf($rawMap.Where{ $_.ToCharArray() -contains 'S' })
$startLineColumn = $rawMap[$startLineIndex].IndexOf('S')

$rawMap = $rawMap.ForEach{
    $mapLine = $_
    $legend.ForEach{
        $mapLine = $mapLine.Replace($_.Key, $_.Item)
    }
    $mapLine
}

# $rawMap | Out-Host

$pos = @{
    Row = $startLineIndex
    Col = $startLineColumn
}

Write-Verbose "[Main] I am at $($pos.Row),$($pos.Col)"
$nextMove = Get-AvailableMoves -Row $pos.Row -Col $pos.Col -Map $rawMap | Select-Object -First 1

Write-Verbose "[Main] I will move $nextMove"
$pos = Get-NextPosition -Row $pos.Row -col $pos.Col -Direction $nextMove

$stepCount = 1
Do {
    Write-Verbose "[Main] I am at $($pos.Row),$($pos.Col)"
    Write-Verbose "[Main] I need to make another move and can't move $($opposites.$nextMove)"
    $nextMove = Get-AvailableMoves -Row $pos.Row -Col $pos.Col -Map $rawMap -IgnoreMove $opposites.$nextMove
    $pos = Get-NextPosition -Row $pos.Row -col $pos.Col -Direction $nextMove
    $thisTile = $rawMap[$pos.Row][$pos.Col]
    Write-Verbose "[Main] I have moved to $($pos.Row),$($pos.Col) and I'm now on a $thisTile"
    $stepCount++
} Until ($thisTile -eq '☺')

Write-Host "I took $stepCount total steps so the further point away was $($stepCount/2)"

$rowsToProcess = $rawMap.Count
$rowsToProcess = 10

$position = 'outside'

$newMap = For($rows = 0; $rows -lt $rowsToProcess; $rows++) {
    $mapLine = ""
    For($cols = 0; $cols -lt $rawMap[0].Length; $cols++) {
        If($TouchedPositions.Where({ $_.Row -eq $rows -and $_.Col -eq $cols },'first').count) {
            $mapLine += $rawMap[$rows][$cols]
        } Else {
            If($position -eq "Outside") {
                $mapLine += '.'    
            } Else {
                $mapLine += ' '
            }
        }
    }
    $mapLine
}

$newMap = $newMap.Where{ $_ -ne " " * $newMap[0].Length }

$newMap | Out-Host

