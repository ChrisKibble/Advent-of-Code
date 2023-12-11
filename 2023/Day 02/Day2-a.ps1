

Function Parse-Input {

    [CmdLetBinding()]
    Param(
        [String[]]$Data
    )

    $rxColors = [RegEx]::New('(\d+) (.*?)(?:,|$)')

    $GameResults = ForEach($Game in $Data) {
        Write-Verbose "Processing $Game"

        $gameNumber = [RegEx]::Match($game,"Game (\d+)").Groups[1].Value
        Write-Verbose "  Game #$gameNumber"

        $sets = $game.substring($game.IndexOf(':')+2)
        Write-Verbose "  Sets: $sets"

        $setNumber = 0
        ForEach($set in $sets -split '; ') {
            $setNumber++
            Write-Verbose "    Set #$setNumber`: $set"
            $colorMatches = $rxColors.Matches($set)

            $cubes = ForEach($m in $colorMatches) {
                $count = $m.groups[1].value
                $color = $m.groups[2].value
                @{ $color = $count }
                Write-Verbose "     There are $count of $color"
            }

            $gameInformation = [PSCustomObject]@{
                Game = [Int]$gameNumber
                Set = [Int]$setNumber
            }

            $cubes.keys.ForEach{
                $color = $_
                [Int]$count = $cubes.$color
                Write-Verbose "      Adding $color = $count to object."
                Add-Member -InputObject $gameInformation -MemberType NoteProperty -Name $color -Value $Count
            }

            $gameInformation
        }
    }

    Return $GameResults

}

$GameResults = Parse-Input (Get-Content $PSScriptRoot\Input.txt)

$limits = @{
    Red = 12
    Green = 13
    Blue = 14
}

$ImpossibleGames = $limits.Keys.ForEach{
    $color = $_
    $count = $limits.$color
    $search = "`$GameResults | Where-Object { `$_.$color -gt $count }"
    Invoke-Command -ScriptBlock $([ScriptBlock]::Create($search))
}

$ImpossibleGameNumbers = $ImpossibleGames | Select-Object -ExpandProperty Game -Unique

$PossibleGames = $GameResults.Where{ $_.Game -notin $ImpossibleGameNumbers}
$PossibleGameNumbers = $PossibleGames | Select-Object -ExpandProperty Game -Unique

$PossibleSum = ($PossibleGameNumbers | Measure-Object -Sum).Sum

Write-Output $PossibleSum