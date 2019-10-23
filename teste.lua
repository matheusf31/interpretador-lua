teste = "if 1 == 1" -- regex pro comparador
regex = "==?>?<?!=?"
cmp = string.match(teste, regex) -- vou armazenar o comparador que está na linha
print(cmp)