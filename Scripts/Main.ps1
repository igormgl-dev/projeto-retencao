# Carrega os módulos necessários

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\FileManager.ps1"
. "$PSScriptRoot\RetentionManager.ps1"

Write-Host ""
Write-Host "====================================="
Write-Host " Projeto Retencao de Gravacoes"
Write-Host "====================================="
Write-Host ""

$Meses = Get-Meses -PastaGravacoes $PastaGravacoes

$Resultado = Get-Retencao -Meses $Meses -MesesParaManter $MesesParaManter

Write-Host ""
Write-Host "==============================="
Write-Host "Meses que serao mantidos"
Write-Host "==============================="
Write-Host ""

foreach($Mes in $Resultado.Manter){

    Write-Host "[MANTER] $($Mes.Name)"

}

Write-Host ""
Write-Host "==============================="
Write-Host " Meses que irao para quarentena"
Write-Host "==============================="
Write-Host ""

foreach($Mes in $Resultado.Mover){

    Write-Host "[QUARENTENA] $($Mes.Name)"

}