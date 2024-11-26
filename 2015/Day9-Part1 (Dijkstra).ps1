# This was the wrong way to go about this, but I wanted to keep it anyway.


$input = @"
London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141
"@ -split "`r?`n"

$input = @"
AlphaCentauri to Snowdin = 66
AlphaCentauri to Tambi = 28
AlphaCentauri to Faerun = 60
AlphaCentauri to Norrath = 34
AlphaCentauri to Straylight = 34
AlphaCentauri to Tristram = 3
AlphaCentauri to Arbre = 108
Snowdin to Tambi = 22
Snowdin to Faerun = 12
Snowdin to Norrath = 91
Snowdin to Straylight = 121
Snowdin to Tristram = 111
Snowdin to Arbre = 71
Tambi to Faerun = 39
Tambi to Norrath = 113
Tambi to Straylight = 130
Tambi to Tristram = 35
Tambi to Arbre = 40
Faerun to Norrath = 63
Faerun to Straylight = 21
Faerun to Tristram = 57
Faerun to Arbre = 83
Norrath to Straylight = 9
Norrath to Tristram = 50
Norrath to Arbre = 60
Straylight to Tristram = 27
Straylight to Arbre = 81
Tristram to Arbre = 90
"@ -split "`r?`n"

# Too lazy to RegEx it this morning.
$map = $input.ForEach{
    $_ | Select-Object @{N='CityA';E={$_ -split ' ' | Select-Object -first 1} }, `
                       @{N='CityB';E={$_ -split ' ' | Select-Object -first 1 -Skip 2} }, `
                       @{N="Distance";E={$_ -split ' ' | Select-Object -first 1 -Skip 4} }

    $_ | Select-Object @{N='CityA';E={$_ -split ' ' | Select-Object -first 1 -Skip 2} }, `
                       @{N='CityB';E={$_ -split ' ' | Select-Object -first 1 } }, `
                       @{N="Distance";E={$_ -split ' ' | Select-Object -first 1 -Skip 4} }
}

Function Get-ShortestPath {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Array]$Map,

        [Parameter(Mandatory=$False)]
        [String]$StartCity = $map[0].CityA,

        [Parameter(Mandatory=$False)]
        [String]$EndCity = $null
    )

    $cities = $map.CityA + $map.CityB | Select-Object -Unique
    $relaxed = New-Object System.Collections.Generic.List[String]

    [Hashtable]$distances = @{}
    ForEach($city in $cities) {
        $distances.$city = [Int]::MaxValue
    }

    $distances.$StartCity = 0

    ## Start City to First Adjacent Nodes

    Write-Host "Starting Node: $startCity"
    $adjacentNodes = $map.Where{ $_.CityA -eq $startCity -and $distances.$($_.CityB) -eq [Int]::MaxValue } 
    ForEach($node in $adjacentNodes) {
        Write-Host "Distances from Starting City to $($node.CityB) is $($node.Distance)"
        $distances.$($node.CityB) = [Int]$node.Distance
    }
    $relaxed.Add($StartCity) | Out-Null

    $currentNode = $map.Where{ $_.CityA -eq $StartCity } | Sort-Object Distance | Select-Object -First 1 -ExpandProperty CityB

    Write-Host ""

    Do {
        $myDistanceFromSource = $distances.$currentNode
        Write-Host "Current Node: $currentNode and I am $myDistanceFromSource from source."
        
        $adjacentNodes = $map.Where{ $_.CityA -eq $currentNode -and $_.CityB -notin $relaxed }
        Write-Host "Adjacent Nodes: $($adjacentNodes.CityB -join ', ')"
        
        ForEach($node in $adjacentNodes) {
            $CurrentCityBDistance = $distances.$($node.CityB)
            Write-Host "I need to calculate the distance from me ($currentNode) to this node ($($node.CityB)) and include my distance to source $myDistanceFromSource."
            $DistanceDirect = $map.Where{ $_.CityA -eq $currentNode -and $_.CityB -eq $node.CityB } | Select-Object -ExpandProperty Distance
            $TotalDistance = [Int]$DistanceDirect + [Int]$myDistanceFromSource
            Write-Host "    Current Known Distance: $CurrentCityBDistance"
            Write-Host "    Direct Distance: $DistanceDirect"
            Write-Host "    Total Distance:  $TotalDistance"

            If($TotalDistance -lt $CurrentCityBDistance) {
                Write-Host "    Updating Distance to $TotalDistance"
                $Distances.$($node.CityB) = $TotalDistance
            } Else {
                Write-Host "    Not updating distance - current path is shorter"
                $Distances.$($node.CityB) = $TotalDistance
            }
        }

        $relaxed.Add($currentNode) | Out-Null
        
        # Next node is the unvisited one with the shortest known path
        $currentNode = $distances.keys | Where-Object { $_ -notin $relaxed } | ForEach-Object { [PSCustomObject]@{ City = $_; Distance = [Int]$Distances.$_ } } | Sort-Object Distance | Select-Object -First 1 -ExpandProperty City

        Write-Host "Moving on to $currentNode"

    }Until(-Not($currentNode))

    If($endCity) { 
        Return $distances.$endCity
    } Else {
        Return $distances
    }

}

$dists = ForEach($city in $map.CityA | Select-Object -Unique) {
    $Lookup = Get-ShortestPath -Map $Map -StartCity $city
    $dist = $lookup.keys | ForEach-Object { [PSCustomObject]@{ City = $_; Distance = [Int]$Lookup.$_ } } | Sort-Object Distance -Descending | Select -First 1 | Select-object -ExpandProperty Distance
    [PSCustomObject]@{
        City = $city
        Max = $Dist
    }
}

$dists | Sort-object Max -Descending


