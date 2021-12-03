$dataIn = Get-Content $PSScriptRoot\Day2-Input.txt

$totalRibbon = 0

$rxLWH = [regex]::new("(\d{1,})x(\d{1,})x(\d{1,})")

ForEach($data in $dataIn) {

    [int]$ribbonLen = 0

    $lwh = $rxLWH.Match($data)

    [int]$length = $lwh.Groups[1].Value
    [int]$width = $lwh.Groups[2].Value
    [int]$height = $lwh.Groups[3].Value

    [int[]]$allSides = @($length, $length, $width, $width, $height, $height)

    $allSides | Sort | Select -First 4 | % { $ribbonLen += $_ }
    
    $ribbonLen += ($length * $width * $height)

    $totalRibbon += $ribbonLen

}

$totalRibbon