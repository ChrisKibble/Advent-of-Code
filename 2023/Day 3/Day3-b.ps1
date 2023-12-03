Clear-Host

$data = Get-Content .\input.txt -Raw

# Make it easy with a one char newline if there are two
$data = $data -replace "`r?`n","`n"

$lineEnd = $data.IndexOf("`n")

# Find all non-digit, non-dot, non-EOL chars
$rxStars = [RegEx]::New('(?msi)\*')

$starChars = $rxStars.matches($data)

# Create Array of positions around the special character (inc. diags)
$starIndexes = $starChars.ForEach{

    $Position = $_.Index
    $leftPosition = $Position - 1
    $rightPosition = $Position + 1
    $abovePosition = $Position - $lineEnd - 1
    $belowPosition = $Position + $lineEnd + 1
    $diagTopLeft = $abovePosition - 1
    $diagTopRight = $abovePosition + 1
    $diagBottomLeft = $belowPosition - 1
    $diagBottomRight = $belowPosition + 1
    
    [PSCustomObject]@{
        StarIndex = $Position
        L = $leftPosition
        R = $rightPosition
        A = $abovePosition
        B = $belowPosition
        dtl = $diagTopLeft
        dtr = $diagTopRight
        dbl = $diagBottomLeft
        dbr = $diagBottomRight
        Positions = [Int[]]@($position, $leftPosition, $rightPosition, $abovePosition, $belowPosition, $diagTopLeft, $diagTopRight, $diagBottomLeft, $diagBottomRight)
    }
}

# Next, Find all the numbers with all of their positions
$rxNumbers = [RegEx]::New('(?msi)(\d+)')

$numberList = $rxNumbers.Matches($data).ForEach{

    $StartIndex = $_.Index
    $Number = $_.Value
    $Length = $_.Length
   
    $StartIndex..$($StartIndex+$Length-1) | ForEach-Object {
        [PSCustomObject]@{
            Number = $Number
            StartIndex = $StartIndex
            Position = $_
        }
    }

}

# Loop over stars to find numbers around them
$allRatios = ForEach($star in $starIndexes) {
    $surroundingNumbers = $numberList | Where-Object { $_.Position -in $star.Positions} | Select-Object Number, StartIndex -Unique
    If($surroundingNumbers.count -eq 2) {
        $gearRatio = [Int]$surroundingNumbers[0].Number * [Int]$surroundingNumbers[1].Number
        $gearRatio
    }
}

$allRatios | Measure-Object -Sum | Select-Object -ExpandProperty Sum