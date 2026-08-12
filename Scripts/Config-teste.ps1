# ========================
# Configuração do ambiente de teste
# ========================

$Projetos = split-path $PSScriptRoot -Parent

$PastaTeste = Join-path $Projetos "TesteMovimentacao"

$PastaGravacoes = Join-path $PastaTeste "Gravacoes"
$PastaQuarentena = Join-path $PastaTeste "Quarentena"
$PastaLogs = Join-path $PastaTeste "Logs"

$MesesParaManter = 3


# Seguranca
$ModoSimulacao = $false