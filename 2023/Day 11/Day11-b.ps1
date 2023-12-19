Clear-Host
Get-Date
Write-Host '---'

Function Get-ExpandedUniverse {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [System.Collections.Generic.List[String]]$map
    )

    [System.Collections.Generic.List[Int]]$WormHoleRows = @()

    $rawMap = $map -join ''

    $dots = [RegEx]::New('\.').Matches($rawMap) | Select-Object -ExpandProperty Index

    [Int[]]$WormHoleColumns = For($index = 0; $index -lt $map[0].Length; $index++) {
        [Array]$multiples = For($entry = $index; $entry -le $rawMap.Length-1; $entry += $map[0].Length) {
            $entry
        }
        If(-Not $multiples.Where({$_ -notin $dots},'first')) {
            $index
        }
    }

    $WormHoleColumns = $WormHoleColumns | Sort-Object -Descending

    $i = 0

    [System.Collections.Generic.List[String]]$map = ForEach($line in $map) {
        $WormHoleColumns.ForEach{
            $line = $line.Remove($_,1).Insert($_,'w')
        }
        if($line -notmatch "[^\.w]") {
            $line -replace '\.', 'w'
            $WormHoleRows.Add($i) | Out-Null
        } Else {
            $line
        }
        $i++
    }

    Return [PSCustomObject]@{
        Map = $Map
        WormholeColumns = $WormHoleColumns
        WormholeRows = $WormHoleRows
    }

}

$map = Get-Content $PSScriptRoot\Input.txt

Write-Host "[$(Get-Date)] I have the map in memory"

$universe = Get-ExpandedUniverse $map -Verbose
[System.Collections.Generic.List[String]]$map = $universe.map

Write-Host "[$(Get-Date)] I have the expanded map in memory"

$rxGalaxy = [RegEx]::New('#')

$galId = 0

$galaxies = @{}
For($index = 0; $index -lt $map.Count; $index++) {
    $rxGalaxy.Matches($map[$index]).ForEach{
        $galaxies.$galId = @{X = $index; Y = $_.index}
        $galId++
    }
}


Write-Host "[$(Get-Date)] I have all galaxies"

[Int64]$TotalLen = 0
$galaxies.GetEnumerator() | Sort-Object | ForEach-Object {
    $StartKey = $_.Key
    $startX = $_.Value.X
    $startY = $_.Value.Y
    $galaxies.GetEnumerator().Where{$_.Key -gt $StartKey}.ForEach{
        # $EndKey = $_.Key
        $EndX = $_.Value.X
        $EndY = $_.Value.Y
        $PathLen = [Math]::Abs($StartX - $EndX) + [Math]::Abs($StartY-$EndY)
        [Array]$RowChanges = $universe.WormholeRows.Where{ $_ -gt [Math]::Min($StartX, $EndX) -and $_ -lt [Math]::Max($StartX, $EndX) }
        [Array]$ColumnChanges = $universe.WormholeColumns.Where{ $_ -gt [Math]::Min($StartY, $EndY) -and $_ -lt [Math]::Max($StartY, $EndY) }
        [Int]$Wormholes = $RowChanges.Count + $ColumnChanges.Count
        $PathLen = ($PathLen - $Wormholes) + (1000000 * $Wormholes)
        # Write-Host "The path from $StartX`x$startY ($StartKey) to $endX`x$EndY ($EndKey) is $PathLen with $wormholes wormholes"
        $TotalLen += $PathLen
    }
}

Write-Host "[$(Get-Date)] I've mapped all paths"

Write-Host "There are $TotalLen Paths (Summed)"

<#
$numberedMap = For($i = 0; $i -lt $map.Count; $i++) {
    $line = $map[$i]
    $galaxies.GetEnumerator() | Where-Object { $_.Value.X -eq $i } | ForEach-Object {
        $line = $line.Remove($_.Value.Y,1).Insert($_.Value.Y, $_.Name)
    }
    $line
}
$numberedMap | Out-Host 
#>

# $map | Out-host