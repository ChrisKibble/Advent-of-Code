Clear-Host
Get-Date
Write-Host "---"
Function PermutateArrays {

    [CmdLetBinding()]
    Param(
        $PermuteLeft,
        $PermuteRight
    )

    [System.Collections.Generic.List[String]]$FullArray = ForEach($l in $permuteLeft) {
        ForEach($r in $permuteRight) {
            "$l$r"
        }
    }

    Return $FullArray

}
Function Get-Permutations {

    [CmdLetBinding()]
    Param(
        [Int]$NumberOfUnknowns
    )

    Write-Verbose "[$(Get-Date)] [Starting] Getting Permutations for $NumberOfUnknowns"

    $global:savedPerms[1] = @('.#','#.')

    If($global:savedPerm.$NumberOfUnknowns) {
        Write-Verbose "[$(Get-Date)] Returning from Cache`r`n"
        Return $global:savedPerms[$NumberOfUnknowns]
    }

    Write-Verbose "[$(Get-Date)] This value isn't yet cached."

    $loopCount = 0
    While(-not($global:savedPerms[$NumberOfUnknowns])) {
        $loopCount++

        $availablePermutations = $global:savedPerms.GetEnumerator() | Select-Object -ExpandProperty Name
        $firstNumber = $availablePermutations | Where-Object { $_ -le $numberofUnknowns } | Sort-Object | Select -Last 1
        $secondNumber = $availablePermutations | Where-Object { $_ -le ($numberofUnknowns-$firstNumber) } | Sort-Object | Select -last 1
        $newPermutation = $firstNumber + $secondNumber

        Write-Verbose "[$(Get-Date)] Looking for $numberofunknowns. Available Permutations are $($availablePermutations -join ',')"
        Write-Verbose "[$(Get-Date)]   Highest number below $numberofunknowns is $firstNumber (FirstNumber)"
        Write-Verbose "[$(Get-Date)]   Highest number we can add to FirstNumber to get closest to $numberofunknowns is $secondnumber (SecondNumber)"
        Write-Verbose "[$(Get-Date)]   This will give us the permutations for $newPermutation"

        $newPermutation = $firstNumber + $secondNumber
        $NewRange = PermutateArrays $global:savedPerms[$firstNumber] $global:savedPerms[$secondNumber]
        $global:savedPerms[$newPermutation] = $NewRange

        If($loopCount -gt 10) { Throw "Whoops" }
    } 

    Return $global:savedPerms[$NumberOfUnknowns]
}
Function Get-Arrangements {

    [CmdLetBinding()]
    Param(
        [String]$Record
    )

    $rxCharacterGroups = [RegEx]::New('(\?{1,}|\.{1,}|#{1,})')
    $rxQuestionMarks = [RegEx]::New('\?')

    $RecordData = $Record.Substring(0,$Record.IndexOf(' ')-1)
    $RecordCounts = $Record.Substring($RecordData.Length+2) -split ','
    $NumberOfGroups = $RecordCounts.Count
    
    [Array]$Unknowns = $rxQuestionMarks.Matches($RecordData) | Select-Object -ExpandProperty Index    
    $UnknownCount = $Unknowns.Count

    Write-Verbose "Processing $Record"
    Write-Verbose "  Data: [$RecordData]"
    Write-Verbose "  Counts: [$($RecordCounts -join ',')] - $NumberOfGroups Groups"
    Write-Verbose "  Unknowns: [$($Unknowns -join ',')] - $UnknownCount Unknowns"

    $permutations = Get-Permutations -NumberOfUnknowns $UnknownCount

    $permutations | FT | Out-host

    Write-Verbose "  Getting List of Possible Values"
    ForEach($test in $permutations) {
        $testValue = $RecordData
        For($index = 0; $index -lt $UnknownCount; $index++) {
            $indexToReplace = $Unknowns[$index]
            $replacementChar = $test[$index]
            $testValue = $testValue.Remove($indexToReplace,1).Insert($indexToReplace,$replacementChar)
        }
    }

}

$global:savedPerms = @{}

$logs = Get-Content $PSScriptRoot\Input.txt

Get-Arrangements ".??..??...?##. 1,1,3" -Verbose  # 4 different arrangements