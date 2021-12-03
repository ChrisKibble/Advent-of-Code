$data = Get-Content $PSScriptRoot\Day1-Input.txt

$position = 0

For($i = 0; $i -lt $data.Length; $i++) {
    
    Switch($data[$i]) {
        "(" { $position++ }
        ")" { $position-- }
    }

    if($position -lt 0) {
        Write-Host "Basement as Position $($i+1)"
        break
    }

}

