$dataIn = Get-Content $PSScriptRoot\Day04-Input.txt

$balls = $dataIn[0] -split ","

$cards = @()
$cardNumber = 0

$cardsWon = @()

# Loop Over Cards
For($i = 2; $i -lt $dataIn.Length; $i += 6) {
    
    # Loop Over Rows
    For($j = 0; $j -lt 5; $j++) {
        $line = $dataIn[$i+$j]
        $cards += [PSCustomObject]@{
            "CN" = [string]$cardNumber
            "B" = [int]$line.substring(0,2)
            "I" = [int]$line.substring(3,2)
            "N" = [int]$line.substring(6,2)
            "G" = [int]$line.substring(9,2)
            "O" = [int]$line.substring(12,2) 
        }        
    }

    $cardNumber ++
}

$winningBall = -1
ForEach($ball in $balls) {

    $hadWin = $false

    $cards.where{[int]$_.cn -notin $cardsWon -and $_.B -eq [int]$ball}.ForEach{$_.B = "X"} | Out-Null
    $cards.where{[int]$_.cn -notin $cardsWon -and $_.I -eq [int]$ball}.ForEach{$_.I = "X"} | Out-Null
    $cards.where{[int]$_.cn -notin $cardsWon -and $_.N -eq [int]$ball}.ForEach{$_.N = "X"} | Out-Null
    $cards.where{[int]$_.cn -notin $cardsWon -and $_.G -eq [int]$ball}.ForEach{$_.G = "X"} | Out-Null
    $cards.where{[int]$_.cn -notin $cardsWon -and $_.O -eq [int]$ball}.ForEach{$_.O = "X"} | Out-Null

    # Find horizontal winner
    $winner = $cards.where{
        $_.cn -notin $cardsWon -and
        $_.B -eq "X" -and
        $_.I -eq "X" -and
        $_.N -eq "X" -and
        $_.G -eq "X" -and
        $_.O -eq "X"
    }

    if($winner.count -gt 0) {
        $winningBall = $ball
        ForEach($w in $winner) {
            Write-Host "Card $($w.cn) is a horizontal winner with $ball ..."
            $cardsWon += @($w.cn)
        }
    }

    # Find Veritcal Winner
    $verWinners = @()
    
    $verWinners += $cards.where{$_.cn -notin $cardsWon -and $_.B -eq "X"} | Group-Object -Property cn | Where-Object { $_.Count -eq 5 } | Select -ExpandProperty Name
    $verWinners += $cards.where{$_.cn -notin $cardsWon -and $_.I -eq "X"} | Group-Object -Property cn | Where-Object { $_.Count -eq 5 } | Select -ExpandProperty Name
    $verWinners += $cards.where{$_.cn -notin $cardsWon -and $_.N -eq "X"} | Group-Object -Property cn | Where-Object { $_.Count -eq 5 } | Select -ExpandProperty Name
    $verWinners += $cards.where{$_.cn -notin $cardsWon -and $_.G -eq "X"} | Group-Object -Property cn | Where-Object { $_.Count -eq 5 } | Select -ExpandProperty Name
    $verWinners += $cards.where{$_.cn -notin $cardsWon -and $_.O -eq "X"} | Group-Object -Property cn | Where-Object { $_.Count -eq 5 } | Select -ExpandProperty Name

    ForEach($w in $verWinners) {
        $winningBall = $ball
        Write-Host "Card $($w) is a vertical winner with $ball ..."
        $cardsWon += @($w)
    }

}

Write-Host "Last card to win is $($cardsWon[-1])"

$cards.where{$_.cn -eq $cardsWon[-1]} | FT -AutoSize

$cardSum = 0

$cards.where{$_.cn -eq $cardsWon[-1]}.ForEach{
    $cardSum += $_.B -as [int]
    $cardSum += $_.I -as [int]
    $cardSum += $_.N -as [int]
    $cardSum += $_.G -as [int]
    $cardSum += $_.O -as [int]
}

$cardSum * $winningBall