Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day10-Input.txt

$closeTags = @{
    "[" = "]"
    "(" = ")"
    "{" = "}"
    "<" = ">"
}

$scoreChart = @{
    ")" = 3
    "]" = 57
    "}" = 1197
    ">" = 25137
}

$openList = "[({<".ToCharArray()
$score = 0

ForEach($chunk in $dataIn) {

    $closeList = [System.Collections.ArrayList]@()

    # Write-Host "Processing $chunk"

    ForEach($c in $chunk.ToCharArray()) {

        $c = [string]$c

        # Write-Host "Found $c ... " -NoNewline

        if($c -in $openList) {
            # Write-Host "Adding $($closeTags.$c) to CloseList"
            $closeList.Insert(0, $closeTags.$c)
        } else {
            If($closeList[0] -eq $c) {
                # Write-Host "Valid Next Close"
                $closeList.RemoveAt(0)
            } else {
                $score += $scoreChart.$c
                # Write-Host "Not Valid Next Close!! $c is an illegal character."
                break
            }
            
        }

    }

    # Write-Host ""

}

$score | Out-Host