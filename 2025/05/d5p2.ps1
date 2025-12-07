[CmdLetBinding()]Param()

# $inputFile = "$PSScriptRoot\sample.txt"
# $inputFile = "$PSScriptRoot\better-sample.txt"
$inputFile = "$PSScriptRoot\input.txt"

$instructions = Get-Content $inputFile

[System.Collections.Generic.List[Object]]$FreshFoodRanges = @()

ForEach($line in $instructions) {
    if($line -match "^\d{1,}-\d{1,}") {
        
        [Int64]$RangeMin, [Int64]$RangeMax = $line -split '-'
        
        $FreshFoodRanges.Add(
            [PSCustomObject]@{
                RangeMin = $RangeMin
                RangeMax = $RangeMax
            }
        )
    }
}

$FreshFoodRanges = $FreshFoodRanges | Sort-Object RangeMin

For($row = 0; $row -lt $FreshFoodRanges.Count; $row++) {
    
    $RangeMin = $FreshFoodRanges[$Row].RangeMin
    $RangeMax = $FreshFoodRanges[$Row].RangeMax

    $NextRange = $FreshFoodRanges[$Row+1]
    $NextMin = $NextRange.RangeMin
    $NextMax = $NextRange.RangeMax

    Write-Verbose "Processing $RangeMin -> $RangeMax (Hint: Next Row is $NextMin -> $NextMax)."

    If($NextRange) {
        # Do I envelop the row below me?
        If($RangeMin -le $NextMin -and $RangeMax -ge $NextMax) {
            Write-Verbose "  I envelop the row below me. I should delete it."
            $FreshFoodRanges.Remove($NextRange) | Out-Null
            Write-Verbose "Rescanning row with continue statement."
            $row--
            continue
        }

        # Is my max greater than the next rows min? If so, reduce my max to one lower than the new rows min.
        If($RangeMax -ge $NextMin) {
            $NewRangeMax = $NextMin - 1
            Write-Verbose "  I need to reduce my max to $($NewRangeMax) because $RangeMax >= $NextMin"
            $FreshFoodRanges[$Row].RangeMax = $NewRangeMax
        }

    }

}

[Int64]$FreshCount = 0

ForEach($range in $FreshFoodRanges) {
    [Int64]$RangeSize = $Range.RangeMax - $Range.RangeMin + 1
    Add-Member -InputObject $Range -MemberType NoteProperty -Name Size -Value $RangeSize
    $FreshCount += $RangeSize
}

$FreshCount