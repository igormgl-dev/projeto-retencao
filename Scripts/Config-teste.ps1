# ========================
# Configuração do ambiente de teste
# ========================

$Projetos = split-path $PSScriptRoot -Parent

$PastaTeste = Join-path $Projetos "TesteMovimentacao"

$PastaGravacoes = Join-Path $PastaTeste "Gravacoes"
$PastaQuarentena = Join-Path $PastaTeste "Quarentena"
$PastaLogs = Join-Path $PastaTeste "Logs"
$PastaBackup = Join-Path $PastaTeste "BackupHash"

$MesesParaManter = 3


# Seguranca
$ModoSimulacao = $false
