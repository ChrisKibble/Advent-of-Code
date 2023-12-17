Clear-Host
Get-Date
Write-Host '-------'

Function Get-DeckData {
    [CmdLetBinding()]
    Param(
        [String[]]$Data
    )

    ForEach($Round in $Data) {
        [PSCustomObject]@{
            Hand = [String]$Round.Substring(0,5)
            Wager = [Int]$Round.Substring(6)
        }
    }
}

Function Get-HandType {

    [CmdLetBinding()]
    Param(
        $Hand
    )

    Write-Verbose "Getting Hand Type of $Hand"

    $Cards = $Hand.ToCharArray()

    [Array]$CardGroups = $Cards | Group-Object | Sort-Object Count -Descending
    
    Switch($CardGroups.Count) {
        1 { Return "FiveOfKind"}
        2 {
            If($CardGroups[0].Count -eq 4) { 
                Return "FourOfKind"
            } ElseIf($CardGroups[0].Count -eq 3) {
                Return "FullHouse"
            } Else {
                Return "Dunno" # Shouldn't happen... I don't think...
            }
        }
        3 {
            If($cardGroups[0].Count -eq 3) {
                Return "ThreeOfKind"
            } ElseIf($CardGroups[0].Count -eq 2) {
                Return "TwoPair"
            } Else {
                Return "Dunno" # Shouldn't happen... I don't think...
            }
        }
        4 { Return "Pair"}
        5 { Return "HighCard"}
    }

    Return "Dunno" # Shouldn't ever come to this...
}

Function Get-HandSortValue {

    [CmdletBinding()]
    Param(
        [String]$Hand
    )

    $CardRanks = (2..9).ForEach{ [String]$_ } + @("T", "J", "Q", "K", "A")
    $Cards = $Hand.ToCharArray()

    Write-Verbose "Hand is $Hand"
    
    $placeValue = 1
    $handValue = 0
    
    For($index = $cards.count-1; $index -ge 0; $index--) {
        [String]$thisCard = $cards[$index]
        $rankValue = $CardRanks.IndexOf($thisCard) + 1
        Write-Verbose $thisCard
        Write-verbose "Rank Value is $rankValue"
        $HandValue += $placeValue * $rankValue
        Write-Verbose "New Hand Value is $handValue"
        $placeValue = $placeValue * 100
    }

    Return $handValue
}

$HandRanks = @("FiveOfKind", "FourOfKind", "FullHouse", "ThreeOfKind", "TwoPair", "Pair", "HighCard")

$Data = Get-Content $PSScriptRoot\Input.txt

$DeckData = Get-DeckData $Data -Verbose

$HandList = $DeckData.ForEach{
    $HandType = Get-HandType $_.Hand
    $HandValue = Get-HandSortValue $_.Hand
    [PSCustomObject]@{
        Hand = $_.Hand
        HandType = $HandType
        HandValue = $HandValue
        Wager = $_.Wager
    }
}

$HandList = $HandList | Sort-Object -Property @{Expression={$HandRanks.IndexOf($_.HandType)}; Descending=$True}, @{Expression={$_.HandValue}; Descending=$False}

$index = 0
$HandList.ForEach{
    $index++
    $_.Wager * $index
} | Measure-Object -Sum | Select-Object -ExpandProperty Sum



