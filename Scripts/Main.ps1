# Carrega os módulos necessários

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\FileManager.ps1"
. "$PSScriptRoot\RetentionManager.ps1"
. "$PSScriptRoot\BackupManager.ps1"
. "$PSScriptRoot\LogManager.ps1"

Write-Host ""
Write-Host "====================================="
Write-Host " Projeto Retencao de Gravacoes"
Write-Host "====================================="
Write-Host ""

Write-Log `
    -Mensagem "Execucao iniciada" `
    -Nivel "INFO" `
    -PastaLogs $PastaLogs

$Meses = Get-Meses -PastaGravacoes $PastaGravacoes

if ($Meses.Count -eq 0) {

    Write-Host ""
    Write-Host "Nenhum mes encontrado na pasta de gravacoes."
    Write-Host ""

    return
}

$Resultado = Get-Retencao `
    -Meses $Meses `
    -MesesParaManter $MesesParaManter

Write-Host ""
Write-Host "Modo de execucao:"

if ($ModoSimulacao) {

    Write-Host "[SIMULACAO] Nenhuma acao sera tomada, apenas exibindo o resultado da retencao"

    Write-Log `
        -Mensagem "Modo de execucao: SIMULACAO" `
        -Nivel "INFO" `
        -PastaLogs $PastaLogs

}
else {

    Write-Host "[EXECUCAO] As acoes serao executadas de fato"

    Write-Log `
        -Mensagem "Modo de execucao: EXECUCAO REAL" `
        -Nivel "INFO" `
        -PastaLogs $PastaLogs
}

Write-Host ""

Write-Host "==============================="
Write-Host "Meses que serao mantidos"
Write-Host "==============================="
Write-Host ""

foreach ($Mes in $Resultado.Manter) {

    Write-Host "[MANTER] $($Mes.Name)"

    Write-Log `
        -Mensagem "Mes mantido: $($Mes.Name)" `
        -Nivel "INFO" `
        -PastaLogs $PastaLogs

}

Write-Host ""
Write-Host "==============================="
Write-Host "Meses que irao para quarentena"
Write-Host "==============================="
Write-Host ""

foreach ($Mes in $Resultado.Mover) {

    Write-Host ""
    Write-Host "Processando: $($Mes.Name)"

    Write-Log `
        -Mensagem "Processando mes: $($Mes.Name)" `
        -Nivel "INFO" `
        -PastaLogs $PastaLogs

    Backup-Mes `
        -Origem $Mes.Caminho `
        -PastaBackup $PastaBackup `
        -NomeMes $Mes.Name `
        -ModoSimulacao $ModoSimulacao `
        -PastaLogs $PastaLogs

    if ($ModoSimulacao) {

        Write-Host "[SIMULACAO] Faria validacao do backup: $($Mes.Name)"

    }
    else {

        $BackupMes = Join-Path $PastaBackup $Mes.Name

        if (-not (Test-Path -Path $BackupMes)) {

            Write-Host "[ERRO] Backup nao encontrado. Movimentacao cancelada: $($Mes.Name)"

            continue
        }

        $BackupValido = Test-Backup `
            -Origem $Mes.Caminho `
            -Backup $BackupMes `
            -PastaLogs $PastaLogs

        if (-not $BackupValido) {

            Write-Host "[ERRO] Backup nao aprovado. Movimentacao cancelada: $($Mes.Name)"

            continue
        }

        Write-Host "[VALIDADO] Backup aprovado: $($Mes.Name)"
    }

    Move-ParaQuarentena `
        -Meses @($Mes) `
        -PastaQuarentena $PastaQuarentena `
        -ModoSimulacao $ModoSimulacao `
        -PastaLogs $PastaLogs
}

Write-Log `
    -Mensagem "Execucao finalizada" `
    -Nivel "INFO" `
    -PastaLogs $PastaLogs