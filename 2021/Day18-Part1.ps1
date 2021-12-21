
Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

Function Get-Depth {

    Param(
        [String]$str,
        [Int]$pos = 0
    )

    $caStr = $str.Substring(0, $pos).ToCharArray()
    
    [Int]$leftBracket = $caStr.where{ $_ -eq "[" }.Count 
    [Int]$rightBracket = $caStr.where{ $_ -eq "]" }.Count 

    Return $($leftBracket - $rightBracket)

}

Function Reduce {

    [CmdLetBinding()]
    Param(
        [String]$FishNumber
    )

    Write-Verbose "Reducing $FishNumber"

    Do {

        $DoExplode = $False
        $DoSplit = $false

        # Explode      
        Write-Verbose "Attempting to Explode $FishNumber"
        $NewFishNumber = Explode -FishNumber $FishNumber
        If($NewFishNumber -ne $FishNumber) { 
            Write-Verbose "There has been a change."
            $DoExplode = $true
        }

        $FishNumber = $NewFishNumber
        
        # Split
        Write-Verbose "Attempting to Split $FishNumber"
        $NewFishNumber = SplitNumber -FishNumber $FishNumber
        If($NewFishNumber -ne $FishNumber) { 
            Write-Verbose "There has been a change."
            $DoSplit = $true
        }

        $FishNumber = $NewFishNumber

    } Until($DoExplode -eq $False -and $DoSplit -eq $False)

    Write-Verbose "Reduce is Returning $FishNumber"
    Return $FishNumber

}

Function FishAdd {

    [CmdLetBinding()]
    Param(
        [String]$FishOne = "",
        [String]$FishTwo = ""
    )

    If(-Not($FishOne)) { Return $FishTwo }
    If(-Not($FishTwo)) { Return $FishOne }

    Return "[$FishOne,$FishTwo]"

}

Function Explode {

    [CmdLetBinding()]
    Param(
        [String]$FishNumber,
        [Switch]$SingleExplode = $false
    )

    Do {

        Write-Verbose $fishNumber

        $sets = [RegEx]::Matches($fishNumber, "(\[\d,\d\])")

        $rxDigits = [RegEx]::Matches($FishNumber, "\d{1,}")
        $regularNumbers = $rxDigits | Select @{N="Number";E={[Int]$_.Value}},Index

        $explode = $null
    
        ForEach($set in $sets) {
            $depth = Get-Depth -str $fishNumber -pos $set.Index
            Write-Verbose "Set: $($set.Value) at Position $($set.Index) has Depth $depth"

            If($depth -ge 4) {
                $explode = $set
                break
            }
        }

        If($explode) {

            $setValues = $explode.Value -replace "[\[|\]]","" -split","

            # Changing Fish Number Values to X,X (helps avoid issues when they change in size and we need to manipulate the string)
        
            [Int]$setLeft = $setValues[0]
            [Int]$setRight = $setValues[1]

            $lastRegularNumberToLeft = $regularNumbers.where({ $_.Index -lt $explode.Index }, 'last')[0]
            $nextRegularNumberToRight = $regularNumbers.where({ $_.Index -gt $($explode.Index + $explode.Length) }, 'first')[0]

            Write-Verbose "LN: $setLeft (Before: $($lastRegularNumberToLeft.Number) at $($lastRegularNumberToLeft.Index))"
            Write-Verbose "RN: $setRight (After: $($nextRegularNumberToRight.Number) at $($nextRegularNumberToRight.Index))"

            # Handle right number first so indexes of set and left number don't change.

            If($nextRegularNumberToRight) {

                Write-Verbose "Need to add our right set value ($setRight) to Right Regular Number ($($nextRegularNumberToRight.Number))"
                $sum = $nextRegularNumberToRight.Number + $setRight
                Write-Verbose "Setting New Number to $sum"

                $fishNumber = $fishNumber.Substring(0,$nextRegularNumberToRight.Index) + [string]$sum + $fishNumber.Substring($nextRegularNumberToRight.Index + $($nextRegularNumberToRight.Number.ToString().Length)  )
            }

            # Handle set next so that indexes of left number don't change it.

            Write-Verbose "Replacing our set with 0"

            $fishNumber = $fishNumber.Substring(0, $explode.Index) + "0" + $fishNumber.Substring($explode.Index + $explode.Length)

            Write-Verbose "New Fish Number is $fishNumber"

            If($lastRegularNumberToLeft) {

                Write-Verbose "Need to add our left set value ($setLeft) to Left Regular Number ($($lastRegularNumberToLeft.Number))"

                $sum = $lastRegularNumberToLeft.Number + $setLeft

                Write-Verbose "Setting New Number to $sum"

                $fishNumber = $fishNumber.Substring(0,$lastRegularNumberToLeft.Index) + [string]$sum + $fishNumber.Substring($lastRegularNumberToLeft.Index+1)

            }

        
        }

        Write-Verbose "Fish Value is $fishNumber"

        If($SingleExplode) { break }

    } Until (-not($explode))

    Return $FishNumber
}


Function SplitNumber {

    [CmdLetBinding()]
    Param(
        [String]$FishNumber,
        [Switch]$SingleSplit = $false
    )

    Do {
    
        $rxLgDigits = [RegEx]::Match($FishNumber, "\d{2,}")
    
        $split = $rxLgDigits | Select Value,Index

        If($split.Value) {
            Write-Verbose "We need to split $($split.Value) as position $($split.Index)"

            $half = $([Float]$split.Value)/2

            [Int]$setLeft = [Math]::Floor($half)
            [Int]$setRight = [Math]::Ceiling($half)

            $newSet = "[$setLeft,$setRight]"

            Write-Verbose "Should become set $newSet"

            $FishNumber = $FishNumber.Substring(0, $split.Index) + $newSet + $FishNumber.Substring($split.Index + $split.Value.ToString().Length)

            Write-Verbose $FishNumber
        }
        
        If($SingleSplit) { break }

    } Until (-not($split.value))

    Return $FishNumber
}

$FishNumber = "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[12,5],[[5,[7,0]],[13,[0,[7,7]]]]]]"

Reduce -FishNumber $FishNumber -Verbose
    







$dataIn = @"
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
"@ -split "`r`n"

$FishTotal = ""

$i = 0
$dataIn | % {
    
    $i++
    Write-Host "Adding $FishTotal to $($_)"
    $FishTotal = FishAdd -FishOne $FishTotal -FishTwo $_
    Write-Host "Sum: $FishTotal"

    $FishTotal = Reduce $FishTotal -Verbose
    
    write-host "-"
    

}


Write-Host $FishTotal

Return






## SINGLE EXPLODE TEST ONLY. DOES NOT WORK FOR FULL FUNCTION

$test = @"
[[[[[9,8],1],2],3],4] [[[[0,9],2],3],4]
[7,[6,[5,[4,[3,2]]]]] [7,[6,[5,[7,0]]]]
[[6,[5,[4,[3,2]]]],1] [[6,[5,[7,0]]],3]
[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] [[3,[2,[8,0]]],[9,[5,[7,0]]]]
"@ -split "`r`n"

$testsToRun = $test.ForEach{
    [PSCustomObject]@{
        "Sample" = ($_ -split " ")[0]
        "Answer" = ($_ -split " ")[1]
    }
}

ForEach($t in $testsToRun) {

    Write-Host "Testing $($t.Sample) ... " -NoNewline
    $e = Explode $t.sample -SingleExplode

    if($e -eq $t.Answer) { 
        Write-Host "Pass." -ForegroundColor Green
    } else {
        Write-Host "Fail $($e)" -ForegroundColor Red
    }
}

