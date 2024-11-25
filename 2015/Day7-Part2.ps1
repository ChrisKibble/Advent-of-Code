$sample = @"
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
"@ -split "`r?`n"

$sample = Get-Content $PSScriptRoot\Day7-Input.txt

$Instructions = ForEach($line in $sample) {
    [Array]$components = $line -split " "
    [Array]$operation = $components[0..$($components.count - 3)]
    $variable = $components[-1]
  
    $op = $null

    If($operation.count -eq 1) {
        $op = "ASSIGN"
        $numLeft = $operation[0]
        $numRight = $null
        Write-Verbose "Assign $numLeft to $variable"
    }

    If($operation[1] -eq "AND") {
        $op = "AND"
        $numLeft = $operation[0]
        $numRight = $operation[2]
        Write-Verbose "$numLeft AND $numRight to $variable"
    }

    If($operation[1] -eq "OR") {
        $op = "OR"
        $numLeft = $operation[0]
        $numRight = $operation[2]
        Write-Verbose "$numLeft OR $numRight to $variable"
    }

    If($operation[1] -eq "LSHIFT") {
        $op = "LSHIFT"
        $numLeft = $operation[0]
        $numRight = $operation[2]
        Write-Verbose "$numLeft LSHIFT $numRight to $variable"
    }

    If($operation[1] -eq "RSHIFT") {
        $op = "RSHIFT"
        $numLeft = $operation[0]
        $numRight = $operation[2]
        Write-Verbose "$numLeft RSHIFT $numRight to $variable"
    }

    If($operation[0] -eq "NOT") {
        $op = "NOT"
        $numLeft = $operation[1]
        $numRight = $null
        Write-Verbose "NOT $numLeft to $variable"
    }

    Write-Verbose "-----------"
    Write-Verbose "Instruction: $line"
    Write-Verbose "Operation: $op"
    Write-Verbose "Variable: $Variable"
    Write-Verbose "LN: $numLeft | RN: $numRight"

    [PSCustomObject]@{
        Instruction = $line
        Operation = $op
        ResultVariable = $Variable
        NumLeft = $numLeft
        NumRight = $numRight
        Processed = $False
    }

    If(-Not($op)) {
        Throw "No Operation"
    }
}


# Skip Result Variables that never get used anyway
$Instructions.Where{ $_.ResultVariable -notin $Instructions.NumLeft -and $_.ResultVariable -notin $Instructions.NumRight -and $_.ResultVariable -ne 'a' }.ForEach{ $_.Processed = $True }

# Set new default for 'B' based on run of Part 1
$Instructions.Where{ $_.ResultVariable -eq 'b' }.ForEach{ 
    $_.NumLeft = 956
    $_.Instruction = '956 -> b'
}

Clear-Host

$circuits = @{}

Do {
    Write-Verbose "Starting..."
    # Find Actions we can take (NumLeft & NumRight are resolved)
    $actionable = $Instructions.Where{ $_.Processed -eq $False -and ($_.NumLeft -as [Int] -is [Int]) -and ($_.NumRight -as [Int] -is [Int] -or -not $_.NumRight) }

    Write-Host "There are $(($Instructions.Where{ -Not $_.Processed}).count) instructions remaining and $($actionable.count) actionable in this loop."

    ForEach($action in $actionable) {
        
        $assignNumber = $null

        If($action.Operation -eq "ASSIGN") {
            $assignNumber = $action.NumLeft
        }

        If($action.Operation -eq "AND") {
            $assignNumber = $action.numLeft -band $action.numRight
        }        

        If($action.Operation -eq "OR") {
            $assignNumber = $action.numLeft -bor $action.numRight
        }

        If($action.Operation -eq "LSHIFT") {
            $assignNumber = $action.numLeft -shl $action.numRight
        }

        If($action.Operation -eq "RSHIFT") {
            $assignNumber = $action.numLeft -shr $action.numRight
        }

        If($action.Operation -eq "NOT") {
            $binary = [Convert]::ToString($action.NumLeft,2).PadLeft(16,"0")
            $complement = $binary.ToCharArray().ForEach{ If($_ -eq "0") { "1" } else { "0" }} -join ""    
            $assignNumber = [Convert]::ToInt32($complement, 2)
        }

        If($null -ne $assignNumber) {
            $Instructions.Where{ $_.numLeft -eq $Action.ResultVariable }.ForEach{ $_.NumLeft = $assignNumber }
            $Instructions.Where{ $_.numRight -eq $Action.ResultVariable }.ForEach{ $_.NumRight = $assignNumber }
            $Instructions.Where{ $_.Instruction -eq $action.Instruction }.ForEach{ $_.Processed = $True }
            $circuits.$($action.ResultVariable) = $assignNumber
        }
    }

} Until(-Not($actionable) -or $circuits.Keys -contains 'a')

$circuits.a