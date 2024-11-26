$data = @"
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
$map = $data.ForEach{
    $_ | Select-Object @{N='CityA';E={$_ -split ' ' | Select-Object -first 1} }, `
                       @{N='CityB';E={$_ -split ' ' | Select-Object -first 1 -Skip 2} }, `
                       @{N="Distance";E={$_ -split ' ' | Select-Object -first 1 -Skip 4} }

    $_ | Select-Object @{N='CityA';E={$_ -split ' ' | Select-Object -first 1 -Skip 2} }, `
                       @{N='CityB';E={$_ -split ' ' | Select-Object -first 1 } }, `
                       @{N="Distance";E={$_ -split ' ' | Select-Object -first 1 -Skip 4} }
} | Select-Object -Unique -Property CityA, CityB, Distance | Sort-Object CityA

# Brute Force because I can't figure out a better TSP response.

$Cities = $Map.CityA | Select-Object -Unique

# This never panned out, dropped too quickly.
# $global:minDistance = [Int]::MaxValue

Function Get-NodePaths {
    [CmdLetBinding()]
    Param(
        [Array]$Map,
        [System.Collections.ArrayList]$Path,
        [Int]$Indent = 0,
        [Int]$TotalDistance = 0
    )

    $StringIndent = ' - ' * $Indent

    #$StringIndent = '-'

    $CurrentNode = $Path[-1]
    Write-Verbose "$StringIndent`Get-NodePaths Called. I am at $CurrentNode with Total Distance = $TotalDistance. Path = $($Path -join ', ')"
    $NextNodes = $Map.Where{ $_.CityA -eq $CurrentNode -and $_.CityB -notin ($Path) } | Select-Object -ExpandProperty CityB -Unique
    
    If($NextNodes) {
        Write-Verbose "$StringIndent`I can go to the following cities next: $($NextNodes -join ', ')"
    } Else {
        Write-Verbose "$StringIndent`Return Path = $($Path -join ', ') and Total Distance = $TotalDistance"
        If($TotalDistance -lt $global:minDistance) {
            $global:minDistance = $TotalDistance
            Write-Verbose "New Min Distance = $global:minDistance!!!"
            Write-Verbose "Continue..."
        }
        Return [PSCustomObject]@{ Path = $Path; Distance = $TotalDistance}
    }
    
    ForEach($node in $nextNodes) {
        [Int]$DistanceToNode = $Map.Where{ $_.CityA -eq $CurrentNode -and $_.CityB -eq $Node } | Select-Object -ExpandProperty Distance
        [Int]$NewDistance = $TotalDistance + $DistanceToNode

        $NewPath = $Path + @($node)

        Write-Verbose "$StringIndent`Calling self with $($newPath -join ', ') as $NewDistance < $global:minDistance"
        Get-NodePaths -Map $Map -Path $NewPath -Indent $($Indent + 1) -TotalDistance $NewDistance

    }

}

$City = $Cities[0]
$AllPaths = ForEach($City in $Cities) {
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.ttt')] $City"
    Get-NodePaths -Map $Map -Path @($City)
}

$AllPaths | Sort-Object Distance -Descending | Format-Table -AutoSize -Verbose

$unabortedPaths = $AllPaths | Where-Object { $_.Path -notcontains "ABORTED"}
$abortedPaths = $allPaths  | Where-Object { $_.Path -contains "ABORTED"}

Write-Host "Winner:"
$winner = $unabortedPaths | Sort-Object Distance | Select-Object -Last 1 -Property @{Name="Path";Express={$_.Path -join ' -> '}}, Distance

$winner

