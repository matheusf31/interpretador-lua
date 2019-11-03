-- function removeElementoDaPilha(nome da funcao)
--     copiapilha = pilha
--     pilha = {}



--     while   do
--         if copiapilha = {} == nome da funcao
--             -- nao coloco ele
--         else
--             pilha[#pilha] = copiapilha = {}
--         end
--     end
-- end
pilha = {}

pilha[1] = 'main'
pilha[2] = 'teste'
pilha[3] = 'teste2'

print(#pilha)

pilha[3] = nil

print(#pilha)
print(pilha[1],pilha[2],pilha[3])