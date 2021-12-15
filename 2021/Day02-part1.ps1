$input = Get-Content C:\temp\input.txt

$horizontal = 0
$depth = 0 

ForEach($cmd in $input) {
    
    $cmdName = $cmd.substring(0,$cmd.indexof(' '))
    $cmdNum = [int]$cmd.Substring($cmd.indexof(' ')+1)

    Switch($cmdName) {
        "forward" { $horizontal += $cmdNum; }
        "up" { $depth -= $cmdNum; }
        "down" { $depth += $cmdNum; }
        default { throw $cmdName }
    }

}

$horizontal * $depth
