[CmdLetBinding()]Param()

$inputFile = "$PSScriptRoot\sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$Instructions = Get-Content $inputFile

$Map = [RegEx]::Matches($instructions[-1], '((?:\*|\+)\s{1,})') | Select-Object `
    @{Name='StartIndex';Expression={$_.Index}}, `
    @{Name='EndIndex';Expression={$_.Index + $_.Length - 2}}, `
    @{Name='Operation';Expression={$_.Value.Trim()}}


[System.Collections.Generic.List[String]]$Numbers = @()

$RightMargin = -1
ForEach($Entry in $Instructions.Where{ $_.TrimStart() -match "\d"}) {
    $Numbers.Add($Entry)
    $RightMargin = [Math]::Max($RightMargin, $Entry.Length)
}

# The arithmetic line doesn't have padding on the end so we need to make sure the final
# map entry goes out all the way to the rightmost character of any line.
$map[-1].EndIndex = $RightMargin - 1

[Int64]$GrandTotal = 0

ForEach($group in $map) {
    [System.Collections.Generic.List[String]]$GroupNumberList = @()
    For($i = $group.StartIndex; $i -le $group.EndIndex; $i++) {
        Write-Verbose "Processing Group Column $i"
        [String]$ThisNumber = '' 
        ForEach($Entry in $Numbers) {
            $ThisDigit = $Entry[$i]
            If($ThisDigit -and $ThisDigit -ne ' ') {
                $ThisNumber += $ThisDigit
            }
        }
        $GroupNumberList.Add($ThisNumber)
    }

    Write-Verbose "Done with Group"

    Switch ($group.Operation) {
        '*' {
            [Int64]$Total = 1
            ForEach($i in $GroupNumberList) {
                $Total *= [Int]$i
            }
        }
        '+' {
            [Int64]$Total = 0
            ForEach($i in $GroupNumberList) {
                $Total += [Int]$i
            }
        }        
    }

    Write-Verbose "T = $Total"
    $GrandTotal += $Total
}

$GrandTotal