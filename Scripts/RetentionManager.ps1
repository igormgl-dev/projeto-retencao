function Get-Retencao {

    param(
        [array]$Meses,
        [int]$MesesParaManter
    )

    $Quantidade = $Meses.Count

    if ($Quantidade -le $MesesParaManter) {

        return @{
            Manter = $Meses
            Mover  = @()
        }

    }

    $Manter = $Meses | Select-Object -Last $MesesParaManter
    $Mover  = $Meses | Select-Object -First ($Quantidade - $MesesParaManter)

    return @{
        Manter = $Manter
        Mover  = $Mover
    }

}