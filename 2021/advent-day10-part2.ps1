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
    ")" = 1
    "]" = 2
    "}" = 3
    ">" = 4
}

$openList = "[({<".ToCharArray()
$pointsList = [System.Collections.ArrayList]@()

ForEach($chunk in $dataIn) {

    $closeList = [System.Collections.ArrayList]@()

    #Write-Host "Processing $chunk"
    $chunkGood = $true

    ForEach($c in $chunk.ToCharArray()) {

        $c = [string]$c

        #Write-Host "Found $c ... " -NoNewline

        if($c -in $openList) {
            #Write-Host "Adding $($closeTags.$c) to CloseList"
            $closeList.Insert(0, $closeTags.$c)
        } else {
            If($closeList[0] -eq $c) {
                #Write-Host "Valid Next Close"
                $closeList.RemoveAt(0)
            } else {
                # $score += $scoreChart.$c
                #Write-Host "Not Valid Next Close!! $c is an illegal character."
                $chunkGood = $false
                break
            }
            
        }

    }

    If($chunkGood) { 
        $score = 0
        ForEach($c in $closeList) {
            $pVal = $scoreChart.$c
            # Write-Host "$c is worth $pVal points"
            $score = ($score * 5) + $pVal
        }
        # Write-Host "Total Score for $($closeList -join '') is $score"
        [Void]$PointsList.add($score)
    }

    #Write-Host ""

}

$pointsList | Sort | Select -Skip $($($pointsList.count-1)/2) -First 1