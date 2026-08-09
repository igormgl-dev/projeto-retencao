function Get-Meses {

    param(
        [string]$PastaGravacoes
    )

    $Pastas = Get-ChildItem -Path $PastaGravacoes -Directory | Sort-Object Name

    $Resultado = @()

    foreach ($Pasta in $Pastas){

        $Resultado += [PSCustomObject]@{

            Name = $Pasta.Name
            Caminho = $Pasta.FullName

        }

    }

    return $Resultado

}

function Move-ParaQuarentena {

    param(
        [array]$Meses,
        [string]$PastaQuarentena,
        [bool]$ModoSimulacao
    )

    foreach ($Mes in $Meses) {

        if ($ModoSimulacao) {

            Write-Host "[SIMULACAO] Moveria: $($Mes.Name)"

        }
        else {

            Write-Host "[EXECUCAO] Movendo: $($Mes.Name)"

        }

    }

}