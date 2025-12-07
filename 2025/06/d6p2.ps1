[CmdLetBinding()]Param()

$inputFile = "$PSScriptRoot\sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$Instructions = Get-Content $inputFile

$rxDigitGroups = [RegEx]::New('(\d{1,})(?: |$)')

[Array]$Arithmetic = $instructions[-1] -split "\s{1,}"

[System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]$Numbers = @()

ForEach($Entry in $Instructions.Where{ $_.TrimStart() -match "\d"}) {
    [System.Collections.Generic.List[Int64]]$Values = $rxDigitGroups.Matches($entry).Value
    $Numbers.Add($Values)
}

[Int64]$Total = 0
For($i = 0; $i -lt $Numbers[0].Count; $i++) {
    $Operation = $Arithmetic[$i]
    $OperationTotal = 0
    $FirstOp = $True #Dirty way to handle multiplication
    ForEach($Entry in $Numbers) {
        If($FirstOp) {
            [Int64]$OperationTotal = $Entry[$i]
            $FirstOp = $False
        } Else {
            Switch($Operation) {
                '+' { $OperationTotal += $Entry[$i] }
                '*' { $OperationTotal *= $Entry[$i] }
            }
        }
    }
    $Total += $OperationTotal
}

Write-Host $Total