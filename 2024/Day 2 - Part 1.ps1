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
        [String]$ReportLevels
    )

    [System.Collections.Generic.List[Int]]$Levels = $ReportLevels -split ' '

    Write-Verbose "Processing $ReportLevels"

    # Reports with duplicate numbers aren't safe because if they are increasing/decreasing there can't be two of the same.
    If($levels | Group-Object | Where-Object { $_.Count -gt 1 }) {
        Write-Verbose "This report contains a duplicate number and can't be safe."
        Return $False
    }
    
    $LevelsFromReport = $Levels.ToArray()

    $Levels.Sort()
    $LevelsAsc = $Levels.ToArray()

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
            Return $False
        }            
    }

    # Each level must be <= 3 from the level next to it (we don't need to worry about looking for zero since they were excluded with the dupe check).
    # Start with a list where we're certain of the order by sorting it again.
    $Levels.Sort()

    For([Int]$i = 0; $i -lt $Levels.count - 1; $i++) {
        If($Levels[$i+1] - $Levels[$i] -gt 3) {
            Write-Verbose "Fails difference test ($($Levels[$i]) and $($Levels[$i+1]))."
            Return $False
        }
    }

    Return $True
}

$Report = Get-Content "$PSScriptRoot\Day 2 - Input.txt"
# $Report = $sample

$SafeReports = 0
ForEach($ReportEntry in $Report) {
    If(Get-ReportSafety -ReportLevels $ReportEntry) { $SafeReports++ }
}

Write-Output "There are $SafeReports Safe Reports!"