Clear-Host
Get-Date
Write-Host "---"

Function Get-RecordWinners {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [UInt64]$TimeMS,

        [Parameter(Mandatory=$True)]
        [UInt64]$RecordDistance
    )

    Write-Verbose "Need to find how long to hold the button to beat $RecordDistance`mm in a race length of $TimeMS`ms"
    $topOfCurve = [Math]::Round($TimeMS/2)

    Write-Verbose "The top of the curve is $topOfCurve"

    If($TimeMS % 2 -eq 0) {
        $TimeIsEven = $True
    } Else {
        $TimeIsEven = $False
    }

    $nextPotentialWinner = [Math]::Round($topOfCurve)

    [System.Collections.Generic.List[Int]]$RecordWinners = Do {
        $RunTime = $TimeMS - $nextPotentialWinner
        $Distance = $RunTime * $nextPotentialWinner
        $IsRecordWinner = $Distance -gt $RecordDistance
        
        Write-Verbose "Testing $NextPotentialWinner"
        Write-Verbose "  Button Hold Time = $NextPotentialWinner"
        Write-Verbose "  RunTime = $RunTime"
        Write-Verbose "  Distance (Calc) = $distance"
        Write-Verbose "  RecordWinner = $isRecordWinner"
        
        If($IsRecordWinner) { $NextPotentialWinner }

        $nextPotentialWinner++
    } Until(-Not($IsRecordWinner))

    Write-Verbose "Found $($RecordWinners.Count) Record Winners in first pass."
    If($TimeIsEven) {
        Write-Verbose "I am Even"
        $TotalWinners = ($RecordWinners.Count - 1) * 2 + 1
    } Else {
        Write-Verbose "I am Odd"
        $Totalwinners = ($RecordWinners.Count - 1) * 2
    }

    Write-Verbose "Total Winners = $TotalWinners"

    $TotalWinners

}


$data = Get-Content $PSScriptRoot\Input.txt
$times = $($data[0] -split '\s+' | Select-Object -Skip 1) -join ""
$distances = $($data[1] -split '\s+' | Select-Object -Skip 1) -join ""

$times | Out-Host
$distances | Out-Host

Get-RecordWinners -TimeMS $times -RecordDistance $distances
