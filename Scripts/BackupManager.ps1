function Backup-Mes {

    param (
        [string]$Origem,
        [string]$PastaBackup,
        [string]$NomeMes,
        [bool]$ModoSimulacao
    )

    $Destino = Join-Path -Path $PastaBackup $NomeMes

    if ($ModoSimulacao) {

        Write-Host "[SIMULACAO] Faria backup de: $NomeMes"

        return
    }

    if (-not (Test-Path -Path $Origem)) {

        Write-Host "[ERRO] Pasta de origem nao encontrada: $NomeMes"

        return
    }

    if (-not (Test-Path -Path $PastaBackup)) {

        New-Item -Path $PastaBackup -ItemType Directory | Out-Null

        Write-Host "[INFO] Pasta de backup criada"
    }

    if (Test-Path -Path $Destino) {

        Write-Host "[INFO] Backup ja existe: $NomeMes"

        return
    }

    try {

        Copy-Item `
            -Path $Origem `
            -Destination $Destino `
            -Recurse `
            -ErrorAction Stop

        Write-Host "[SUCESSO] Backup realizado com sucesso: $NomeMes"

    }
    catch {

        Write-Host "[ERRO] Falha ao realizar backup: $NomeMes"

        Write-Host "[ERRO] Detalhes: $($_.Exception.Message)"
    }
}

function Testar-Backup {

    param (
        [string]$Origem,
        [string]$Backup
    )


    if (-not (Test-Path -Path $Origem)) {

        Write-Host "[ERRO] Origem nao encontrada para validacao"

        return $false
    }

    if (-not (Test-Path -Path $Backup)) {

        Write-Host "[ERRO] Backup nao encontrado para validacao"

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

        return $false
    }

    Write-Host "[VALIDADO] Quantidade de arquivos corresponde"

    foreach ($ArquivoOrigem in $ArquivosOrigem) {
        $CaminhoRelativo = $ArquivoOrigem.FullName.Substring($Origem.Length).TrimStart('\')

        $CaminhoBackup = Join-Path $Backup $CaminhoRelativo

        if (-not (Test-Path -Path $CaminhoBackup)) {

            Write-Host "[ERRO] Arquivo nao encontrado no backup: $CaminhoRelativo"

            return $false
        }

        $ArquivoBackup = Get-Item -Path $CaminhoBackup
             
        if ($ArquivoOrigem.Length -ne $ArquivoBackup.Length) {

            Write-Host "[ERRO] Tamanho de arquivo diferente: $CaminhoRelativo"

            Write-Host "[ERRO] Origem: $($ArquivoOrigem.Length) bytes"

            Write-Host "[ERRO] Backup: $($ArquivoBackup.Length) bytes"

            return $false
        }

        $HashOrigem = (Get-FileHash -Path $ArquivoOrigem.FullName -Algorithm SHA256).Hash
        $HashBackup = (Get-FileHash -Path $ArquivoBackup.FullName -Algorithm SHA256).Hash

        if ($HashOrigem -ne $HashBackup) {

            Write-Host "[ERRO] Hash diferente: $CaminhoRelativo"

            Write-Host "[ERRO] Origem: $HashOrigem"
            Write-Host "[ERRO] Backup: $HashBackup"

            return $false
        }

        Write-Host "[VALIDADO] Hash corresponde: $CaminhoRelativo"
    }

    Write-Host "[VALIDADO] Backup correspondente a origem"

    return $true
}

function Testar-HashArquivo {

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