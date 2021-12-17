Clear-Host

Get-Variable | Remove-Variable -ErrorAction SilentlyContinue

Function DrawGrid {
    
    Param(
        $target,
        $pos
    )

    Write-Host $target.x2

    For($x = 0; $x -le $target.x2; $x++) {
        
        $grid += "."

    }

    Return $grid


}

$dataIn = "target area: x=20..30, y=-10..-5"
$dataIn = "target area: x=269..292, y=-68..-44"

$targets = [regex]::new("(?i)x=(.*?)\.\.(.*?), y=(.*?)\.\.(.*?)$").Matches($dataIn)

$target= @{}
$pos = @{}


$target.x1 = [int]$targets.groups[1].value
$target.x2 = [int]$targets.groups[2].value
$target.y1 = [int]$targets.groups[3].value
$target.y2 = [int]$targets.groups[4].value

$pos.x = 0
$pos.y = 0

$target | Out-Host
$pos | Out-Host

$stepX = 7
$stepY = 2

$i = 0

$goodTargets = @()

$highY = 0

For($startX = 0; $startX -le 100; $startX++) {
    
    For($startY = -500; $startY -le 500; $startY++) {

        $stepX = $startX
        $stepY = $startY
        $pos.X = 0
        $pos.Y = 0

        $loopHigh = 0

        While($pos.x -le $target.x2 -and $pos.y -ge $target.y1) { # While not to the right of the target
            $i++

            # Write-Host "Position $($pos.x),$($pos.y) with Step = $stepX,$stepY"
            
            If($pos.y -gt $loopHigh) { $loopHigh = $pos.y }

            # Move
            $pos.x = $pos.x + $stepX
            $pos.y = $pos.y + $stepY

            If($pos.x -in $target.x1..$target.x2 -and $pos.y -in $target.y1..$target.y2) {
                # Write-Host "Good spot at $($pos.x),$($pos.y)"
                $goodTargets += "$($startX),$($startY)"
                If($loopHigh -gt $highY) { $highY = $loopHigh }
                break
            }

            If($stepX -gt 0) { 
                $stepX--
            } elseif($stepX -lt 1) {
                $stepX++
            }

            $stepY--

            # if($i -eq 7) { break }

        }




    }
}


Write-Host "High Y is $highY"