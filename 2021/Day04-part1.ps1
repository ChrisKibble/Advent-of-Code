$dataIn = Get-Content $PSScriptRoot\Day04-Input.txt

$balls = $dataIn[0] -split ","

$cards = @()
$cardNumber = 0

# Loop Over Cards
For($i = 2; $i -lt $dataIn.Length; $i += 6) {
    
    # Loop Over Rows
    For($j = 0; $j -lt 5; $j++) {
        $line = $dataIn[$i+$j]
        $cards += [PSCustomObject]@{
            "#" = [string]$cardNumber
            "B" = [int]$line.substring(0,2)
            "I" = [int]$line.substring(3,2)
            "N" = [int]$line.substring(6,2)
            "G" = [int]$line.substring(9,2)
            "O" = [int]$line.substring(12,2) 
        }        
    }

    $cardNumber ++
}

ForEach($ball in $balls) {
    $cards.where{$_.B -eq [int]$ball}.ForEach{$_.B = "X"} | Out-Null
    $cards.where{$_.I -eq [int]$ball}.ForEach{$_.I = "X"} | Out-Null
    $cards.where{$_.N -eq [int]$ball}.ForEach{$_.N = "X"} | Out-Null
    $cards.where{$_.G -eq [int]$ball}.ForEach{$_.G = "X"} | Out-Null
    $cards.where{$_.O -eq [int]$ball}.ForEach{$_.O = "X"} | Out-Null

    # Find horizontal winner
    $winner = $cards.where{
        $_.B -eq "X" -and
        $_.I -eq "X" -and
        $_.N -eq "X" -and
        $_.G -eq "X" -and
        $_.O -eq "X"
    }

    if($winner.count -gt 0) {
        $winningCard = $winner.'#'
        break
    }

    # Find Veritcal Winner
    $bVertWin = $cards.where{$_.B -eq "X"} | Group-Object -Property '#' | Where-Object { $_.Count -eq 5 }
    $iVertWin = $cards.where{$_.I -eq "X"} | Group-Object -Property '#' | Where-Object { $_.Count -eq 5 }
    $nVertWin = $cards.where{$_.N -eq "X"} | Group-Object -Property '#' | Where-Object { $_.Count -eq 5 }
    $gVertWin = $cards.where{$_.G -eq "X"} | Group-Object -Property '#' | Where-Object { $_.Count -eq 5 }
    $oVertWin = $cards.where{$_.O -eq "X"} | Group-Object -Property '#' | Where-Object { $_.Count -eq 5 }

    if($bVertWin) { $winningCard = $bVertWin.Name; break }
    if($iVertWin) { $winningCard = $iVertWin.Name; break }
    if($nVertWin) { $winningCard = $nVertWin.Name; break }
    if($gVertWin) { $winningCard = $gVertWin.Name; break }
    if($oVertWin) { $winningCard = $oVertWin.Name; break }

}

Write-Host "Winning Card is $winningCard"

$cards.where{$_.'#' -eq $winningCard} | FT -AutoSize

$cardSum = 0

$cards.where{$_.'#' -eq $winningCard}.ForEach{
    $cardSum += $_.B -as [int]
    $cardSum += $_.I -as [int]
    $cardSum += $_.N -as [int]
    $cardSum += $_.G -as [int]
    $cardSum += $_.O -as [int]
}

$cardSum * $ball