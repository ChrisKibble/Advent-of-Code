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
    
    If($caveLeft -ne "start") {
        $caves.where({ $_.Cave -eq $caveRight }, 'first').ForEach{ [Void]$_.Connections.Add($caveLeft) }
    }
}

Function FindPath {

    Param(
        $caveMap,
        $from,
        $deadCaves = @(),
        $path = @(),
        $mediumCave = $null,
        $indent = 0
    )

    # write-host "$("   "*$indent)At position $from"
    # write-host "$("   "*$indent)Medium Cave: $mediumCave"

    $path += $from

    $myCave = $caveMap.where{ $_.Cave -eq $from }

    If($myCave.CaveType -eq "small" -and $from -ne $mediumCave) {
        $deadCaves += $from
        # write-host "$("   "*$indent)I can never come back here!"
    } elseif($from -eq $mediumCave) {
        # write-host "$("   "*$indent)Changing cave to small"
        $mediumCave = $null
    }

    # write-host "$("   "*$indent)Current Path: $($path -join ",")"
    # write-host "$("   "*$indent)Dead Caves: $($deadCaves -join ",")"

    If($from -ne "end") {      
        $myCave.Connections.Where{ $_ -notin $deadCaves }.ForEach{
            # write-host "$("   "*$indent)I can move to $_ from $from"
            FindPath -caveMap $caveMap -from $_ -deadCaves $deadCaves -path $path -indent $($indent+1) -mediumCave $mediumCave
        }
    } else {
        # write-host "$("   "*$indent)Final Path: $path" -ForegroundColor Green
        Return $($path -join ",")
    }

}

$caves.where{ $_.Cave -notin @("start","end") -and $_.CaveType -eq "small" }.ForEach{
    
    $medCave = $($_.Cave)
    write-host "I shall make $medCave medium"
    $p += FindPath -caveMap $caves -from "start" -mediumCave $medCave

}


$p = $p | Select -Unique
$p.count | Out-Host
