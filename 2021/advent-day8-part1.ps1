Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = Get-Content $PSScriptRoot\Day8-Input.txt

# Easier to visualize this way, not really necessary
$allData = ForEach($systemOutput in $dataIn) {
   
    $signalPatterns = $systemOutput.Substring(0,$systemOutput.IndexOf("|")-1)
    $outputValue = $systemOutput.Substring($signalPatterns.Length+3)

    $newPattern = $signalPatterns -split " " | ForEach-Object {
        $($_.ToCharArray() | Sort-Object) -join ""
    }

    $newOutput = $outputValue -split " " | ForEach-Object {
        $($_.ToCharArray() | Sort-Object) -join ""
    }
    
    [PSCustomObject]@{
        "SystemOutput" = $systemOutput
        "SignalPatterns" = $newPattern
        "OutputValue" = $newOutput
    }
}

$numCount = 0

ForEach($ov in $allData.Outputvalue) {
    # 1 4 7 8
    If($ov.Length -in (2, 4, 3, 7)) { 
        $numCount ++ 
    }
}

$numCount
