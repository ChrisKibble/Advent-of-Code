Clear-Host

Function Calibrate {
    Param(
        [String[]]$document
    )

    $rxFirstNumber = [RegEx]::New('(?m)^(?:.*?)(\d)') 
    $rxLastNumber = [RegEx]::New('(?m)(?:.*)(\d)')
    
    $outputNumbers = ForEach($line in $document) {
        $firstNum = $rxFirstNumber.Match($line).Groups[1].Value
        $lastNum = $rxLastNumber.Match($line).Groups[1].Value
        [Int]"$firstNum$lastNum"
    }

    ($outputNumbers | Measure-Object -Sum).Sum

}

[String[]]$sampleData = Get-Content .\input-a.txt

Calibrate $SampleData