Clear-Host 
Write-Host '---------'
Get-Date

$data = Get-Content $PSScriptRoot\Input.txt

$rxDigits = [RegEx]::New('(\d{1,})')

[System.Collections.Generic.List[Object]]$cards = ForEach($game in $data) {
    $gameSection = $game.substring(0,$game.IndexOf(':'))
    $gameNumber = $rxDigits.Match($gameSection).Groups[1].Value
    $numberSection = $game.Substring($gameSection.Length+2)
    [Int[]]$winningNumbers = $rxDigits.Matches($($numberSection -split '\|' | Select-Object -First 1)) | Select-Object -ExpandProperty Value
    [Int[]]$cardNumbers = $rxDigits.Matches($($numberSection -split '\|' | Select-Object -Last 1)) | Select-Object -ExpandProperty Value
    $winCount = @(Compare-Object $winningNumbers $cardNumbers -IncludeEqual -ExcludeDifferent).Count
    # $winningNumbers = $winningNumbers | Sort-Object
    # $cardNumbers = $cardNumbers | Sort-Object
    # Write-Host "Win: $($winningNumbers -split ',') | My: $($cardNumbers -split ',') | Wins: $winCount | Points $Points"
    [PSCustomObject]@{
        Game = $gameNumber
        WinCount = $WinCount
    }
}

$lastGameNumber = $gameNumber

# $lastGameNumber = 2

For($gameNumber = 1; $gameNumber -le $lastGameNumber; $gameNumber++) {
    $gameCards = $cards.Where{ $_.Game -eq $gameNumber }
    [Int]$totalWins = $gameCards[0].WinCount
    # $gameCards | Out-Host

    Write-Host "[$(Get-Date -format "HH:mm:ss")] Processing Game $gameNumber with TotalWins = $Totalwins"
    For($i = 1; $i -le $TotalWins; $i++) {
        $nextGame = $gameNumber + $i
        If($nextGame -le $lastGameNumber) {
            $nextGameWinCount = $cards.Where({ $_.Game -eq $nextGame }, 'first').WinCount
            Write-Host "  [$(Get-Date -format "HH:mm:ss")]   Must Duplicate Game #$nextGame a total of $($gameCards.count) times, it has WinCount of $nextGameWinCount"
            $newCard = [PSCustomObject]@{Game = $nextGame;WinCount = $nextGameWinCount}
            
            For($copyCount = 1; $copyCount -le $gameCards.count; $copyCount++) {
                $cards.Add($newCard) | Out-Null
            }
        }
    }
}

$cards.count | Out-Host
