$VerbosePreference = 'SilentlyContinue'

[Array]$Repositories = @(
    'https://github.com/theznerd/AdventOfCode.git'
    'https://github.com/indented-automation/AoC.git'
    'https://github.com/Kooties/AdventOfCode.git'
    'https://github.com/jputman/AdventOfCode.git'
    'https://github.com/ajf8729/Advent-of-Code.git'
    'https://github.com/ChrisKibble/Advent-of-Code.git'
)

$TargetFolder = Join-Path $env:temp -ChildPath "AoC"
If(-Not(Test-Path $TargetFolder -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path $TargetFolder | Out-Null }

[System.Collections.Generic.List[String]]$LocalRepositories = @()

ForEach($repository in $Repositories) {
    $Author = $($Repository -split '/')[3]

    $RepoPath = Join-Path $TargetFolder -ChildPath $Author
    If(Test-Path $RepoPath) {
        $RepoPath = Get-ChildItem $RepoPath -Directory | Select-Object -First 1 -ExpandProperty FullName
        $lastHead = Join-Path $RepoPath -ChildPath ".git\HEAD"
        If((Get-ChildItem $LastHead).LastWriteTime -ge ((Get-Date).AddHours(-4))) {
            Write-Verbose "Already updated in past 4 hours."
        } Else {
            Write-Verbose "Running Pull in $RepoPath"
            Start-Process git.exe -ArgumentList 'pull' -WorkingDirectory $RepoPath -NoNewWindow -Wait -Verbose    
        }
        $LocalRepositories.Add($RepoPath)
    } Else {
        New-Item -ItemType Directory -Path $RepoPath | Out-Null
        Write-Verbose "Running Clone $repository in $RepoPath"
        Start-Process git.exe -ArgumentList "clone $repository" -WorkingDirectory $RepoPath -NoNewWindow -Wait -Verbose
        $RepoPath = Get-ChildItem $RepoPath -Directory | Select-Object -First 1 -ExpandProperty FullName
        $LocalRepositories.Add($RepoPath)
    }
}

ForEach($CodeBase in $LocalRepositories) {
    
    Write-Output "Processing $CodeBase"

    $ByYear = Join-Path $CodeBase -ChildPath '2024'
    
    If(Get-ChildItem $ByYear -ErrorAction SilentlyContinue) {
        Write-Verbose "Repository appears to use use year folders."
        $CodeBase = $ByYear
    } Else {
        Write-Error "Not using ByYear, will need to come back and adjust this for other common methods."
        continue
    }

    $children = Get-ChildItem $CodeBase

    $DayFolders = @{}

    If($children.where{ $_.PSIsContainer }.Name -contains '01') {
        Write-Verbose "Repository using 'dd' style folders"
        1..31 | ForEach-Object { 
            $DayFolders.$_ = Join-Path $CodeBase -ChildPath $("{0:D2}" -f $_)
        }
    } ElseIf($children.where{ $_.PSIsContainer }.Name -contains '1') {
        Write-Verbose "Repository using 'd' style folders"
        1..31 | ForEach-Object { 
            $DayFolders.$_ = Join-Path $CodeBase -ChildPath $_
        }
    } ElseIf($children.where{ $_.PSIsContainer }.Name -contains 'Day01') {
        Write-Verbose "Repository using 'Day|dd|' style folders"
        1..31 | ForEach-Object { 
            $DayFolders.$_ = Join-Path $CodeBase -ChildPath "Day$("{0:D2}" -f $_)"
        }
    } ElseIf($children.where{ $_.PSIsContainer }.Name -contains 'Day1') {
        Write-Verbose "Repository using 'Day|d|' style folders"
        1..31 | ForEach-Object { 
            $DayFolders.$_ = Join-Path $CodeBase -ChildPath "Day$_"
        }
    } ElseIf($Children.where{ -not $_.PSIsContainer -and $_.Extension -eq '.ps1' }) {
        Write-Error "Repository is using scripts written right to the root like mad men!"
        continue
    } Else {
        Write-Error "Not sure how days are being broken out. Come back and adjust."
        continue
    }

    For($day = 1; $day -le (Get-date -Format 'dd') -as [int]; $day++) {
        $FolderForToday = $DayFolders.$Day
        $scripts = Get-ChildItem $FolderForToday -Filter "*.ps1" -ErrorAction SilentlyContinue -Recurse
        Write-Output "$FolderForToday - $($scripts.count)"
        
        # If there is only one script, assume it's the first part

    }

    Write-Output  "--"
    
}
