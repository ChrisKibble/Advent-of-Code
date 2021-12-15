$input = get-content $PSScriptRoot\Day03-Input.txt

[string]$g = [string]$e = ""
$bit = [String[]]::New($input[0].Length)

$input.ForEach{
    For($i = 0; $i -lt $_.length; $i++) {
        $bit[$i] += [char]$_[$i]
    }
}

$bit.ForEach{
    [int]$zero = $_.ToCharArray().where{$_ -eq "0"}.count
    [int]$one = $_.ToCharArray().where{$_ -eq "1"}.count

    If($zero -gt $one) {
        $g += "0"
        $e += "1"
    } elseif ($one -gt $zero) {
        $g += "1"
        $e += "0"
    }
}

$gamma = [Convert]::ToInt32($g,2)
$epsilon = [Convert]::ToInt32($e,2)

Write-Host "Gamma: $g $gamma"
Write-Host "Epsilon: $e $epsilon"

Write-Host "Power = $($gamma * $epsilon)"
