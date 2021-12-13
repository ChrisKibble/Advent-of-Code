$data = "yzbqklnj"

$minInt = 0
$maxInt = [Int]::MaxValue
# $maxInt = 282750
$jobBlock = 40000

For($i = $minInt; $i -le $maxInt; $i += $jobBlock) {

    $min = $i
    $max = [Math]::Min($i+$jobBlock-1,$maxInt)  
      
    #Write-Host "[$(Get-Date -format "hh:mm:ss")] $min -> $max" -ForegroundColor Yellow

    Start-ThreadJob -Name "$($min.ToString("N0")) -> $($max.ToString("N0"))" -ArgumentList @($data, $min, $max) -ThrottleLimit 10 -ScriptBlock {
        
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
            if($hashValue.Substring(0,6) -eq "000000") { 
                Write-Output "$i = $hashValue"
            }
        }

    } | Out-Null
}

Write-Host "Done Starting Jobs"

While(Get-Job) {

    If ($(Get-Date).Second % 5 -eq 0) {
        If($shown -eq $false) {
            $lastJob = (Get-Job -State Running)[-1]
            Write-Host "$(Get-Date -Format "hh:mm:ss.fff") Processing Incoming Job Data. LastJob = $($lastJob.Name)"
            $shown = $true
        }
    } else {
        $shown = $false
    }

    $jobData = Get-Job -State Completed -HasMoreData:$true | Receive-Job

    If($jobData) {
        Write-Host $jobData -ForegroundColor Green
        Get-Job | Remove-Job -Force
    } else {
        Get-Job -state Completed -HasMoreData:$false | Remove-Job
    }

}

Write-Host "There are no more jobs running."
