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

        # New: Get Heros Real Play for 2B
        $hero = Get-HeroAction -Villain $villain -Hero $hero

        $totalScore += Get-RoundPoints -Villain $villain -Hero $hero
        $totalScore += $rpsPoints.$hero
    }

    Return $totalScore

}

Function Get-HeroAction {

    [CmdLetBinding()]
    Param(
        [Char]$Villain,
        [Char]$Hero
    )

    # X - Hero Must Lose
    # Y - Hero Must Draw
    # Z - Hero Must Win

    $actionTable = @{
        'AX' = 'Z' # Villain Rock, Hero Must Lose. Throw Scissors.
        'AY' = 'X' # Villain Rock, Hero Must Draw. Throw Rock.
        'AZ' = 'Y' # Villain Rock, Hero Must Win. Throw Paper.
        'BX' = 'X' # Villain Paper, Hero Must Lose. Throw Rock.
        'BY' = 'Y' # Villain Paper, Hero Must Draw. Throw Paper.
        'BZ' = 'Z' # Villain Paper, Hero Must Win. Throw Scissors.
        'CX' = 'Y' # Villain Scissors, Hero Must Lose. Throw Paper.
        'CY' = 'Z' # Villain Scissors, Hero Must Draw. Throw Scissors.
        'CZ' = 'X' # Villain Scissors, Hero Must Win. Throw Rock.
    }

    [String]$heroActionLookupValue = "$Villain$Hero"

    Return $actionTable.$heroActionLookupValue

}

Get-GamePoints -Games (Get-Content $PSScriptRoot\Day02-Input.txt)

