﻿Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

$dataIn = "D2FE28"


$dataIn = "220D4B80491FE6FBDCDA61F23F1D9B763004A7C128012F9DA88CE27B000B30F4804D49CD515380352100763DC5E8EC000844338B10B667A1E60094B7BE8D600ACE774DF39DD364979F67A9AC0D1802B2A41401354F6BF1DC0627B15EC5CCC01694F5BABFC00964E93C95CF080263F0046741A740A76B704300824926693274BE7CC880267D00464852484A5F74520005D65A1EAD2334A700BA4EA41256E4BBBD8DC0999FC3A97286C20164B4FF14A93FD2947494E683E752E49B2737DF7C4080181973496509A5B9A8D37B7C300434016920D9EAEF16AEC0A4AB7DF5B1C01C933B9AAF19E1818027A00A80021F1FA0E43400043E174638572B984B066401D3E802735A4A9ECE371789685AB3E0E800725333EFFBB4B8D131A9F39ED413A1720058F339EE32052D48EC4E5EC3A6006CC2B4BE6FF3F40017A0E4D522226009CA676A7600980021F1921446700042A23C368B713CC015E007324A38DF30BB30533D001200F3E7AC33A00A4F73149558E7B98A4AACC402660803D1EA1045C1006E2CC668EC200F4568A5104802B7D004A53819327531FE607E118803B260F371D02CAEA3486050004EE3006A1E463858600F46D8531E08010987B1BE251002013445345C600B4F67617400D14F61867B39AA38018F8C05E430163C6004980126005B801CC0417080106005000CB4002D7A801AA0062007BC0019608018A004A002B880057CEF5604016827238DFDCC8048B9AF135802400087C32893120401C8D90463E280513D62991EE5CA543A6B75892CB639D503004F00353100662FC498AA00084C6485B1D25044C0139975D004A5EB5E52AC7233294006867F9EE6BA2115E47D7867458401424E354B36CDAFCAB34CBC2008BF2F2BA5CC646E57D4C62E41279E7F37961ACC015B005A5EFF884CBDFF10F9BFF438C014A007D67AE0529DED3901D9CD50B5C0108B13BAFD6070"


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


            Write-Host "   Not sure what to do, so time to read in the version and type bits."
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
                $bitString = $bitString.Substring($opBitLen)

                Write-Host "   Subpacket Length is $subpacketLength"
                $message = $bitString.Substring(0, $subpacketLength)
                
                Write-Host "Message is $message"
                
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
