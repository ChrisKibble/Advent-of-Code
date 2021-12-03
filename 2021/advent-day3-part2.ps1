Clear-Host 

$data = get-content C:\temp\input3.txt

[string]$ogr = [string]$co2 = [string]$bitString = ""

For($i = 0; $i -lt $data[0].length; $i++) {
    
    [string]$bitString = ""
    $data.ForEach{
        $bitString += $_.ToCharArray()[$i]
    }

    $zeroCount = $bitString.ToCharArray().where{ $_ -eq "0" }.count
    $oneCount = $bitString.ToCharArray().where{ $_ -eq "1" }.count
    
    if($zeroCount -gt $oneCount) {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "0" }
    } elseif ($zeroCount -lt $oneCount) {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "1" }
    } else {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "1" }
    }

    if($data.count -eq 1) {
        $ogr = $data
        break
    }

}

$data = get-content C:\temp\input3.txt

For($i = 0; $i -lt $data[0].length; $i++) {
    
    [string]$bitString = ""
    $data.ForEach{
        $bitString += $_.ToCharArray()[$i]
    }

    $zeroCount = $bitString.ToCharArray().where{ $_ -eq "0" }.count
    $oneCount = $bitString.ToCharArray().where{ $_ -eq "1" }.count
    
    if($zeroCount -gt $oneCount) {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "1" }
    } elseif ($zeroCount -lt $oneCount) {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "0" }
    } else {
        $data = $data.where{ $_.ToCharArray()[$i] -eq "0" }
    }

    if($data.count -eq 1) {
        $co2 = $data
        break
    }

}

$oxygen = [Convert]::ToInt32($ogr,2)
$scrubber = [Convert]::ToInt32($co2,2)

Write-Host "Oxygen: $ogr $oxygen"
Write-Host "CO2 Scrubber: $co2 $scrubber"

Write-Host "LSR = $($oxygen * $scrubber)"