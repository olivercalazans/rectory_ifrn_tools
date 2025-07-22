aparicao_minima = int(input('Informe a quantidade mínima de aparições: '))
dominios = {}

with open('dominios.txt', 'r', encoding='utf-8') as file:
        for line in file:
                dom = line.split(' - ')[0]
                dom = dom.split('.')
                for sub in dom:
                        if not sub in dominios:
                                dominios[sub] = 0
                        dominios[sub] += 1


lista_ordenada = dict(sorted(dominios.items(), key=lambda item: item[1], reverse=True))
len_maior_chave = len(max(dominios, key=len))


for i in lista_ordenada:
        quantidade     = lista_ordenada[i]
        if quantidade <= aparicao_minima: continue
        tamanho_lacuna = len_maior_chave - len(i)
        print(f'{i}{"." * tamanho_lacuna}: {quantidade}')
