[CmdLetBinding()]Param()

# $inputFile = "$PSScriptRoot\sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$instructions = Get-Content $inputFile

[System.Collections.Generic.List[Object]]$FreshFoodRanges = @()
[System.Collections.Generic.List[String]]$Ingredients = @()

ForEach($line in $instructions) {
    if($line -like "*-*") {
        [Int64]$RangeMin, [Int64]$RangeMax = $line -split '-'
        $FreshFoodRanges.Add(
            [PSCustomObject]@{
                RangeMin = $RangeMin
                RangeMax = $RangeMax
            }
        )
    } ElseIf($line -match "\d{1,}") {
        $Ingredients.Add($line)
    }
}

[Int]$FreshIngredient = 0

ForEach($item in $Ingredients) {
    if($FreshFoodRanges.Where({ $_.RangeMin -le $Item -and $_.RangeMax -ge $Item},'first')) {
        $FreshIngredient++
    }
}

$FreshIngredient