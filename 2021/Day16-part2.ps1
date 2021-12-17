Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

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


Function Get-NextPacket {

    Param(
        [CmdLetBinding()]
        [string]$bitString,
        [int]$indent = 0
    )

    Write-Host "$("  " * $indent)BitString: $bitString"

    $packetVersion = $bitString.Substring(0,3)
    $packetType = $bitString.Substring(3,3)
    $packetVersion = [Convert]::ToInt32($packetVersion, 2)
    $packetType = [Convert]::ToInt32($packetType, 2)
    $bitString = $bitString.Substring(6)

    Write-Host "$("  " * $indent)Version is $packetVersion"
    Write-Host "$("  " * $indent)Packet Type is $packetType"

    If($packetType -eq 4) {

        [String]$literal = ""

        Do {
            Write-Host "$("  " * $indent)I'm working a literal packet. Grabbing next five bits."
            
            $nextBits = $bitString.Substring(0,5)          
            $bitString = $bitString.Substring(5)

            $literalBinary = $nextBits.Substring(1,4)
            $lastMessage = $nextBits.Substring(0,1)

            $literal += $literalBinary
            
            If($lastMessage -eq 0) {
                
                Write-Host "$("  " * $indent)This was be my last literal capture."
                $literalNum = $([Convert]::ToInt64($literal, 2))
                Write-Host "$("  " * $indent)Value: $literal ($literalNum)"
            }

        } Until($lastMessage -eq 0)

        Return [PSCustomObject]@{
            "Version" = $packetVersion
            "Type" = $packetType
            "Value" = $literalNum
            "BitString" = $bitString
        }
    
    }

    If($packetType -ne 4) {
            
        Write-Host "$("  " * $indent)I'm starting an operation with $bitString"

        $bitLengthTypeId = $bitString.Substring(0,1)
        $bitString = $bitString.Substring(1)

        Write-Host "$("  " * $indent)BitLengthTypeID is $bitLengthTypeId"

        $values = @()

        If($bitLengthTypeId -eq 0) {
            
            Write-Host "$("  " * $indent)I will look at the next 15 bits to find the bit length"
            $bitLength = $bitString.Substring(0,15)
            $bitLength = [Convert]::ToInt32($bitString.Substring(0,15), 2)
            $bitString = $bitString.Substring(15)
            
            Write-Host "$("  " * $indent)Bit Length = $bitLength"
            $packetData = $bitString.Substring(0, $bitLength)
            $bitString = $bitString.Substring($bitLength)

            Do {
                $p = Get-NextPacket $packetData -indent ($indent+1)
                $packetData = $p.BitString
                $values += [uint64]$p.value
                Write-Host "$("  " * $indent)-"
            } Until($packetData.length -le 6)


        } else {
            
            Write-Host "$("  " * $indent)I will look at the next 11 bits to find the number of subpackets"
            $subpacketCount = [Convert]::ToInt32($bitString.Substring(0, 11), 2)
            $bitString = $bitString.Substring(11)

            Write-Host "$("  " * $indent)Subpacket Count is $subpacketCount"

            For($i = 1; $i -le $subpacketCount; $i++) {
                $p = Get-NextPacket -bitString $bitString -indent ($indent+1)
                $bitString = $p.bitstring
                $values += [uint64]$p.Value
                Write-Host "$("  " * $indent)-"
            }

        }

        Write-Host "$("  " * $indent)Values are $($values -join ',')"
        
        
        Switch ($packetType) {
            
            "0" {
                # SUM
                "$("  " * $indent)Getting Sum of Values"
                $val = $($values | Measure-Object -Sum).Sum
            }

            "1" {
                # PRODUCT
                "$("  " * $indent)Getting Product of Values"
                $val = 1
                $values.ForEach{ $val *= $_ }
            }

            "2" {
                # MINIMUM
                "$("  " * $indent)Getting Minimum of Values"
                $val = $($values | Measure-Object -Minimum).Minimum
            }

            "3" {
                # Maximum
                "$("  " * $indent)Getting Maximum of Values"
                $val = $($values | Measure-Object -Maximum).Maximum
            }

            "5" {
                # Val 1 > Val 2
                "$("  " * $indent)Processing Less Than Packet"
                If($values[0] -gt $values[1]) { $val = 1 } else { $val = 0 }
            }
            
            
            "6" {
                # Val 1 < Val 2
                "$("  " * $indent)Processing Greater Than Packet"
                If($values[0] -lt $values[1]) { $val = 1 } else { $val = 0 }
            }

            "7" {
                # Val 1 = Val 2
                "$("  " * $indent)Processing Greater Than Packet"
                If($values[0] -eq $values[1]) { $val = 1 } else { $val = 0 }
            }

        }

        Return [PSCustomObject]@{
            "Version" = $packetVersion
            "Type" = $packetType
            "Value" = $val
            "BitString" = $bitString
        }



    }


}

$p = Get-NextPacket $bitString

$p | FT -AutoSize
