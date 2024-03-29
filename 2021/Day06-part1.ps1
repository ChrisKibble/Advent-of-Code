﻿Clear-Host

$dataIn = "2,4,1,5,1,3,1,1,5,2,2,5,4,2,1,2,5,3,2,4,1,3,5,3,1,3,1,3,5,4,1,1,1,1,5,1,2,5,5,5,2,3,4,1,1,1,2,1,4,1,3,2,1,4,3,1,4,1,5,4,5,1,4,1,2,2,3,1,1,1,2,5,1,1,1,2,1,1,2,2,1,4,3,3,1,1,1,2,1,2,5,4,1,4,3,1,5,5,1,3,1,5,1,5,2,4,5,1,2,1,1,5,4,1,1,4,5,3,1,4,5,1,3,2,2,1,1,1,4,5,2,2,5,1,4,5,2,1,1,5,3,1,1,1,3,1,2,3,3,1,4,3,1,2,3,1,4,2,1,2,5,4,2,5,4,1,1,2,1,2,4,3,3,1,1,5,1,1,1,1,1,3,1,4,1,4,1,2,3,5,1,2,5,4,5,4,1,3,1,4,3,1,2,2,2,1,5,1,1,1,3,2,1,3,5,2,1,1,4,4,3,5,3,5,1,4,3,1,3,5,1,3,4,1,2,5,2,1,5,4,3,4,1,3,3,5,1,1,3,5,3,3,4,3,5,5,1,4,1,1,3,5,5,1,5,4,4,1,3,1,1,1,1,3,2,1,2,3,1,5,1,1,1,4,3,1,1,1,1,1,1,1,1,1,2,1,1,2,5,3"
$daysToWatch = 80

#$dataIn = "3,4,3,1,2"
#$daysToWatch = 80

$fishData = @()

$dataIn -split "," | Select -Unique | ForEach-Object {
    $startAge = $_

    $fishies = @($startAge)
   
    For($i = 1; $i -le $daysToWatch; $i++) {
    
        $newFish = 0
        For($f = 0; $f -lt $fishies.count; $f++) {
        
            If($fishies[$f] -gt 0) {
                $fishies[$f] = $fishies[$f] - 1
            } else {
                $fishies[$f] = 6
                $newFish++
            }
        }

        For($f = 0; $f -lt $newFish; $f++) {
            $fishies += 8
        }

        #Write-Host "Day $i :: $($fishies -join ',')"

    }

    $fishData += @{$startAge=$($fishies.count)}

}

$totalFish = 0

$dataIn -split "," | ForEach-Object {
    
    $totalFish += $fishData.$($_)

}
$totalFish
