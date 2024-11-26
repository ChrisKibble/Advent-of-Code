# So much junk left behind... 

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

# Brute Force because I can't figure out TSP.

$StartingCity = $map[0].CityA

Function Get-Paths {
    [CmdLetBinding()]
    [Array]$Map
    [String]$City,
    [System.Collections.Generic.List[String]]$CurrentPath

    Write-Verbose ""
}