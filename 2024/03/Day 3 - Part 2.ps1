#$Memory = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
$Memory = Get-Content "$PSScriptRoot\Day 3 - Input.txt"

$rxFindDigits = [RegEx]::New("mul\((\d{1,}),(\d{1,})\)|don't\(\)|do\(\)")

[Int]$Sum = 0
$mul = $True

$rxFindDigits.Matches($Memory) | ForEach-Object {
    If($_.Value -like "mul*" -and $mul) {
        [Int]$num1 = $_.Groups[1].Value
        [Int]$num2 = $_.Groups[2].Value
        $sum += ($num1 * $num2)    
    }
    If($_.Value -eq "don't()") { $mul = $false }
    If($_.Value -eq "do()") { $mul = $true }    
}

$sum
