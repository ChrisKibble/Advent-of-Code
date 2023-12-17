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
            SourceStart = $sourceRangeStart
            SourceEnd = $sourceRangeEnd
            DestStart = $destinationRangeStart
            DestEnd = $destinationRangeEnd
        }
    }

    $map
}

Function Get-SeedData {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Int64]$SeedNumber,

        [Parameter(Mandatory=$True)]
        [Array[]]$seed2soil,

        [Parameter(Mandatory=$True)]
        [Array[]]$soil2fert,

        [Parameter(Mandatory=$True)]
        [Array[]]$fert2water,

        [Parameter(Mandatory=$True)]
        [Array[]]$water2light,

        [Parameter(Mandatory=$True)]
        [Array[]]$light2temp,

        [Parameter(Mandatory=$True)]
        [Array[]]$temp2hum,

        [Parameter(Mandatory=$True)]
        [Array[]]$hum2loc
    )

    Function FindDest {
        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory=$True)]
            [Array[]]$Map,

            [Parameter(Mandatory=$True)]
            [Int64]$SourceNumber
        )

        Write-Verbose "  Need to find $sourceNumber in Map"
        $mapEntry = $map.Where({ $sourceNumber -ge $_.SourceStart -and $sourceNumber -le $_.SourceEnd },'first') | Select-Object -First 1

        If(-Not($mapEntry)) {
            # If it's not in the almanac, it's the same number.
            Write-Verbose "    Not in Map, Returning Source as Destination."
            Return $SourceNumber
        }

        [Int64]$distanceFromSource = $SourceNumber - $mapEntry.SourceStart
        Write-Verbose "    Found in Map $distanceFromSource above the SourceStart"

        [Int64]$destinationNumber = $mapEntry.DestStart + $distanceFromSource

        Write-Verbose "    Returning $DestinationNumber"

        Return $destinationNumber
    }

    Write-Verbose "Getting Seed Data for $seedNumber"

    $soil = FindDest -Map $seed2soil -SourceNumber $SeedNumber      # Find Seed to Soil
    $fert = FindDest -Map $soil2fert -SourceNumber $soil            # Find Soil to Fert
    $water = FindDest -Map $fert2water -SourceNumber $fert          # Find Fert to Water
    $light = FindDest -map $water2light -SourceNumber $water        # Find Water to Light
    $temp = FindDest -Map $light2temp -SourceNumber $light          # Find Light to Temp
    $hum = FindDest -Map $temp2hum -SourceNumber $temp              # Find Temp to Humidity
    $loc = FindDest -Map $hum2loc -SourceNumber $hum                # Find Humidity to Location

    [PSCustomObject]@{
        Seed = $SeedNumber
        Fert = $fert    
        Water = $water
        Light = $Light
        Temp = $temp
        Hum = $hum
        Loc = $loc
    }

}

$data = Get-Content .\Input.txt

$seeds = ($data[0] -split ":" | Select-Object -Last 1).Trim() -split "\s"

$seed2soil = FindMapInAlmanac -Almanac $data -MapName "seed-to-soil map:"
$soil2fert = FindMapInAlmanac -Almanac $data -MapName "soil-to-fertilizer map:"
$fert2water = FindMapInAlmanac -Almanac $data -MapName "fertilizer-to-water map:"
$water2light = FindMapInAlmanac -Almanac $data -MapName "water-to-light map:"
$light2temp = FindMapInAlmanac -Almanac $data -MapName "light-to-temperature map:"
$temp2hum = FindMapInAlmanac -Almanac $data -MapName "temperature-to-humidity map:"
$hum2loc = FindMapInAlmanac -Almanac $data -MapName "humidity-to-location map:"

# Get-SeedData -SeedNumber 13 -seed2soil $seed2soil -soil2fert $soil2fert -fert2water $fert2water -water2light $water2light -light2temp $light2temp -temp2hum $temp2hum -hum2loc $hum2loc -Verbose

$seedList = $seeds.ForEach{
    Get-SeedData -SeedNumber $_ -seed2soil $seed2soil -soil2fert $soil2fert -fert2water $fert2water -water2light $water2light -light2temp $light2temp -temp2hum $temp2hum -hum2loc $hum2loc
}

$seedList | FT -AutoSize

$seedList | Sort-Object Loc | Select-Object -First 1 -ExpandProperty Loc