[CmdLetBinding()]Param()

# $instructions = Get-Content $PSScriptRoot\sample.txt
$instructions = Get-Content $PSScriptRoot\input.txt

### Determine the possible lengths that we need to care about ###

<# TESTING #>

<# TESTING #>

$IdLengths = $instructions -split ',' | ForEach-Object {
    $First, $Second = $_ -split '-'
    $First.ToString().Length
    $Second.ToString().Length
}

$minLength = $IdLengths | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
$maxLength = $IdLengths | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

$valueStart = [Convert]::ToInt64("1$("0" * $($minLength/2-1))")
$valueEnd = [Convert]::ToInt64("9" * $($maxLength/2))

# Create every possible duplicate for the given input range.
[System.Collections.Generic.HashSet[Int64]]$DupeList = For($i = $valueStart; $i -le $valueEnd; $i++) { 
    $repeatCount = 2
    Do {
        $possibleDuplicate = [Convert]::ToInt64("$i" * $repeatCount)
        if($possibleDuplicate.ToString().Length -le $maxLength) {
            $possibleDuplicate
        }
        $repeatCount++
    } Until($possibleDuplicate.ToString().Length -gt $maxLength)
}

# Check our inputs against the dupelist.

$InputDuplicates = ForEach($idRange in $($Instructions -split ',')) {
    $RangeStart, $RangeEnd = $idRange -split '-'
    $DupeList.Where{ $_ -ge $RangeStart -and $_ -le $RangeEnd }
}

$InputDuplicates | Measure-Object -Sum | Select-Object -ExpandProperty Sum