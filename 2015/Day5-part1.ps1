Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
ugknbfddgicrmopn
aaa
jchzalrnumimnmhp
haegwjzuvuyypxyu
dvszwmarrgswjxmb
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day5-Input.txt

$nice = 0

$vowels = [RegEx]::new("(?i)[aeiou]")
$dblLetter = [RegEx]::New("(.)\1+")
$badGroups = [RegEx]::New("(?i)(ab|cd|pq|xy)")

$dataIn.ForEach{

    [string]$s = $_

    If($vowels.Matches($s).count -ge 3 -and $dblLetter.Matches($s).Count -ge 1 -and $badGroups.Matches($s).Count -eq 0) {
        # Write-Host "NICE!"
        $nice++
    } else {
        # Write-Host "NAUGHTY!"
    }


}

Write-Host "There are $nice nice strings."