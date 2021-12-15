Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
start-A
start-b
A-c
A-b
b-d
A-end
b-end
"@ -split "`r`n"

$dataIn = Get-Content "$PSScriptRoot\Day12-Input.txt"

$caves = New-Object System.Collections.ArrayList

$dataIn.ForEach{

    $caveLeft = $_.Substring(0, $_.IndexOf("-"))
    $caveRight = $_.Substring($_.IndexOf("-")+1)

    ForEach($caveName in @($caveLeft, $caveRight)) {
        $val = [byte][char]$caveName.Substring(0,1)
        If($val -ge 65 -and $val -le 90) { $caveType = "big" } else { $caveType = "small" }
        If($caves.Cave -notcontains $caveName) {
            [Void]$caves.Add([PSCustomObject]@{
                "Cave" = $caveName
                "CaveType" = $caveType
                "Connections" = [System.Collections.ArrayList]@()
            })
        }
    }
}


$dataIn.ForEach{
    $caveLeft = $_.Substring(0, $_.IndexOf("-"))
    $caveRight = $_.Substring($_.IndexOf("-")+1)

    $caves.where({ $_.Cave -eq $caveLeft }, 'first').ForEach{ [Void]$_.Connections.Add($caveRight) }
    $caves.where({ $_.Cave -eq $caveRight }, 'first').ForEach{ [Void]$_.Connections.Add($caveLeft) }

}

# $allPaths = New-Object System.Collections.ArrayList

Function FindPath {

    Param(
        $caveMap,
        $from,
        $deadCaves = @(),
        $path = @(),
        $allPaths = @()
    )

    # # # write-host "At position $from"

    $path += $from

    $myCave = $caveMap.where{ $_.Cave -eq $from }

    If($myCave.CaveType -eq "small") {
        # # # write-host "   I can never come back here!"
        $deadCaves += $from
    }

    # # # write-host "   Dead Caves: $($deadCaves -join ",")"

    If($from -ne "end") {      
        $myCave.Connections.Where{ $_ -notin $deadCaves }.ForEach{
            # # # write-host "   I can move to $_"
            FindPath -caveMap $caveMap -from $_ -deadCaves $deadCaves -path $path
        }
    } else {
        # # # write-host $path -ForegroundColor Green
        Return $($path -join ",")
    }

}

$p = FindPath -caveMap $caves -from "start"

write-host $p.Count