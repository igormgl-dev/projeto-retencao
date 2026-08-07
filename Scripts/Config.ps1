# ===========================
# CONFIGURAÇOES DO PROJETO
# ===========================

# Caminho da raiz do projeto
$Projeto = Split-path $PSScriptRoot -Parent

# Pastas principais
$PastaGravacoes = Join-path $Projeto "Gravacoes"
$PastaQuarentena = Join-path $Projeto "Quarentena"
$PastaLogs = Join-path $Projeto "Logs"

# Configurações de retenção
$MesesParaManter = 3

# Segurança
$ModoSimulacao = $true
