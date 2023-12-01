Clear-Host

Function Convert-WordToNumber {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Word
    )

    Write-Verbose "      Starting Convert-WordToNumber with Input '$word'"

    $numbers = @{
        "one" = "1"
        "two" = "2"
        "three" = "3"
        "four" = "4"
        "five" = "5"
        "six" = "6"
        "seven" = "7"
        "eight" = "8"
        "nine" = "9"
    }

    if($numbers.$word) {
        Return $numbers.$word
    } Else {
        Return $Word
    }

}

Function Calibrate {
    [CmdLetBinding()]
    Param(
        [String[]]$document
    )

    Write-Verbose "Starting Calibrate"

    $rxNumbers = [RegEx]::New('(?=(\d|one|two|three|four|five|six|seven|eight|nine))')

    $allNumbers = ForEach($line in $document) {
        Write-Verbose "  Searching $line for numbers..."
        $numberList = $rxNumbers.Matches($line)
        $leftNumber = Convert-WordToNumber $numberList[0].Groups[1].Value
        $rightNumber = Convert-WordToNumber $numberList[-1].Groups[1].Value
        [Int]$finalNumber = "$leftNumber$rightNumber"
        Write-Verbose "    Left Number = $LeftNumber"
        Write-Verbose "    Right Number = $RightNumber"
        Write-Verbose "    Final Number = $FinalNumber"
        $FinalNumber
    }

    ($allNumbers | Measure-Object -Sum).Sum
    
}

#[String[]]$sampleData = Get-Content .\input-b.txt
#Calibrate $SampleData

[String[]]$fullDataSet = Get-Content .\input-a.txt
Calibrate $fullDataSet


