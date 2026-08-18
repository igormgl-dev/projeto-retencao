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
        [bool]$ModoSimulacao,
        [string]$PastaLogs
    )

    if ($ModoSimulacao) {

        foreach ($Mes in $Meses) {

            Write-Host "[SIMULACAO] Moveria: $($Mes.Name)"

            Write-Log `
                -Mensagem "Moveria para quarentena: $($Mes.Name)" `
                -Nivel "SIMULACAO" `
                -PastaLogs $PastaLogs
        }

        return
    }

    if ( -not (Test-Path -Path $PastaQuarentena)) {

        New-Item -Path $PastaQuarentena -ItemType Directory | Out-Null

        Write-Host "[INFO] Pasta de quarentena criada"

        Write-Log `
            -Mensagem "Pasta de quarentena criada: $PastaQuarentena" `
            -Nivel "INFO" `
            -PastaLogs $PastaLogs
    }

    foreach ($Mes in $Meses) {

        $Origem = $Mes.Caminho
        $Destino = Join-Path $PastaQuarentena $Mes.Name

        if (-not (Test-Path -Path $Origem)) {

            Write-Host "[ERRO] Pasta de origem não encontrada: $($Mes.Name)"

            Write-Log `
                -Mensagem "Pasta de origem nao encontrada: $($Mes.Name)" `
                -Nivel "ERRO" `
                -PastaLogs $PastaLogs

            continue
        }

        Write-Host "[Validado] Pasta de origem encontrada: $($Mes.Name)"

        Write-Log `
            -Mensagem "Pasta de origem encontrada: $($Mes.Name)" `
            -Nivel "VALIDADO" `
            -PastaLogs $PastaLogs

        if (Test-Path -Path $Destino) {
            Write-Host "[INFO] Pasta de destino ja existe na quarentena: $($Mes.Name)"

            Write-Log `
                -Mensagem "Destino ja existe na quarentena: $($Mes.Name)" `
                -Nivel "INFO" `
                -PastaLogs $PastaLogs

            continue
        }

        Write-Host "[Validado] Destino disponivel. Pronto para mover: $($Mes.Name)"

        try {
            Move-Item -Path $Origem -Destination $Destino -ErrorAction Stop

            Write-Host "[Sucesso] Pasta movida para quarentena: $($Mes.Name)"    

            Write-Log `
                -Mensagem "Pasta movida para quarentena: $($Mes.Name)" `
                -Nivel "SUCESSO" `
                -PastaLogs $PastaLogs
        }
        catch {
            Write-Host "[Erro] Falha ao mover pasta para quarentena: $($Mes.Name)"
            Write-Host "[Erro] Detalhes: $($_.Exception.Message)"

            Write-Log `
                -Mensagem "Falha ao mover para quarentena: $($Mes.Name) | $($_.Exception.Message)" `
                -Nivel "ERRO" `
                -PastaLogs $PastaLogs
        }

    }
}