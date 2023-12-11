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

[Array]$startingPositions = $mapSteps.Keys.Where{ $_.Substring(2,1) -eq 'A'}

$startingPositions | ForEach-Object {

    $nextStep = $_
    Write-Host "Seeing where $nextStep Ends"

    $stepNumber = 0
    $itCount = 0
    
    Do {
        $nextStep = Walk -Directions $directions -StepNumber $stepNumber -StartingPoint $nextStep -MapSteps $mapSteps
        $stepNumber++
        If($nextStep.Substring(2,1) -eq 'Z') { 
            Write-Host "  Ends at $nextStep After $stepNumber Steps"
            $itCount++ 
        }
    } Until($itCount -eq 3)

}

# Here I realized that each loop was the same count, so the number of steps would
# be the LCM of the number of each path taken. I had no idea how to write that function,
# so I ran it through an online calculator instead.

# Sorry if you expected more of me at this line :)
