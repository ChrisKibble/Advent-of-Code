Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
qjhvhtzxzqqjkmpb
xxyxx
uurcxstgmygtbstg
ieodomkazucvgmuy
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day5-Input.txt

$nice = 0

$dblLetter = [RegEx]::New("([a-z][a-z]).*\1")
$skipLetter = [RegEx]::New("([a-z]).\1")

$dataIn.ForEach{

    [string]$s = $_

    If($dblLetter.Matches($s).Count -gt 0 -and $skipLetter.Matches($s).Count -gt 0) {
        $nice++
    }

}

Write-Host "There are $nice nice strings."