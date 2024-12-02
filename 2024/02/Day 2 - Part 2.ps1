Set-StrictMode -Version 2

$sample = @"
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"@ -split "`r?`n"

Function Get-ReportSafety {
    [CmdLetBinding()]
    Param(
        [String]$ReportLevels,
        [Boolean]$SecondAttempt = $False
    )

    [System.Collections.Generic.List[Int]]$Levels = $ReportLevels -split ' '
    $LevelsFromReport = $Levels.ToArray()

    If(-Not($SecondAttempt)) { Write-Verbose "---" }
    Write-Verbose "Processing $ReportLevels$(If($SecondAttempt) { " (Second Attempt)"})"

    # Reports with duplicate numbers aren't safe because if they are increasing/decreasing there can't be two of the same.
    [Array]$duplicates = $levels | Group-Object | Where-Object { $_.Count -gt 1 }
    If($duplicates) {
        Write-Verbose "This report contains a duplicate number and can't be safe."
        If(-Not($SecondAttempt) -and $duplicates.count -eq 1 -and $duplicates.group.count -eq 2) {
            Write-Verbose "MULLIGAN!"
            
            # Remove the duplicate number and run it through again. Only if there's only one duplicate (else it'll just fail again anyway).
            [System.Collections.Generic.List[String]]$Candidates = @()

            [System.Collections.Generic.List[Int]]$LevelsWithoutFirstDupe = @($Levels)
            $LevelsWithoutFirstDupe.RemoveAt($LevelsWithoutFirstDupe.IndexOf($Duplicates.Name))

            [System.Collections.Generic.List[Int]]$LevelsWithoutSecondDupe = @($Levels)
            $LevelsWithoutSecondDupe.RemoveAt($LevelsWithoutSecondDupe.LastIndexOf($Duplicates.Name))

            $Candidates.Add($LevelsWithoutFirstDupe -join ' ')
            $Candidates.Add($LevelsWithoutSecondDupe -join ' ')

            ForEach($Candidate in $Candidates) {
                $ValidReport = Get-ReportSafety -ReportLevels $Candidate -SecondAttempt $True
                If($ValidReport) {
                    Return $True
                }
            }

        } Else {
            If(-Not($SecondAttempt)) { Write-Verbose "There are too many duplicates to MULLIGAN."}
            Return $False
        }
    }
    
    $Levels.Sort()
    $LevelsAsc = $Levels.ToArray()

    $AscDescTest = $True

    # If the list is ascending, it should match it's ascending sort.
    [Array]$ascCompare = Compare-Object $LevelsAsc $LevelsFromReport -SyncWindow 0 -PassThru
    If($ascCompare -gt 0) {
        # The list is not in ascending order. Check for decending.
        $Levels.Reverse()
        $LevelsDesc = $Levels.ToArray()
        [Array]$descCompare = Compare-Object $LevelsDesc $LevelsFromReport -SyncWindow 0 -PassThru
        If($descCompare -gt 0) {
            # The list is not in decending order. Fail the report.
            Write-Verbose "Report is neither ascending or decending."
            $AscDescTest = $False
        }            
    }

    If(-Not($AscDescTest)) {
        # Failed the Ascending/Descending Test.
        If(-Not($SecondAttempt)) {
            Write-Verbose "MULLIGAN!"

            [System.Collections.Generic.List[String]]$Candidates = @()
            For($i = 1; $i -le $LevelsFromReport.Count - 2; $i++) {
                $ToTheLeft = $LevelsFromReport[$i-1]
                $ToTheRight = $LevelsFromReport[$i+1]
                $ThisLevel = $LevelsFromReport[$i]
                If(($ToTheLeft -lt $ThisLevel -and $ToTheRight -lt $ThisLevel) -or ($ToTheLeft -gt $ThisLevel -and $ToTheRight -gt $ThisLevel)) {
                    # Yeah, this is a silly way to go about this...
                    [System.Collections.Generic.List[String]]$NewCandidate = $LevelsFromReport
                    $NewCandidate.RemoveAt($i)
                    Write-Verbose "This is a candidate for a potential replacement: $($NewCandidate -join ' ')"
                    $Candidates.Add($NewCandidate -join ' ')
                }
            }

            # Also include removing the first
            $Candidates.Add($($LevelsFromReport[1..$($LevelsFromReport.Count)] -join ' '))

            # Also include removing the last
            $Candidates.Add($($LevelsFromReport[0..$($LevelsFromReport.Count-2)] -join ' '))
            
            ForEach($Candidate in $Candidates) {
                $ValidReport = Get-ReportSafety -ReportLevels $Candidate -SecondAttempt $True
                If($ValidReport) {
                    Return $True
                }
            }
        }
        Return $False
    }

    # Each level must be <= 3 from the level next to it (we don't need to worry about looking for zero since they were excluded with the dupe check).
    # Start with a list where we're certain of the order by sorting it again.
    $Levels.Sort()

    For([Int]$i = 0; $i -lt $Levels.count - 1; $i++) {
        If($Levels[$i+1] - $Levels[$i] -gt 3) {
            Write-Verbose "Fails difference test ($($Levels[$i]) and $($Levels[$i+1]))."
            If(-Not($SecondAttempt)) {
                Write-Verbose "MULLIGAN!"
                If($i -gt 0 -and $i -lt $levels.count-2) {
                    Write-Verbose "We are at $i"
                    Write-Verbose "Fails - No reason to check first or last since that's not where the issue is."
                    Return $False
                }    
                [System.Collections.Generic.List[String]]$Candidates = @()
                # Remove the first number
                $Candidates.Add($($LevelsFromReport[1..$($LevelsFromReport.Count)] -join ' '))

                # Remove the last number
                $Candidates.Add($($LevelsFromReport[0..$($LevelsFromReport.Count-2)] -join ' '))

                ForEach($Candidate in $Candidates) {
                    $ValidReport = Get-ReportSafety -ReportLevels $Candidate -SecondAttempt $True
                    If($ValidReport) {
                        Return $True
                    }
                }    
            }
            Return $False
        }
    }

    Write-Verbose "All tests have passed! :)"
    Return $True
}

$Report = Get-Content "$PSScriptRoot\Day 2 - Input.txt"
# $Report = $sample

$SafeReports = 0

ForEach($ReportEntry in $Report) {
    If(Get-ReportSafety -ReportLevels $ReportEntry) { $SafeReports++ }
}

Write-Output "There are $SafeReports Safe Reports!"