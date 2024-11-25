$sample = @"
""
"abc"
"aaa\"aaa"
"\x27"
"@ -split "`r`n"

$sample = Get-Content $PSScriptRoot\Day8-Input.txt

$replacements = @('\\x[0-9a-f]{2}', '\\\\', '\\"')

$TotalChars = $sample.ToCharArray().Where{ $_ -notin @("`r","`n") }.Count
$CharCount = 0

ForEach($line in $sample) {
    $line = $line.Substring(1,$line.Length-2)
    $replacements.ForEach{
        $line = [RegEx]::Replace($line, $_, '#')
    }
    $charCount += $line.Length
}

Write-Host "$TotalChars - $CharCount = $($TotalChars - $CharCount)"
