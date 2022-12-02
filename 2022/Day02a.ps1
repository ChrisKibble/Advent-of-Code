# X (Rock) - 1 Point              # Beats Scissors (C)
# Y (Paper) - 2 Points            # Beats Rock (A)
# Z (Scissors) - 3 Points         # Beats Paper (B)

# A: Rock
# B: Paper
# C: Scissors

Function Get-RoundPoints {

    # 6 Win, 3 Draw, 0 Lose

    [CmdletBinding()]
    Param(
        [Char]$Villain,
        [Char]$Hero
    )

    $pointsTable = @{
        'AX' = 3 # Rock v. Rock (Draw)
        'AY' = 6 # Rock v. Paper (Hero)
        'AZ' = 0 # Rock v. Scissors (Villain)
        'BX' = 0 # Paper v. Rock (Villain)
        'BY' = 3 # Paper v. Paper (Draw)
        'BZ' = 6 # Paper v. Scissors (Hero)
        'CX' = 6 # Scissors v. Rock (Hero)
        'CY' = 0 # Scissors v. Paper (Villain)
        'CZ' = 3 # Scissors v. Scissors (Draw)
    }

    [String]$pointsLookupValue = "$Villain$Hero"

    Return $pointsTable.$pointsLookupValue

}

Function Get-GamePoints {

    [CmdLetBinding()]
    Param(
        [String[]]$Games
    )
    
    $rpsPoints = @{
        X = 1
        Y = 2
        Z = 3
    }

    $totalScore = 0

    ForEach($game in $games) {
        $villain = $game.Substring(0,1)
        $hero = $game.Substring(2,1)

        $totalScore += Get-RoundPoints -Villain $villain -Hero $hero
        $totalScore += $rpsPoints.$hero
    }

    Return $totalScore

}

Get-GamePoints -Games (Get-Content $PSScriptRoot\Day02-Input.txt)

