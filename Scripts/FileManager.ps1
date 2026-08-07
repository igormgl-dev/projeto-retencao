function Get-Meses {

    param(
        [string]$PastaGravacoes
    )

    $Pastas = Get-ChildItem -Path $PastaGravacoes -Directory | Sort-Object Name

    $Resultado = @()

    foreach ($Pasta in $Pastas){

        $Resultado += [PSCustomObject]@{

            Name = $Pasta.Name
            Caminho = $Pasta.FullName

        }

    }

    return $Resultado

}