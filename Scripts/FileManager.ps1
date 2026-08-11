function Get-Meses {

    param(
        [string]$PastaGravacoes
    )

    $Pastas = Get-ChildItem -Path $PastaGravacoes -Directory | Sort-Object Name

    $Resultado = @()

    foreach ($Pasta in $Pastas) {

        $Resultado += [PSCustomObject]@{

            Name    = $Pasta.Name
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

    if ($ModoSimulacao) {
        foreach ($Mes in $Meses) {

            Write-Host "[SIMULACAO] Moveria: $($Mes.Name)"
        }

        return

    }

    if ( -not (Test-Path -Path $PastaQuarentena)) {

        New-Item -Path $PastaQuarentena -ItemType Directory | Out-Null

        Write-Host "[INFO] Pasta de quarentena criada"
    }

    foreach ($Mes in $Meses) {

        $Origem = $Mes.Caminho
        $Destino = Join-Path $PastaQuarentena $Mes.Name

        if (-not (Test-Path -Path $Origem)) {

            Write-Host "[ERRO] Pasta de origem não encontrada: $($Mes.Name)"

            continue
        }

        Write-Host "[Validado] Pasta de origem encontrada: $($Mes.Name)"

        if (Test-Path -Path $Destino) {
            Write-Host "[INFO] Pasta de destino já existe na quarentena: $($Mes.Name)"

            continue
        }

        Write-Host "[Validado] Destino disponível. Pronto para mover: $($Mes.Name)"
    }
}