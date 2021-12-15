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

[RegEx]::Matches($dataIn, "fold along (.)=(\d{1,})").ForEach{
    
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

[int]$width = $($points.X | Measure-Object -Maximum).Maximum
[int]$height = $($points.Y | Measure-Object -Maximum).Maximum

For($y = 0; $y -le $height; $y++) {
    For($x = 0; $x -le $width; $x++) {
        if($points.where({ $_.x -eq $x -and $_.y -eq $y},'first')) { Write-Host "#" -NoNewline } else { Write-Host " " -NoNewline }
    }
    Write-Host ""
}