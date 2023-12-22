Clear-Host
Get-Date
Write-Host "---"

Function Get-Maps {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Array]$Atlas
    )

    [Array[]]$Maps = Do {
        $nextBlank = $atlas.indexof('')
        If($nextBlank -ge 0) {
            $atlas[0..$($nextBlank-1)] -join ','
            $Atlas = $Atlas[$($nextBlank+1)..$Atlas.Count]
        } Else {
            $Atlas -join ','
        }
    } While($nextBlank -ge 0)

    Return $maps
}
Function Find-ReflectionPoint {

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$true)]    
        [array]$Map
    )

    Function Reflections {

        [CmdLetBinding()]
        Param(
            [Array]$MapData
        )

        # $mapData | FT -AutoSize | Out-Host

        # Get all duplicate lines sorted by their line number. These aren't necessarily in pairs since a line could be in the list
        # an odd number of times (trickery!)
        $duplicates = $MapData | Group-Object Line | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Group | Sort-Object Index
        
        Write-Verbose "Looping Over Duplicates..."

        [Array]$dupeAfter = $duplicates.ForEach{
            if($mapData[$_.Index].Line -eq $mapData[$_.Index-1].Line) {
                $($_.Index - 1)
            }
        }


        Write-Verbose "Possible Reflection Lines: $($dupeAfter -join ',')"
        [Array]$ReflectionList = @()
        $dupeAfter.ForEach{
            $dupeLine = $_
            Write-Verbose "Looking at possible reflection at index $dupeLine with mapCount = $($mapData.count)"
    
            $ReflectionTop = $dupeLine
            $ReflectionBottom = $dupeLine + 1
    
            $GoodReflection = $True
            Do {
                Write-Verbose "Checking $ReflectionTop Against $ReflectionBottom ($($($mapData[$ReflectionTop].Line)) -> $($($mapData[$ReflectionBottom].Line)))"
                if($mapData[$ReflectionTop].Line -ne $mapData[$ReflectionBottom].Line) {
                    Write-Verbose "This is not a good reflection."
                    Write-Verbose "  Left:  $($mapData[$ReflectionTop].Line)"
                    Write-Verbose "  Right: $($mapData[$ReflectionBottom].Line)"
                    $GoodReflection = $false
                    break
                } Else {
                    Write-Verbose " So far so good..."
                }
                $ReflectionTop--
                $ReflectionBottom++
            } Until($ReflectionTop -eq -1 -or $ReflectionBottom -gt $mapData.Count - 1)
            
            If($GoodReflection) { 
                Write-Verbose "$dupeLine is a good reflection"
                $reflectionList += $dupeLine
            }
        }

        Return [Array]$ReflectionList
    
    }

    $mapDataNormal = For($index = 0; $index -lt $map.Count; $index++) {
        [PSCustomObject]@{
            Index = $index
            Line = $map[$index]
        }
    }

    [Array]$mapDataTurned = For($index = 0; $index -lt $map[0].Length; $index++) {
        [String]$ColumnData = ""
        $map.ForEach{
            $ColumnData += "$($_.Substring($index,1))"
        }
        [PSCustomObject]@{
            Index = $index
            Line = $ColumnData
        }
    }

    Write-Verbose "Getting Horizontal Reflection List..."
    [Array]$HorizontalReflectionList = Reflections -MapData $mapDataNormal
    
    Write-Verbose "Getting Vertical Reflection List..."
    [Array]$VerticalReflectionList = Reflections -MapData $mapDataTurned

    If($HorizontalReflectionList.count -eq 0 -and $VerticalReflectionList.count -eq 0) {
        Throw "No reflections found."
    }

    If($HorizontalReflectionList.Count + $VerticalReflectionList.count -gt 1) {
        Throw "Too many reflections found."
    }

    If($HorizontalReflectionList.Count) {
        Write-Verbose "Horizontal Refelection List: $($HorizontalReflectionList[0])"
        Return ($HorizontalReflectionList[0]+1)*100
    } Else {
        Write-Verbose "Vertical Refelection List: $($VerticalReflectionList[0])"
        Return $VerticalReflectionList[0]+1
    }
    


}

$data = Get-Content $PSScriptRoot\Input.txt

$maps = Get-Maps $data

<#
$thisMap = $maps[5] -split ','
$thisMap | FT -AutoSize

Find-ReflectionPoint -Map $thisMap -Verbose
break
#>

$allResults = ForEach($map in $maps) {
    $thisMap = $map -split ','
    Try {
        Find-ReflectionPoint $thisMap
    } Catch {
        Throw $_
        break
    }
}

$allResults | Measure-Object -Sum | Select-Object -ExpandProperty Sum

#$thisMap | FT -AutoSize
#break

