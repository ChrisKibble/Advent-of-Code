Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = @"
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"@ -split "`r`n"

$dataIn = Get-Content $PSScriptRoot\Day13-Input.txt

$points = $dataIn.where{ $_ -match "\d{1,},\d{1,}" }.ForEach{  
    $m = [RegEx]::Matches($_, "(\d{1,}),(\d{1,})")
    [PSCustomObject]@{ "X"=[Int]$m.groups[1].Value; "Y"=[Int]$m.groups[2].value; NewX = $null; NewY = $null }
}

# Expecting Part 2 to need me to complete all of them, so writing to be easily changed later.
[RegEx]::Matches($dataIn, "fold along (.)=(\d{1,})")[0].ForEach{
    
    $axis = $_.Groups[1].Value
    $lineNum = $_.Groups[2].Value

    if($axis -eq "y") {
        $points.where{ $_.y -gt $lineNum }.ForEach{
            $newY = $_.y-(($_.y-$lineNum)*2)
            $_.y = $newY
        }
    } elseif($axis -eq "x") {
        $points.where{ $_.x -gt $lineNum }.ForEach{
            $newX = $_.x-(($_.x-$lineNum)*2)
            $_.x = $newX
        }
    }

}

#$points | Sort Y | FT -AutoSize

Write-Host $($points | Group-Object X,Y).count