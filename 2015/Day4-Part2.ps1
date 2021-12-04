$data = "yzbqklnj"

Function Get-MD5Hash {
    
    Param (
        [string]$data
    )

    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = New-Object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($data)))

    $hash -replace "-",""
}

$fiveZerosFromPart1 = 282749

For($i = $fiveZerosFromPart1; $i -lt [int]::MaxValue; $i++) {
    $hash = Get-MD5Hash -data "$data$i"
    if($hash.Substring(0,6) -eq "000000") {
        Write-Host $i
        break
    }
}
