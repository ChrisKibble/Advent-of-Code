Clear-Host

$data = Get-Content .\input.txt -Raw

# Make it easy with a one char newline if there are two
$data = $data -replace "`r?`n","`n"

$lineEnd = $data.IndexOf("`n")

# Find all non-digit, non-dot, non-EOL chars
$specials = [RegEx]::New('(?msi)[^\d|\.|\n]')

$specialChars = $specials.matches($data)

# Create Array of positions around the special character (inc. diags)
[Int[]]$specialIndexes = $specialChars.ForEach{

    $Position = $_.Index
    $leftPosition = $Position - 1
    $rightPosition = $Position + 1
    $abovePosition = $Position - $lineEnd - 1
    $belowPosition = $Position + $lineEnd + 1
    $diagTopLeft = $abovePosition - 1
    $diagTopRight = $abovePosition + 1
    $diagBottomLeft = $belowPosition - 1
    $diagBottomRight = $belowPosition + 1
    
    $leftPosition
    $rightPosition
    $abovePosition
    $belowPosition
    $diagTopLeft
    $diagTopRight
    $diagBottomLeft
    $diagBottomRight
}

# Remove negatives and anything that is beyond our map
$specialIndexes = $specialIndexes | Select-Object -Unique | Where-Object { $_ -ge 0 -and $_ -le $data.Length }

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

# Find where the special characters list and number positions intersect.
$PartNumberIndex = $specialIndexes.Where{ $_ -in $NumberList.Position}

# Strip out the position so we can get a unique list of numbers only, then sum the numbers
$numberList.Where{ $_.Position -in $PartNumberIndex} | Select-Object Number, StartIndex -Unique | Select-Object -ExpandProperty Number | Measure-Object -Sum | Select-Object -ExpandProperty Sum

