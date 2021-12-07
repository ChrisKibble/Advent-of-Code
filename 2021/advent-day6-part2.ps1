Clear-Host

Function Show-Fish {

    Param(
        [System.Collections.Hashtable]$F,
        [Switch]$NoHeader = $false
    )

    If(-Not($NoHeader)) { 
        For($i = 0; $i -le 8; $i++) { Write-Host "$i`t" -NoNewline }
        Write-Host ""
        For($i = 0; $i -le 8; $i++) { Write-Host "-`t" -NoNewline }
        Write-Host ""
    }

    For($i = 0; $i -le 8; $i++) {
        Write-Host "$($F."$i")`t" -NoNewline
    }
    
    Write-Host ""

}

$dataIn = "2,4,1,5,1,3,1,1,5,2,2,5,4,2,1,2,5,3,2,4,1,3,5,3,1,3,1,3,5,4,1,1,1,1,5,1,2,5,5,5,2,3,4,1,1,1,2,1,4,1,3,2,1,4,3,1,4,1,5,4,5,1,4,1,2,2,3,1,1,1,2,5,1,1,1,2,1,1,2,2,1,4,3,3,1,1,1,2,1,2,5,4,1,4,3,1,5,5,1,3,1,5,1,5,2,4,5,1,2,1,1,5,4,1,1,4,5,3,1,4,5,1,3,2,2,1,1,1,4,5,2,2,5,1,4,5,2,1,1,5,3,1,1,1,3,1,2,3,3,1,4,3,1,2,3,1,4,2,1,2,5,4,2,5,4,1,1,2,1,2,4,3,3,1,1,5,1,1,1,1,1,3,1,4,1,4,1,2,3,5,1,2,5,4,5,4,1,3,1,4,3,1,2,2,2,1,5,1,1,1,3,2,1,3,5,2,1,1,4,4,3,5,3,5,1,4,3,1,3,5,1,3,4,1,2,5,2,1,5,4,3,4,1,3,3,5,1,1,3,5,3,3,4,3,5,5,1,4,1,1,3,5,5,1,5,4,4,1,3,1,1,1,1,3,2,1,2,3,1,5,1,1,1,4,3,1,1,1,1,1,1,1,1,1,2,1,1,2,5,3"
$daysToWatch = 256

$dataIn = "3,4,3,1,2"
$daysToWatch = 256

$fishies = @{}

$($dataIn -split ",").ForEach{ $fishies[$_]++ }

Show-Fish $Fishies

For($day = 1; $day -le $daysToWatch; $day++) {
    
    # Move Zeros to 7 (they'll move to 6 below)
    $zeroDayFish = $fishies."0"
    $fishies."7" += $zeroDayFish

    # Shift Left
    $fishies."0" = $fishies."1"
    $fishies."1" = $fishies."2"
    $fishies."2" = $fishies."3"
    $fishies."3" = $fishies."4"
    $fishies."4" = $fishies."5"
    $fishies."5" = $fishies."6"
    $fishies."6" = $fishies."7"
    $fishies."7" = $fishies."8"
    
    $fishies."8" = $zeroDayFish

    #Show-Fish $fishies -noHeader

}

$sumOfFish = 0
$fishies.GetEnumerator().ForEach{ $sumOfFish += $_.Value }

$sumOfFish