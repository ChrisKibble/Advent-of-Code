$dataIn = Get-Content $PSScriptRoot\Day2-Input.txt

$totalPaper = 0

$rxLWH = [regex]::new("(\d{1,})x(\d{1,})x(\d{1,})")

ForEach($data in $dataIn) {
    $lwh = $rxLWH.Match($data)

    [int]$length = $lwh.Groups[1].Value
    [int]$width = $lwh.Groups[2].Value
    [int]$height = $lwh.Groups[3].Value

    [int]$panel1 = ($length * $width)
    [int]$panel2 = ($width * $height)
    [int]$panel3 = ($height * $length)

    [int]$sqftNeeded = (2*$panel1) + (2*$panel2) + (2*$panel3) + @($panel1, $panel2, $panel3 | Measure-Object -Minimum).Minimum

    [int]$totalPaper += $sqftNeeded
}

$totalPaper | Out-Host