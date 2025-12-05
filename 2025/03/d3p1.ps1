[CmdLetBinding()]Param()

$instructions = Get-Content $PSScriptRoot\input.txt
# $instructions = Get-Content $PSScriptRoot\sample.txt

[Int]$joltage = 0

ForEach($bank in $instructions) {
    Write-host $bank
    $batteries = New-Object -TypeName System.Collections.Generic.SortedSet[Int]
    For($posA = 0; $posA -lt $bank.Length; $posA++) {
        For($posB = $posA + 1; $posB -lt $bank.Length; $posB++) {
            $batteries.Add("$($bank[$posA])$($bank[$posB])") | out-Null
        }
    }
    $bankJolts = $batteries.GetEnumerator() | Select-Object -last 1
    $joltage += $bankJolts
}

$joltage