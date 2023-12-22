Clear-Host
Get-Date
Write-Host "---"

Function Get-Permutations {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Int]$StringLength
    )

    Write-Verbose "I need to generate all combinations for $StringLength."

    If($global:savedPerms[$StringLength]) {
        Write-Verbose "Returning from Cache"
        Return $global:savedPerms[$StringLength]
    }

    [String]$binaryString = "1" * $StringLength

    [Int64]$BinaryAsInt = [System.Convert]::ToInt64($binaryString,2)

    $permutations = For($index = 0; $index -le $BinaryAsInt; $index++) {
        $binaryString = [System.Convert]::ToString($index, 2).PadLeft($StringLength,'0')
        $binaryString -replace '0','.' -replace '1','#'
    }
    
    Write-Verbose "Returning"
    Return $permutations

}

Function Get-Arrangements {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Record
    )
   
    $rxCharacterGroups = [RegEx]::New('(\?{1,}|\.{1,}|#{1,})')
    $rxCharacterGroups = [RegEx]::New('(#{1,})')
    $rxQuestionMarks = [RegEx]::New('\?')

    $RecordData = $Record.Substring(0,$Record.IndexOf(' '))
    $RecordCounts = $Record.Substring($RecordData.Length+1) -split ','
    $NumberOfGroups = $RecordCounts.Count
    
    [Array]$Unknowns = $rxQuestionMarks.Matches($RecordData) | Select-Object -ExpandProperty Index    
    $UnknownCount = $Unknowns.Count

    Write-Verbose "Processing $Record"
    Write-Verbose "  Data: [$RecordData]"
    Write-Verbose "  Counts: [$($RecordCounts -join ',')] - $NumberOfGroups Groups"
    Write-Verbose "  Unknowns: [$($Unknowns -join ',')] - $UnknownCount Unknowns"

    if($null -ne $global:savedPerms[$UnknownCount]) {
        Write-Verbose "  We already have these permutations saved in cache."
    } Else {
        $HighestPerm = $global:savedPerms.GetEnumerator() | Select-Object -ExpandProperty Name | Where-Object { $_ -gt $UnknownCount } | Sort-Object | Select-Object -First 1
        Write-Verbose "  Getting Permutations for $UnknownCount from $HighestPerm"
        $global:savedPerms[$UnknownCount] = $global:savedPerms[$HighestPerm].ForEach{
            $_.Substring(0,$UnknownCount)
        }
        Write-Verbose "    Making Unique"
        $global:savedPerms[$UnknownCount] = $global:savedPerms[$UnknownCount] | Sort-Object -Unique
    }

    $thisPermutationGroup = $global:savedPerms[$UnknownCount]

    Write-Verbose "  Getting List of Possible Values"
    $PossibleValues = ForEach($test in $thisPermutationGroup) {
        $testValue = $RecordData
        For($index = 0; $index -lt $UnknownCount; $index++) {
            $indexToReplace = $Unknowns[$index]
            $replacementChar = $test[$index]
            $testValue = $testValue.Remove($indexToReplace,1).Insert($indexToReplace,$replacementChar)
        }

        [Array]$hashGroups = $rxCharacterGroups.Matches($testValue)
        If($hashGroups.Count -eq $NumberOfGroups) {
            # Number of hash groups matches the number we're looking for
            $ConfirmedMatch = $True
            For($index = 0; $index -lt $hashGroups.count; $index++) {
                If($RecordCounts[$index] -ne $hashGroups[$index].Length) {
                    $ConfirmedMatch = $False
                    break
                }
            }
            If($ConfirmedMatch) { 
                $testValue
            }
        }
    }

    Write-Verbose "Found $($PossibleValues.Count) Possible Values"

    Return $PossibleValues.Count

}

$logs = Get-Content $PSScriptRoot\Input.txt

$lineUnknowns = $logs.ForEach{ 
    ($_.ToCharArray().Where{ $_ -eq '?' }).Count
}

[Int]$lineUnknownsMax = $lineUnknowns | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

If(-Not($global:savedPerms)) { $global:savedPerms = @{} }

$global:savedPerms[$lineUnknownsMax] = Get-Permutations -StringLength $lineUnknownsMax -Verbose

# Go through the input file backwards by question mark count to generate the secondary permutations faster.

$logData = $logs.ForEach{
    [PSCustomObject]@{
        Line = $_
        Questions = ($_.ToCharArray().Where{ $_ -eq '?' }).Count
    }
}

$i = 0
[Int]$sum = 0
$logdata | Sort-Object Questions -Descending | ForEach-Object {
    $i++
    Write-Host $i
    $count = Get-Arrangements $_.Line -Verbose  
    $sum += $count
}

Write-Output $sum


