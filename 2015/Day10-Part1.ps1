Function Get-LookAndSay {
    [CmdLetBinding()]
    Param(
        [String]$Data
    )

    Write-Verbose "Reading: $Data"

    $x = Measure-Command {
        $contents = [RegEx]::Matches($data,'(0+|1+|2+|3+|4+|5+|6+|7+|8+|9+)').Value
    }
    
    Write-Verbose "RegEx Took $($x.TotalMilliseconds)ms and returned $($contents.Count) blocks"

    $x = Measure-Command {
        [System.Collections.Generic.List[String]]$Output = @()
        ForEach($block in $contents) {
            $len = $block.Length
            $char = $block[0]
            $Output.Add("$len$char")
        }
    }
    
    Write-Verbose "Loop took $($x.TotalMilliseconds)ms and returned length $($output.Count)."

    $out = $output -join ''
    Write-Verbose "Writing: $out"
    Return $out
}

1..40 | % {
    $_
    $data = Get-LookAndSay -Data (Get-Content $PSScriptRoot\Day10-Input.txt)
}

$data.Length
