function Backup-Mes {

    param (
        [string]$Origem,
        [string]$PastaBackup,
        [string]$NomeMes,
        [bool]$ModoSimulacao,
        [string]$PastaLogs
    )

    $Destino = Join-Path -Path $PastaBackup $NomeMes

    if ($ModoSimulacao) {

        Write-Host "[SIMULACAO] Faria backup de: $NomeMes"

        Write-Log `
            -Mensagem "Faria backup de: $NomeMes" `
            -Nivel "SIMULACAO" `
            -PastaLogs $PastaLogs

        return
    }

    if (-not (Test-Path -Path $Origem)) {

        Write-Host "[ERRO] Pasta de origem nao encontrada: $NomeMes"

        Write-Log `
            -Mensagem "Pasta de origem nao encontrada: $NomeMes" `
            -Nivel "ERRO" `
            -PastaLogs $PastaLogs

        return
    }

    if (-not (Test-Path -Path $PastaBackup)) {

        New-Item -Path $PastaBackup -ItemType Directory | Out-Null

        Write-Host "[INFO] Pasta de backup criada"
    }

    if (Test-Path -Path $Destino) {

        Write-Host "[INFO] Backup ja existe: $NomeMes"

        Write-Log `
            -Mensagem "Backup ja existe: $NomeMes" `
            -Nivel "INFO" `
            -PastaLogs $PastaLogs

        return
    }

    try {

        Copy-Item `
            -Path $Origem `
            -Destination $Destino `
            -Recurse `
            -ErrorAction Stop

        Write-Host "[SUCESSO] Backup realizado com sucesso: $NomeMes"

        Write-Log `
            -Mensagem "Backup realizado com sucesso: $NomeMes" `
            -Nivel "SUCESSO" `
            -PastaLogs $PastaLogs

    }
    catch {

        Write-Host "[ERRO] Falha ao realizar backup: $NomeMes"

        Write-Host "[ERRO] Detalhes: $($_.Exception.Message)"

        Write-Log `
            -Mensagem "Falha ao realizar backup: $NomeMes | $($_.Exception.Message)" `
            -Nivel "ERRO" `
            -PastaLogs $PastaLogs
    }
}

function Test-Backup {

    param (
        [string]$Origem,
        [string]$Backup,
        [string]$PastaLogs
    )


    if (-not (Test-Path -Path $Origem)) {

        Write-Host "[ERRO] Origem nao encontrada para validacao"

        Write-Log `
            -Mensagem "Origem nao encontrada para validacao: $Origem" `
            -Nivel "ERRO" `
            -PastaLogs $PastaLogs

        return $false
    }

    if (-not (Test-Path -Path $Backup)) {

        Write-Host "[ERRO] Backup nao encontrado para validacao"

        Write-Log `
            -Mensagem "Backup nao encontrado para validacao: $Backup" `
            -Nivel "ERRO" `
            -PastaLogs $PastaLogs

        return $false
    }

    $Origem = (Resolve-Path -Path $Origem).Path
    $Backup = (Resolve-Path -Path $Backup).Path

    $ArquivosOrigem = @(Get-ChildItem -Path $Origem -File -Recurse)
    $ArquivosBackup = @(Get-ChildItem -Path $Backup -File -Recurse)

    if ($ArquivosOrigem.Count -ne $ArquivosBackup.Count) {

        Write-Host "[ERRO] Quantidade de arquivos diferente entre origem e backup"
        Write-Host "[ERRO] Origem: $($ArquivosOrigem.Count) arquivos"
        Write-Host "[ERRO] Backup: $($ArquivosBackup.Count) arquivos"

        Write-Log `
            -Mensagem "Quantidade de arquivos diferente | Origem: $($ArquivosOrigem.Count) | Backup: $($ArquivosBackup.Count)" `
            -Nivel "ERRO" `
            -PastaLogs $PastaLogs

        return $false
    }

    Write-Host "[VALIDADO] Quantidade de arquivos corresponde"

    Write-Log `
        -Mensagem "Quantidade de arquivos corresponde" `
        -Nivel "VALIDADO" `
        -PastaLogs $PastaLogs

    foreach ($ArquivoOrigem in $ArquivosOrigem) {
        $CaminhoRelativo = $ArquivoOrigem.FullName.Substring($Origem.Length).TrimStart('\')

        $CaminhoBackup = Join-Path $Backup $CaminhoRelativo

        if (-not (Test-Path -Path $CaminhoBackup)) {

            Write-Host "[ERRO] Arquivo nao encontrado no backup: $CaminhoRelativo"

            Write-Log `
                -Mensagem "Arquivo nao encontrado no backup: $CaminhoRelativo" `
                -Nivel "ERRO" `
                -PastaLogs $PastaLogs

            return $false
        }

        $ArquivoBackup = Get-Item -Path $CaminhoBackup
             
        if ($ArquivoOrigem.Length -ne $ArquivoBackup.Length) {

            Write-Host "[ERRO] Tamanho de arquivo diferente: $CaminhoRelativo"

            Write-Host "[ERRO] Origem: $($ArquivoOrigem.Length) bytes"

            Write-Host "[ERRO] Backup: $($ArquivoBackup.Length) bytes"

            Write-Log `
                -Mensagem "Tamanho diferente: $CaminhoRelativo | Origem: $($ArquivoOrigem.Length) bytes | Backup: $($ArquivoBackup.Length) bytes" `
                -Nivel "ERRO" `
                -PastaLogs $PastaLogs

            return $false
        }

        $HashOrigem = (Get-FileHash -Path $ArquivoOrigem.FullName -Algorithm SHA256).Hash
        $HashBackup = (Get-FileHash -Path $ArquivoBackup.FullName -Algorithm SHA256).Hash

        if ($HashOrigem -ne $HashBackup) {

            Write-Host "[ERRO] Hash diferente: $CaminhoRelativo"

            Write-Host "[ERRO] Origem: $HashOrigem"
            Write-Host "[ERRO] Backup: $HashBackup"

            Write-Log `
                -Mensagem "Hash diferente: $CaminhoRelativo" `
                -Nivel "ERRO" `
                -PastaLogs $PastaLogs

            return $false
        }

        Write-Host "[VALIDADO] Hash corresponde: $CaminhoRelativo"

        Write-Log `
            -Mensagem "Hash corresponde: $CaminhoRelativo" `
            -Nivel "VALIDADO" `
            -PastaLogs $PastaLogs
    }

    Write-Host "[VALIDADO] Backup correspondente a origem"

    Write-Log `
        -Mensagem "Backup correspondente a origem" `
        -Nivel "VALIDADO" `
        -PastaLogs $PastaLogs

    return $true
}

function Test-HashArquivo {

    param (
        [string]$Origem,
        [string]$Backup
    )

    $HashOrigem = (Get-FileHash -Path $Origem -Algorithm SHA256).Hash
    $HashBackup = (Get-FileHash -Path $Backup -Algorithm SHA256).Hash

    if ($HashOrigem -ne $HashBackup) {

        Write-Host "[ERRO] Hash diferente entre origem e backup"
        Write-Host "[ERRO] Arquivo: $Origem"

        Write-Host "[ERRO] Origem: $HashOrigem"
        Write-Host "[ERRO] Backup: $HashBackup"

        return $false
    }

    Write-Host "[VALIDADO] Hash corresponde: $Origem"

    return $true
}