[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [ValidateRange(0,12)]
    [Int]$DayNumber
)

$ProjectFolder = Join-Path $PSScriptRoot -ChildPath $DayNumber.ToString().PadLeft(2, '0')

If(Get-Item $ProjectFolder -ErrorAction SilentlyContinue) {
    Throw "Project Folder for Day $DayNumber already exists."
}

Try {
    New-Item -ItemType Directory -Path $ProjectFolder | Out-Null
} Catch {
    Throw "Failed to create folder. $($_.Exception.Message)"
}

$ProjectCode = @'
[CmdLetBinding()]Param()

$inputFile = "$PSScriptRoot\sample.txt"
# $inputFile = "$PSScriptRoot\input.txt"
'@

Add-Content -Path "$ProjectFolder\input.txt" -Value ''
Add-Content -Path "$ProjectFolder\sample.txt" -Value ''
Add-Content -Path "$ProjectFolder\d$DayNumber`p1.ps1" -Value $ProjectCode

Start-Process code -ArgumentList "$ProjectFolder\d$DayNumber`p1.ps1"
Start-Process code -ArgumentList "$ProjectFolder\sample.txt"
Start-Process code -ArgumentList "$ProjectFolder\input.txt"

