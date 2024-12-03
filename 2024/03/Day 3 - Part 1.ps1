# $Memory = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
$Memory = Get-Content "$PSScriptRoot\Day 3 - Input.txt"

$rxFindDigits = [RegEx]::New('mul\((\d{1,}),(\d{1,})\)')

[Int]$Sum = 0
$rxFindDigits.Matches($Memory) | ForEach-Object {
    [Int]$num1 = $_.Groups[1].Value
    [Int]$num2 = $_.Groups[2].Value
    $sum += ($num1 * $num2)
}

$sum
