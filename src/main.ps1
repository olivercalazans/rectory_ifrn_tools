Add-Type -AssemblyName System.Windows.Forms


$dialogo        = New-Object System.Windows.Forms.OpenFileDialog
$dialogo.Filter = "CSV Files (*.csv)|*.csv"
$dialogo.Title  = "Selecione um arquivo CSV"


if ($dialogo.ShowDialog() -eq "OK") {
    $arquivoCSV = $dialogo.FileName
    Write-Host "`nArquivo selecionado:`n$arquivoCSV`n"


    $linhas = Get-Content $arquivoCSV

    foreach ($linha in $linhas) {
        if ($linha.Trim() -ne "") {
            $primeiroValor = ($linha -split ",")[0].Trim()
            if ($primeiroValor -ne "") {
                Write-Host "mail=$primeiroValor"
            }
        }
    }
}
else {
    Write-Host "Nenhum arquivo foi selecionado."
}
