$sample = @"
3   4
4   3
2   5
1   3
3   9
3   3
"@ -split "`r?`n"

Function Get-Lists {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String[]]$Data
    )

    # Find all digits with 1+ spaces between them or that end the line.
    $rxDigits = [RegEx]::new('(?ms)\d{1,}(?= *?|$)')

    # Determine how many lists to create
    $listCount = $rxDigits.Matches($Data[0]).Count

    # Create a list to hold our lists
    $lists = [PSCustomObject]@{}

    # Create a new list for each input list
    For($i = 0; $i -lt $listCount; $i++) {
        Add-Member -InputObject $lists -MemberType NoteProperty -Name "List$i" -Value $(New-Object System.Collections.Generic.List[Int])
    }

    # Loop over the data and add the numbers to the list
    ForEach($entry in $data) {
        $digits = $rxDigits.Matches($entry)
        For($i = 0; $i -lt $listCount; $i++) {
            $lists.$("List$i").Add($digits[$i].Value)
        }
    }

    # Sort the list
    For($i = 0; $i -lt $listCount; $i++) {
        $lists.$("List$i").Sort()
    }

    # Return the list
    Return $lists

}

Function Get-ListDiffs {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [PSCustomObject]$Lists
    )

    $NumberOfLists = ($lists | Get-Member | Where-Object { $_.MemberType -eq "NoteProperty" }).count
    $NumberOfItems = $Lists.List0.Count

    $totalDiff = 0

    For($EntryId = 0; $entryId -lt $NumberOfItems; $EntryId++) {
        $diff = $Lists.List0[$EntryId]
        For($listId = 1; $listId -lt $NumberOfLists; $listId++) {
            $Value = $Lists.$("List$listId")[$EntryId]
            $diff = $diff - $Value
        }
        $diff = [Math]::Abs($Diff)
        $totalDiff += $diff
    }

    $TotalDiff
}

# $Lists = Get-Lists $sample
$Lists = Get-Lists (Get-Content "$PSScriptRoot\Day 1 - Input.txt")
$TotalDiff = Get-ListDiffs $lists

Write-Output "It's $TotalDiff !"
