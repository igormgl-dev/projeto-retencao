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

if ($Meses.Count -eq 0){

    Write-Host ""
    Write-Host "Nenhum mes encontrado na pasta de gravacoes."
    Write-Host ""

    return
}

$Resultado = Get-Retencao -Meses $Meses -MesesParaManter $MesesParaManter

Write-Host ""
Write-Host "Modo de execucao:"

if($ModoSimulacao){
    write-host "[SIMULACAO] Nenhuma acao sera tomada, apenas exibindo o resultado da retencao"
}
else {
    write-host "[EXECUCAO] As acoes serao executadas de fato"
}
write-host ""

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

Move-ParaQuarentena -Meses $Resultado.Mover -PastaQuarentena $PastaQuarentena -ModoSimulacao $ModoSimulacao
