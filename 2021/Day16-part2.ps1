Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = "D2FE28"


$dataIn = "C200B40A82"


$bitList = [System.Collections.ArrayList]::New(@())

$dataIn.ToCharArray().ForEach{

    $str = [string]$_
    $dec = [uint32]"0x$str"
    $bin = $([Convert]::ToString($dec,2)).PadLeft(4,'0')
    
    [Void]$bitList.Add(
        [PSCustomObject]@{
            "Hex" = $str
            "Decimal" = $dec
            "Binary" = $bin
        }
    )

}

$bitString = $bitList.Binary -join ""
$action = $null

[Int64]$total = 0
[Int]$VersionSum = 0

While($bitString.Length -ge 4) {

    #Write-Host "Bitstring is now $bitString with length $($bitString.Length)" 

    Switch($action) {
    
        $null {

            If($bitString.Length -lt 10) { 
                # Nothing we can do with less than 10 characters if we're not in an action alrady
                return
            }


            Write-Host "Not sure what to do, so time to read in the version and type bits."
            $packetVersion = $bitString.Substring(0,3)
            $packetType = $bitString.Substring(3,3)
            $packetVersion = [Convert]::ToInt32($packetVersion, 2)
            $packetType = [Convert]::ToInt32($packetType, 2)
            $bitString = $bitString.Substring(6)
            Write-Host "      Version $packetVersion"
            Write-Host "      Type $packetType"
            
            $VersionSum += $packetVersion

            If($packetType -eq "4") {
                Write-Host "Switching to Literal Mode!"
                $action = "L"
                [String]$literal = ""
            } else {
                Write-Host "Switching to Operator Mode"
                If($bitString.Substring(0,1) -eq 0) {
                    $opBitLen = 15
                } else {
                    $opBitLen = 11
                }

                $bitString = $bitString.Substring(1)

                Write-Host "   Bit Length = $opBitLen"

                $subpacketLength = [Convert]::ToInt32($bitString.Substring(0, $opBitLen), 2)
                Write-Host "   Subpacket Length is $($bitString.Substring(0, $opBitLen)) ($subpacketLength)"

                $bitString = $bitString.Substring($opBitLen)
                $message = $bitString.Substring(0, $subpacketLength)
                
                Write-Host "   Message is $message"
                
            }


        }

        "L" {
            
            Write-Host "   I'm working a literal packet. Grabbing next five bits."
            
            $nextBits = $bitString.Substring(0,5)
            
            $bitString = $bitString.Substring(5)
            $litBin = $nextBits.Substring(1,4)

            $literal += $litBin
            
            If($nextBits.substring(0,1) -eq "0") {
                
                Try {
                    $literalNum = $([Convert]::ToInt64($literal, 2))
                } Catch {
                    Throw $_
                }
                Write-Host "     This was be my last literal capture."
                Write-Host "     Value: $literal ($literalNum)"
                $total = $total + $literalNum
                $action = $null
            }


        }
    
    }

}
