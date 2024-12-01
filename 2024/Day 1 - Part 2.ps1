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

    # Do Not Sort the list for Part II
    #For($i = 0; $i -lt $listCount; $i++) {
        #$lists.$("List$i").Sort()
    #}

    # Return the list
    Return $lists

}

Function Get-SimilarityScore {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [System.Collections.Generic.List[Int]]$ListLeft,

        [Parameter(Mandatory=$True)]
        [System.Collections.Generic.List[Int]]$ListRight
    )


    # Find numbers not on the right side
    [Int[]]$LeftOnlyNumbers = Compare-Object $listleft $listright | Where-Object { $_.SideIndicator -eq "<=" } | Select-Object -ExpandProperty InputObject

    $ListLeft.RemoveAll({Param ($x); $x -in $LeftOnlyNumbers }) | Out-Null

    [Int]$Score = 0
    Do {
        # Get the next entry in the list
        $Entry = $ListLeft[0]
        If($Entry) {
            # How many times is this in the left
            $LeftCount = $($ListLeft.Where{ $_ -eq $Entry }).Count

            # How many times is this in the right
            $RightCount = $($ListRight.Where{ $_ -eq $Entry }).Count

            # Use the AoC rules to calculate the score
            $Similarity = $Entry * $LeftCount * $RightCount

            # Remove all copies of this number from the left list.
            $ListLeft.RemoveAll({Param($x); $x -eq $Entry}) | Out-Null
            
            # Add it up.
            $Score += $Similarity
        }
    }Until(-Not($entry))

    $Score

}

# $Lists = Get-Lists $sample
$Lists = Get-Lists (Get-Content "$PSScriptRoot\Day 1 - Input.txt")

$Score = Get-SimilarityScore -ListLeft $lists.List0 -ListRight $lists.List1

Write-Output "It's $Score !"
