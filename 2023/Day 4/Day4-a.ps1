$data = Get-Content $PSScriptRoot\Input.txt

$rxDigits = [RegEx]::New('(\d{1,})')

$cardPoints = ForEach($game in $data) {
    $gameSection = $game.substring(0,$game.IndexOf(':'))
    $numberSection = $game.Substring($gameSection.Length+2)
    [Int[]]$winningNumbers = $rxDigits.Matches($($numberSection -split '\|' | Select-Object -First 1)) | Select-Object -ExpandProperty Value
    [Int[]]$cardNumbers = $rxDigits.Matches($($numberSection -split '\|' | Select-Object -Last 1)) | Select-Object -ExpandProperty Value
    $winCount = (Compare-Object $winningNumbers $cardNumbers -IncludeEqual -ExcludeDifferent).Count
    If(-Not($winCount)) {
        $points = 0
    } Else {
        $points = [Math]::Pow(2,$winCount-1)
    }
    # $winningNumbers = $winningNumbers | Sort-Object
    # $cardNumbers = $cardNumbers | Sort-Object
    # Write-Host "Win: $($winningNumbers -split ',') | My: $($cardNumbers -split ',') | Wins: $winCount | Points $Points"
    $points
}

($cardPoints | Measure-Object -Sum).Sum