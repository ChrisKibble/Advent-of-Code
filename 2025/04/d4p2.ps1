[CmdLetBinding()]Param()

$inputFile = "$PSScriptRoot\sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$instructions = Get-Content $inputFile

[System.Collections.Generic.SortedSet[String]]$WrappingPaperPositions = @()

For($row = 0; $row -lt $instructions.Length; $row++) {
    [RegEx]::Matches($instructions[$row], '@').Index.ForEach{
        $WrappingPaperPositions.Add("$row,$($_)") | Out-Null
    }
}

[Int]$MoveMe = 0

$LastRow, $null = $WrappingPaperPositions[-1] -split ','

$Pass = 0

Do {
    $Pass++
    [System.Collections.Generic.List[String]]$RemoveMe = @()

    ForEach($position in $WrappingPaperPositions) {
        [Int]$posX, [Int]$posY = $Position -split ','
        # Write-Host "Looking at: $posX,$posY"

        $NearbyPositions = For($row = $posX-1; $row -le $posX+1; $row++) {
            For($col = $posY-1; $col -le $posY+1; $col++) {
                "$row,$col"
            }
        }

        [Int]$NearbyPaper = 0
        
        $NearbyPositions.Where{ $_ -ne "$posX,$posY" }.ForEach{ 
            if($NearbyPaper -lt 4 -and $WrappingPaperPositions.Contains($_)) { $NearbyPaper++ }
        }

        if($nearbyPaper -lt 4) {
            # Write-Host "I can remove $posX,$posY"
            $RemoveMe.Add("$posX,$posY")
            $MoveMe++
        }
    }

    If($RemoveMe.Count -gt 0) {
        $ListChanged = $True
        ForEach($paper in $RemoveMe) {
            $WrappingPaperPositions.Remove($Paper) | Out-Null
        }
    } Else {
        $ListChanged = $False
    }
    
} Until(-Not($ListChanged))

$MoveMe