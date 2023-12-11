

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

$GameResults = Parse-Input (Get-Content $PSScriptRoot\input.txt)

$allProducts = $GameResults | Group-Object Game | ForEach-Object {
    $sets = $_.Group
    $blue = $($sets | Select-Object -ExpandProperty blue -ErrorAction SilentlyContinue | Measure-Object -Maximum).Maximum
    $green = $($sets | Select-Object -ExpandProperty green -ErrorAction SilentlyContinue | Measure-Object -Maximum).Maximum
    $red = $($sets | Select-Object -ExpandProperty red -ErrorAction SilentlyContinue | Measure-Object -Maximum).Maximum
    $MaxProduct = $blue * $green * $red
    $MaxProduct
}

$allProducts | Measure-Object -Sum | Select-Object -ExpandProperty Sum