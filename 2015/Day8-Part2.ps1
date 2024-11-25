$sample = @"
""
"abc"
"aaa\"aaa"
"\x27"
"@ -split "`r`n"

$sample = Get-Content $PSScriptRoot\Day8-Input.txt

$replacements = @('"')

$TotalChars = $sample.ToCharArray().Where{ $_ -notin @("`r","`n") }.Count
$CharCount = 0

ForEach($line in $sample) {
    $replacements.ForEach{
        $line = $line -replace '\\', '\\'
        $line = $line -replace '"','\"'
    }
    $line = "`"$line`""
    $charCount += $line.Length
    $line
}

Write-Host "$CharCount - $TotalChars = $($CharCount - $TotalChars)"
