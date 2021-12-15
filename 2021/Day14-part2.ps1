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

$iterationCount = 40

$dataIn = Get-Content $PSScriptRoot\Day14-Input.txt

$template = $($dataIn[0])

$ruleList = $dataIn | Select -Skip 2 | ForEach { 
    $str = $_.Substring(0,2)
    
    $add = $_.Substring(6)
    $newStr = "$($_.Substring(0,1))$add"
    
    $child1 = "$($_.Substring(0,1))$add"
    $child2 = "$add$($_.Substring(1,1))"

    @{
        $str = @($child1, $child2)
    }
}

$rxPairs = [RegEx]::new("(?i)(?=([A-Z][A-Z]))")
$pairs = $rxPairs.Matches($template)

$map = [Ordered]@{}
$pairs.ForEach{
    $thisPair = $_.Groups[1].Value
    # $map.Add($thisPair,1)
    [Void][UInt64]$map.$thisPair++
}

$letters = @{}

# Last letter ends up missing because of the way that pairs break up, start by adding it right in.
$letters.$([string]$template[-1]) = 1


For($i = 1; $i -le $iterationCount; $i++) {

    # Write-Host "---- Iteration #$i -----"
       
    $newMap = @{}

    $map.GetEnumerator().ForEach{     
        
        $str = $_.Name
        $count = $_.Value
        $child1 = $ruleList.$str[0]
        $child2 = $ruleList.$str[1]
        
        # Write-Host "$str spawns $child1 and $child2 (#$j)"
        [UInt64]$newMap.$child1 += $count
        [UInt64]$newMap.$child2 += $count

    }

    $map = $newMap.Clone()
  
}


$map.GetEnumerator().ForEach{
    $ltr = $_.Name.Substring(0,1)
    $letters.$ltr += $_.Value
}

[UInt64]$max = 0
[UInt64]$min = [UInt64]::MaxValue

$letters.GetEnumerator().ForEach{
    $min = [Math]::Min([UInt64]$min, [Uint64]$_.Value)
    $max = [Math]::Max([UInt64]$max, [Uint64]$_.Value)
}

Write-Host "Diff = $($max-$min)"
