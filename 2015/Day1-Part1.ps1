$data = Get-Content $PSScriptRoot\Day1-Input.txt

$up = $data.ToCharArray().Where{$_ -eq "("}.count
$down = $data.ToCharArray().Where{$_ -eq ")"}.count

$result = $up - $down

$result
