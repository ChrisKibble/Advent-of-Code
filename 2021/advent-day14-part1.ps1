Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day14-Input.txt

$template = $dataIn[0]
$ruleList = $dataIn | Select -Skip 2 | ForEach { 
    $str = $_.Substring(0,2)
    $add = $_.Substring(6)
    $newStr = "$($_.Substring(0,1))$add"
    
    @{$str = $newStr}
}

$rxTwoChar = [RegEx]::new("(?i)(?=([A-Z][A-Z]))")

1..10 | % {

    $finds = $rxTwoChar.Matches($template)

    $newTemplate = $finds.ForEach{
        $ruleList.$($_.Groups[1].Value)
    }

    $newTemplate += $template[-1]
    $template = $newTemplate -join ""
}

Write-Host "Template Length: $($template.Length)"

$grp = $template.ToCharArray() | Group-Object | Select Name,Count | Sort-Object Count -Descending

$maxCount = $grp[0].Count
$minCount = $grp[-1].Count

$diff = $maxCount - $minCount

Write-Host "Difference from Min to Max is $diff"
