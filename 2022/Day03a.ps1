
Get-Content $PSScriptRoot\Day03-Sample.txt | ForEach-Object {
    $GroupA = $_.Substring(0,$_.Length/2).ToCharArray()
    $GroupB = $_.Substring($_.Length/2).ToCharArray()
    [Array]$DuplicateChars = Compare-Object $GroupA $GroupB -IncludeEqual -ExcludeDifferent -CaseSensitive | Select-Object -ExpandProperty InputObject
    $DuplicateChars | Out-Host
}