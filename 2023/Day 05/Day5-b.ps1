Set-StrictMode -Version 2

Clear-Host
Get-Date
Write-Host "---"

Function FindMapInAlmanac {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [AllowEmptyString()]
        [String[]]$almanac,
        [Parameter(Mandatory=$True)]
        [String]$mapName
    )

    Write-Verbose "Finding Map $MapName"

    $mapStart = $almanac.IndexOf($mapName) + 1
    Write-Verbose "Map Starts at $mapStart"

    If($mapStart -lt 0) { Throw "Cannot Find Map Start" }

    $mapEnd = ($almanac[$mapStart..$almanac.Count]).IndexOf("") + $mapStart - 1
    If($mapEnd -lt $mapStart) { $mapEnd = $almanac.Count }
    Write-Verbose "Map Ends at $mapEnd"

    $seed2map = $almanac[$mapStart..$mapEnd]

    $map = $seed2map.ForEach{
        $numbers = $_ -split "\s"
        Write-Verbose "Processing $($numbers -join ',')"
        [Int64]$rangeLength = $numbers[2]
        
        [Int64]$destinationRangeStart = $numbers[0]
        [Int64]$destinationRangeEnd = $destinationRangeStart + $rangeLength - 1
        
        [Int64]$sourceRangeStart = $numbers[1]
        [Int64]$sourceRangeEnd = $sourceRangeStart + $rangeLength - 1
        
        Write-Verbose "  $destinationRangeStart -> $destinationRangeEnd"
        Write-Verbose "  $sourceRangeStart -> $sourceRangeEnd"
    
        [PSCustomObject]@{
            MapName = $mapName
            SourceStart = [Int64]$sourceRangeStart
            SourceEnd = [Int64]$sourceRangeEnd
            DestStart = [Int64]$destinationRangeStart
            DestEnd = [Int64]$destinationRangeEnd
            PlotLen = [Int64]$rangeLength
        }
    }

    $map
}

Function Get-Destinations {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Array]$Sources,

        [Parameter(Mandatory=$True)]
        [Array]$Map,

        [Parameter(Mandatory=$False)]
        [String]$MapName = $map[0].MapName
    )

    $DestinationList = ForEach($s in $Sources) {
        $SourceStart = $s.SourceStart
        $SourceEnd = $s.SourceEnd

        Write-Verbose "I need to return all destinations for $SourceStart -> $SourceEnd in map '$MapName'"

        $index = $SourceStart
        While($index -lt $SourceEnd) {
            Write-Verbose "  Need to find entry in map that supports $Index"

            $mapEntry = $map.where({ $_.SourceStart -le $index -and $_.SourceEnd -ge $index},'first')

            If($mapEntry) {
                
                $MapStartDifference = $index - $mapEntry.SourceStart
                
                $DestinationRangeStart = $mapEntry.DestStart + $MapStartDifference
                
                Write-Verbose "    Found Entry in Map where MapStartDifference=$MapStartDifference"
                Write-Verbose "    New Destination Start is $DestinationRangeStart"

                If($mapEntry.SourceEnd -ge $SourceEnd) {
                    Write-Verbose "    This map contains all of our numbers"
                    $EndOfRange = $SourceEnd
                } Else {
                    Write-Verbose "    This map does not contain all of our numbers"
                    $EndOfRange = $mapEntry.SourceEnd
                }

                $MapEndDifference = $mapEntry.SourceEnd - $EndOfRange
                Write-Verbose "    EndOfRange for this loop is $EndOfRange. MapEndDifference=$MapEndDifference"

                $DestinationRangeEnd = $mapEntry.DestEnd - $MapEndDifference
                Write-Verbose "    New Destination End is $DestinationRangeEnd"
            } Else {
                
                Write-Verbose "    This index is not in the map. Look for next number that is on a map"

                $nextSourceStart = $map.where{ $_.SourceStart -gt $index } | Sort-Object SourceStart | Select-Object -First 1 -ExpandProperty SourceStart
                
                If($nextSourceStart) { Write-Verbose "      Found map that starts with $nextSourceStart" }
                
                If($nextSourceStart -gt $SourceEnd) {
                    Write-Verbose "    This map is beyond our range, so we know that every number from here to $sourceEnd is itself"
                    $DestinationRangeStart = $index
                    $DestinationRangeEnd = $SourceEnd
                } ElseIf($null -eq $nextSourceStart) {
                    Write-Verbose "    There is no map, so we know that every number from here to $sourceEnd is itself"
                    $DestinationRangeStart = $index
                    $DestinationRangeEnd = $SourceEnd
                } Else {
                    Write-Verbose "    This map is not beyond our range, so we know that every number from here to $($nextSourceStart-1) is itself"
                    $DestinationRangeStart = $index
                    $DestinationRangeEnd = $nextSourceStart - 1
                }

                $EndOfRange = $DestinationRangeEnd

            }
            
            Write-verbose "    Result: Destination Range $DestinationRangeStart -> $DestinationRangeEnd"

            [PSCustomObject]@{
                SourceStart = $DestinationRangeStart
                SourceEnd = $DestinationRangeEnd
            }

            Write-Verbose "  Advancing Loop to $($EndOfRange + 1)"
            $index = $EndOfRange + 1

        }

    } #=> Items in Source Array

    $DestinationList
}







$data = Get-Content .\Input.txt -ErrorAction Stop

$rxSeedPairs = [RegEx]::New('(\d+)\s(\d+)')
$SeedPairs = $rxSeedPairs.Matches($data[0])

$seeds = ForEach($pair in $seedPairs) {
    [PSCustomObject]@{
        SourceStart = [Int64]$pair.Groups[1].Value
        SourceEnd = [Int64]$pair.Groups[1].Value + [Int64]$pair.Groups[2].Value - 1
    }
}

$seed2soil   = FindMapInAlmanac -Almanac $data -MapName "seed-to-soil map:"
$soil2fert   = FindMapInAlmanac -Almanac $data -MapName "soil-to-fertilizer map:"
$fert2water  = FindMapInAlmanac -Almanac $data -MapName "fertilizer-to-water map:"
$water2light = FindMapInAlmanac -Almanac $data -MapName "water-to-light map:"
$light2temp  = FindMapInAlmanac -Almanac $data -MapName "light-to-temperature map:"
$temp2hum    = FindMapInAlmanac -Almanac $data -MapName "temperature-to-humidity map:"
$hum2loc     = FindMapInAlmanac -Almanac $data -MapName "humidity-to-location map:"

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Soil"
$soilFromSeeds  = Get-Destinations -Sources $seeds          -Map $seed2soil

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Fert"
$fertFromSoil   = Get-Destinations -Sources $soilFromSeeds  -Map $soil2fert

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Water"
$waterFromFert  = Get-Destinations -Sources $fertFromSoil   -Map $fert2water

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Light"
$lightFromWater = Get-Destinations -Sources $waterFromFert  -Map $water2light

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Temp"
$tempFromLight  = Get-Destinations -Sources $lightFromWater -Map $light2temp

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Hum"
$humFromTemp    = Get-Destinations -Sources $tempFromLight  -Map $temp2hum

Write-Host "[$(Get-Date -format 'HH:mm:ss')] Getting Loc"
$locFromHum     = Get-Destinations -Sources $humFromTemp    -Map $hum2loc

$locFromHum | Sort-Object SourceStart | Select-Object -First 1 -ExpandPropert SourceStart


