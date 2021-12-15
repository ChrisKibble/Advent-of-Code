Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = Get-Content $PSScriptRoot\Day8-Input.txt

[int]$totalCalc = 0

# Easier to visualize this way, not really necessary
$allData = ForEach($systemOutput in $dataIn) {
   
    $signalPatterns = $systemOutput.Substring(0,$systemOutput.IndexOf("|")-1)
    $outputValue = $systemOutput.Substring($signalPatterns.Length+3)

    $newPattern = $signalPatterns -split " " | ForEach-Object {
        $($_.ToCharArray() | Sort-Object) -join ""
    }

    $newOutput = $outputValue -split " " | ForEach-Object {
        $($_.ToCharArray() | Sort-Object) -join ""
    }
    
    [PSCustomObject]@{
        "SystemOutput" = $systemOutput
        "SignalPatterns" = $newPattern
        "OutputValue" = $newOutput
    }
}


ForEach($signal in $allData) {

    $signalPatterns = $signal.SignalPatterns

    $map = @{}
 
    $map.Add($signalPatterns.Where{ $_.length -eq 7 }[0].ToString(), 8)   # 8 characters = 8
    $map.Add($signalPatterns.Where{ $_.length -eq 3 }[0].ToString(), 7)   # 3 characters = 7
    $map.Add($signalPatterns.Where{ $_.length -eq 4 }[0].ToString(), 4)   # 4 characters = 4
    $map.Add($signalPatterns.Where{ $_.length -eq 2 }[0].ToString(), 1)   # 2 characters = 1

    [string]$one = $map.GetEnumerator().Where{ $_.Value -eq 1 }[0].Name
    [string]$four = $map.GetEnumerator().Where{ $_.Value -eq 4 }[0].Name
    [string]$seven = $map.GetEnumerator().Where{ $_.Value -eq 7 }[0].Name
    [string]$eight = $map.GetEnumerator().Where{ $_.Value -eq 8 }[0].Name

    # Possible Values
    $pt = $ptl = $ptr = $pm = $pbl = $pbr = $p = @("a","b","c","d","e","f","g")

    # Actual Values
    $t = $tl = $tr = $m = $bl = $br = $b = "."
    
    # The diff between 1 and 7 is the top bar
    $val = [String]$(Compare-Object $one.ToCharArray() $seven.ToCharArray()).InputObject
    $t = $pt = $val

    $ptl = $ptl.where{$_ -ne $t }
    $ptr = $ptr.where{$_ -ne $t }
    $pm = $pm.where{$_ -ne $t }
    $pbl = $pbl.where{$_ -ne $t }
    $pbr = $pbr.where{$_ -ne $t }
    $pb = $pb.where{$_ -ne $t }


    # The letters in 1 must be one of the two right values, and nothing else can be those.
    $ptr = $one.ToCharArray()
    $pbr = $one.ToCharArray()


    $ptl = $ptl.where{$_ -notin $one.ToCharArray()}
    $pm = $ptl.where{$_ -notin $one.ToCharArray()}
    $pbl = $ptl.where{$_ -notin $one.ToCharArray()}
    $pb = $ptl.where{$_ -notin $one.ToCharArray()}

    # The diff between 1 and 4 are the left top and mid, and nothing else can be those.
    $val = $(Compare-Object $one.ToCharArray() $four.ToCharArray()).InputObject
    
    $ptl = $ptl.where{$_ -in $val}
    $pm = $pm.where{$_ -in $val}

    $ptr = $ptr.where{$_ -notin $val}
    $pbl = $pbl.where{$_ -notin $val}
    $pbr = $pbr.where{$_ -notin $val}
    $pb = $pb.where{$_ -notin $val}
    
    # The possible mid value is in 4 but not in 7
    $val = $(Compare-Object $four.ToCharArray() $seven.ToCharArray()) | Where-Object { $_.SideIndicator -eq "<=" } | Select -ExpandProperty InputObject
    $pm = $pm.where{ $_ -in $val }

    # If it has six characters (0, 6, 9) and four of them are from our known number four, then it's our nine.
    $signalPatterns.where{$_.length -eq 6}.ForEach{
        # Can I use Compare Object here instead of looping?
        $patChar = $_.ToCharArray()
        If($patChar -contains $four[0] -and $patChar -contains $four[1] -and $patChar -contains $four[2] -and $patChar -contains $four[3]) {
            [string]$nine = $_
        }
    }
    
    # The missing segment from nine is the lower left and nothing else can be.
    $pbl = $bl = $(Compare-Object "abcdefg".ToCharArray() $nine.ToCharArray()).InputObject

    $ptl = $ptl.where{$_ -ne $bl}
    $ptr = $ptr.where{$_ -ne $bl}
    $pm = $pm.where{$_ -ne $bl}
    $pbr = $pbr.where{$_ -ne $bl}
    $pb = $pb.where{$_ -ne $bl}

    # This also rules out all other possibilities for the bottom
    $b = $pb[0]

    # If it has five characters (2, 3, or 5), and contain our top, bottom-left, and bottom, it must be the 2.
    $signalPatterns.where{ $_.length -eq 5 }.ForEach{
        $patChar = $_.ToCharArray()
        If($patChar -contains $t -and $patChar -contains $bl -and $patChar -contains $b) {
            [string]$two = $_
        }
    }

    # If we remove the Top, Bottom Left, and Bottom from the TWO, we're left with a possible mid and top-right
    $strippedTwo = $two.ToCharArray().where{ $_ -ne $t -and $_ -ne $bl -and $_ -ne $b }

    $pm = $pm.where{ $_ -in $strippedTwo }
    $ptr = $ptr.where{ $_ -in $strippedTwo }

    # Above solves for mid and top right

    $m = $pm[0]
    
    $tr = $ptr[0]
    
    # Remaining are Top Left and Bottom Right which we can work out by removing the two we just found
    $tl = $ptl = $ptl.where{ $_ -notin $m -and $_ -notin $tr }
    $br = $pbr = $pbr.where{ $_ -notin $m -and $_ -notin $tr }

    # Fill in the map
    $zero = $("$t$tl$tr$bl$br$b".ToCharArray() | Sort) -join ""
    $three = $("$t$tr$m$br$b".ToCharArray() | Sort) -join ""
    $five = $("$t$tl$m$br$b".ToCharArray() | Sort) -join ""
    $six = $("$t$tl$m$bl$br$b".ToCharArray() | Sort) -join ""
    
    $map.Add($zero, 0)
    $map.Add($two, 2)
    $map.Add($three, 3)
    $map.Add($five, 5)
    $map.Add($six, 6)
    $map.Add($nine, 9)

    [string]$outputCode  = ""
    
    $signal.OutputValue.ForEach{
        $outputCode += $map.$_
    }

    $totalCalc += $($outputCode -as [int])
}

$totalCalc
