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

$maxJobs = 25
$maxInt = [Int]::MaxValue
$jobBlock = 10000
$found = $false

For($i = 0; $i -le $maxInt; $i += $jobBlock) {

    $min = $i
    $max = [Math]::Min($i+$jobBlock-1,$maxInt)  

    If(-Not($found)) {
        
        Do {
            $jobCount = (Get-Job -State Running).Count
            if($jobCount -ge $maxJobs) { Start-Sleep -Seconds 1 }
        } Until ($jobCount -lt $maxJobs)
        
        Write-Host "[$(Get-Date -format "hh:mm:ss")] $min -> $max (Currently $jobCount jobs running)" -ForegroundColor Yellow
        Start-Job -Name "$min -> $max" -ArgumentList @($data, $min, $max) -ScriptBlock {
            
            Param(
                [String]$data,
                [Int]$Min,
                [Int]$Max
            )

            Function Get-MD5Hash {
    
                Param (
                    [string]$data
                )

                $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $utf8 = New-Object -TypeName System.Text.UTF8Encoding
                $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($data)))

                $hash -replace "-",""
            }

            For($i = $Min; $i -le $Max; $i++) {
                $hashValue = Get-MD5Hash -data "$data$i"
                if($hashValue.Substring(0,6) -eq "00000") { 
                    Write-Output "$i = $hashValue"
                }
                <#
                if($hashValue -eq "423A163C4CF4D62CCF027DE20251F12E") {
                    Write-Output "$i = $hashValue"
                }
                #>
            }

        } | Out-Null
    }


    $jobData = Get-Job -State Completed -HasMoreData:$true | Receive-Job

    if($jobData) {
        Write-Host $jobData -ForegroundColor Green
        $found = $true
        Get-Job | Stop-Job
        Get-Job | Remove-Job
    }

    Get-Job -state Completed -HasMoreData:$false | Remove-Job

    if($found) { break }

}

While($found -eq $false) {
    $jobData = Get-Job -State Completed -HasMoreData:$true | Receive-Job

    if($jobData) {
        Write-Host $jobData -ForegroundColor Green
        $found = $true
        Get-Job | Stop-Job
        Get-Job | Remove-Job
    }

    Get-Job -state Completed -HasMoreData:$false | Remove-Job
}

break



$ms = 0

$max = 100000

$start = Get-Date
1..$max | % { 

    $n = $_

    $test = Get-MD5Hash "$data$n"
    if($test.Substring(0,6) -eq "00000") { $n }

}
$end = Get-Date

"Span: $($(New-TimeSpan -Start $start -End $end).TotalMilliseconds)"
