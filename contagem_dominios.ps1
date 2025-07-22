$aparicao_minima = Read-Host "Informe a quantidade minima de aparicoes"
$aparicao_minima = [int]$aparicao_minima

$dominios = @{}

Get-Content "dominios.txt" | ForEach-Object {
    $linha = $_
    $dom = $linha -split " - " | Select-Object -First 1
    $subdominios = $dom -split '\.'

    foreach ($sub in $subdominios) {
        if (-not $dominios.ContainsKey($sub)) {
            $dominios[$sub] = 0
        }
        $dominios[$sub]++
    }
}

# Ordena o dicionário por valor decrescente
$lista_ordenada = $dominios.GetEnumerator() | Sort-Object Value -Descending

# Encontra o tamanho da maior chave
$len_maior_chave = ($dominios.Keys | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

foreach ($item in $lista_ordenada) {
    $chave = $item.Key
    $quantidade = $item.Value

    if ($quantidade -le $aparicao_minima) { continue }

    $tamanho_lacuna = $len_maior_chave - $chave.Length
    $pontos = "." * $tamanho_lacuna
    Write-Output ("{0}{1}: {2}" -f $chave, $pontos, $quantidade)
}
