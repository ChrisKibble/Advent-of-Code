Clear-Host
Get-Date
Write-Host '---'

Function Get-ExpandedUniverse {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [System.Collections.Generic.List[String]]$map
    )

    $rawMap = $map -join ''

    $dots = [RegEx]::New('\.').Matches($rawMap) | Select-Object -ExpandProperty Index

    [Int[]]$emptyColumns = For($index = 0; $index -lt $map[0].Length; $index++) {
        [Array]$multiples = For($entry = $index; $entry -le $rawMap.Length-1; $entry += $map[0].Length) {
            $entry
        }
        If(-Not $multiples.Where({$_ -notin $dots},'first')) {
            $index
        }
    }

    $emptyColumns = $emptyColumns | Sort-Object -Descending

    [System.Collections.Generic.List[String]]$map = ForEach($line in $map) {
        $emptyColumns.ForEach{
            $line = $line.Insert($_,'.')
        }
        $line
        if($line -eq ('.' * $line.Length)) {
            $line
        }
    }

    Return $map

}

$map = Get-Content $PSScriptRoot\Input.txt

Write-Host "[$(Get-Date)] I have the map in memory"

[System.Collections.Generic.List[String]]$map = Get-ExpandedUniverse $map

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

[Int]$TotalLen = 0
$galaxies.GetEnumerator() | Sort-Object | ForEach-Object {
    $StartKey = $_.Key
    $startX = $_.Value.X
    $startY = $_.Value.Y
    $galaxies.GetEnumerator().Where{$_.Key -gt $StartKey}.ForEach{
        # $EndKey = $_.Key
        $EndX = $_.Value.X
        $EndY = $_.Value.Y
        $PathLen = [Math]::Abs($StartX - $EndX) + [Math]::Abs($StartY-$EndY)
        #Write-Host "The path from $StartX`x$EndX to $EndY`x$EndY is $PathLen"
        $TotalLen += $PathLen
    }
}

Write-Host "[$(Get-Date)] I've mapped all paths"
