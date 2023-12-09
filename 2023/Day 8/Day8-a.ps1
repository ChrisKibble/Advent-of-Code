Clear-Host
Get-Date
Write-Host '---------'

Function Translate-Map {

    [CmdLetBinding()]
    Param(
        [String[]]$Map
    )

    $keyList = $Map | Select-Object -Skip 2

    $locs = $keyList.ForEach{
        @{
            $_.Substring(0,3) = @($_.Substring(7,3), $_.Substring(12,3))
        }
    }

    $locs

}

Function Walk {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Directions,

        [Parameter(Mandatory=$True)]
        [Object[]]$MapSteps,

        [Parameter(Mandatory=$True)]
        [Int]$StepNumber,

        [Parameter(Mandatory=$True)]
        [String]$StartingPoint
    )

    $NextDirectionIndex = $StepNumber % $($directions.Length)

    Write-Verbose "I've taken $StepNumber Steps. I need to get index $nextDirectionIndex from Directions starting at $startingPoint"
    $nextDirection = $directions[$nextDirectionIndex]
    If($nextDirection -eq 'L') { $mapIndex = 0 } Else { $mapIndex = 1 }
    Write-Verbose "   Next Direction is $nextDirection (index $mapIndex)"

    $nextStep = $mapSteps.$StartingPoint[$mapIndex]

    Return $nextStep

}

$data = Get-Content $PSScriptRoot\Input.txt

[String]$directions = $data[0]
$mapSteps = Translate-Map $data -Verbose

$stepNumber = 0
$nextStep = 'AAA'
Do {
    $NextStep = Walk -Directions $directions -Map $MapSteps -StepNumber $StepNumber -StartingPoint $nextStep
    $stepNumber++
} While($NextStep -ne 'ZZZ')

Write-Output "Steps: $stepNumber"
