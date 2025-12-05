[CmdLetBinding()]Param()

$instructions = Get-Content $PSScriptRoot\input.txt
# $instructions = Get-Content $PSScriptRoot\sample.txt

$batterySize = 12

[Int64]$Joltage = 0

ForEach($Bank in $Instructions) {

    [String]$NewBattery = ""

    Do {
        Write-Verbose "Input is $Bank"
        $RemainingSpaces = $($batterySize - $NewBattery.Length)
        Write-Verbose "I have $RemainingSpaces spots left to fill."
        $startingPositionMax = $Bank.length - $RemainingSpaces + 1
        Write-Verbose "TL: $($Bank.Length) | BS = $BatterySize | NBL = $($NewBattery.Length) | SPM = $StartingPositionMax"
        Write-Verbose "Next number has to be one of the first $startingPositionMax characters"

        If($startingPositionMax -eq 0) {
            # Remaining Numbers can now just be appended.
            Write-Verbose "Appending Bank Value to New Battery (SPM = 0)"
            $NewBattery += $Bank
        } Else {
            [String]$Value = $Bank[0..$($startingPositionMax-1)] | ForEach-Object { [Int]"$_" } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
            $NewBattery += $Value

            [Int]$ValuePosition = $Bank.IndexOf($Value)

            Write-Verbose "Next Number is $value in position $ValuePosition"
            $Bank = $Bank.Substring($ValuePosition+1)
            Write-Verbose "New Input is $Bank, NewBattery = $NewBattery"
            
        }
        Write-Verbose "-"
        
    } Until($NewBattery.Length -eq $BatterySize)

    $joltage += [Convert]::ToInt64($NewBattery)
}

$Joltage