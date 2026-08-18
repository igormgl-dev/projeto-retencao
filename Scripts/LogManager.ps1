function Write-Log {

    param (
        [string]$Mensagem,
        [ValidateSet("INFO", "SIMULACAO", "VALIDADO", "SUCESSO", "ERRO")]
        [string]$Nivel = "INFO",
        [string]$PastaLogs
    )

    if (-not (Test-Path -Path $PastaLogs)) {

        New-Item `
            -Path $PastaLogs `
            -ItemType Directory | Out-Null
    }

    $DataHora = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $DataArquivo = Get-Date -Format "yyyy-MM-dd"

    $ArquivoLog = Join-Path $PastaLogs "retencao-$DataArquivo.log"

    $LinhaLog = "[$DataHora] [$Nivel] $Mensagem"

    Add-Content `
        -Path $ArquivoLog `
        -Value $LinhaLog `
        -Encoding UTF8
}