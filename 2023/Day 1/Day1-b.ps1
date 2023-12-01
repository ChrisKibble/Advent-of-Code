Clear-Host
Write-Host "*** START ***"
Function WordsToNumbers {
    [CmdLetBinding()]
    Param(
        [String]$entry
    )

    Write-Verbose "          Starting WordsToNumbers with Input '$entry'"

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

    ## Replace First Word
    $firstWordToReplace = $numbers.Keys.ForEach{
        [PSCustomObject]@{
            Word = $_
            Position = $entry.IndexOf($_)
        }
    } | Where-Object { $_.Position -ge 0 } | Sort-Object Position | Select-Object -First 1 -ExpandProperty Word
 
    if($FirstWordToReplace) {
        $NumberValue = $numbers.$FirstWordToReplace
        
        Write-Verbose "               Replace $FirstWordToReplace with $NumberValue"
        [RegEx]$Replacement = $FirstWordToReplace
        $entry = $Replacement.Replace($entry, $NumberValue, 1)
        Write-Verbose "               Entry is now: $entry"
    }

    ## Replace Last Word
    $LastWordToReplace = $numbers.Keys.ForEach{
        [PSCustomObject]@{
            Word = $_
            Position = $entry.IndexOf($_)
        }
    } | Where-Object { $_.Position -ge 0 } | Sort-Object Position | Select-Object -Last 1 -ExpandProperty Word
    
    If($LastWordToReplace) {
        $rtl = [Text.RegularExpressions.RegexOptions]::RightToLeft
        $NumberValue = $numbers.$LastWordToReplace
        Write-Verbose "               Replace $LastWordToReplace with $NumberValue"
        $entry = [RegEx]::Replace($entry, $LastWordToReplace, $NumberValue, $rtl)
    }

    Write-Verbose "               Final Entry: $entry"
    $entry
}

Function Calibrate {
    [CmdLetBinding()]
    Param(
        [String[]]$document
    )

    Write-Verbose "Starting Calibrate"

    $rxFirstNumber = [RegEx]::New('(?m)^(?:.*?)(\d)') 
    $rxLastNumber = [RegEx]::New('(?m)(?:.*)(\d)')
    
    $outputNumbers = ForEach($line in $document) {
        
        $start = $line

        Write-Verbose "     Processing $line. Converting Words."
        $line = WordsToNumbers $line
        Write-Verbose "     Updated Entry is $line"
        
        $firstNum = $rxFirstNumber.Match($line).Groups[1].Value
        $lastNum = $rxLastNumber.Match($line).Groups[1].Value
        
        $finalNumber = [Int]"$firstNum$lastNum"

        Write-Verbose "     Final Number: $firstNum$lastNum"
        $finalNumber
    }

    ($outputNumbers | Measure-Object -Sum).Sum

}

[String[]]$sampleData = Get-Content .\input-a.txt

Calibrate $SampleData -Verbose

# $test = 'one59twoeightwox'
# WordsToNumbers $test -Verbose


### Not 53412
