import csv
import tkinter as tk
from tkinter import filedialog

root = tk.Tk()
root.withdraw()

caminho_arquivo = filedialog.askopenfilename(title="Selecione um arquivo")

quantidade = 0 
alunos = []


with open(caminho_arquivo, newline='', encoding='utf-8') as csvfile:
    leitor = csv.reader(csvfile, delimiter=',')
    
    for linha in leitor:
        if linha[-1] == 'Concluída' or 'EXT' in linha[1]:
            continue
        quantidade += 1
        alunos.append(linha)


with open('alunos.csv', 'w', newline='', encoding='utf-8') as arquivo:
    escritor = csv.writer(arquivo)
    escritor.writerows(alunos) 

print(f'Quantidade: {quantidade}')