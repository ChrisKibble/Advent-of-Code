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
    [PSCustomObject]@{
        Game = $gameNumber
        WinCount = $WinCount
        CardCount = 1
    }
}

$cards.insert(0, [PSCustomObject]@{ Game = 0; WinCount = 0; CardCount = 0})
$lastGameNumber = $gameNumber

# $cards | FT -AutoSize

For($gameNumber = 1; $gameNumber -le $lastGameNumber; $gameNumber++) {

    $card = $cards[$gameNumber]
    $WinCount = $card.WinCount
    $CardCount = $card.CardCount
    
    If($WinCount -gt 0) { $CardsToUpdate = $($gameNumber+1)..$($gameNumber+$WinCount) } Else { $CardsToUpdate = $null }

    #Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Processing Game #$($card.Game)"
    #Write-Host "[$(Get-Date -Format 'HH:mm:ss')]   WinCount = $WinCount and CardCount = $CardCount"

    #Write-Host "[$(Get-Date -Format 'HH:mm:ss')]   We need to add $cardCount to the next $WinCount Cards $($CardsToUpdate -join ',')"
    $CardsToUpdate.ForEach{ $cards[$_].CardCount += $CardCount }

}

$cards | Select-Object -ExpandProperty CardCount | Measure-Object -Sum | Select-Object -ExpandProperty Sum