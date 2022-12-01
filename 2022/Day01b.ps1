Function Get-ElfCalories { 
    [CmdLetBinding()]
    Param(
        [String]$Calories
    )
    
    $DoubleNewLine = $([Environment]::NewLine)*2

    $Calories -split $DoubleNewLine | ForEach-Object {
        $CalorieList = [Array]$_ -split [System.Environment]::NewLine
        [PSCustomObject]@{
            CalorieList = $CalorieList
            TotalCalories = $($CalorieList | Measure-Object -Sum).Sum
        }
    }
}

Function Get-ElfWithMostCalories {
    [CmdLetBinding()]
    Param(
        [PSCustomObject[]]$ElfList,
        [Int]$Top = 1
    )

    $($ElfList | Sort-Object TotalCalories -Descending | Select-Object -ExpandProperty TotalCalories -First $Top | Measure-Object -Sum).Sum

}

$ElfList = Get-ElfCalories -Calories (Get-Content $PSScriptRoot\Day01-Input.txt -Raw)
Get-ElfWithMostCalories -ElfList $ElfList -Top 3


