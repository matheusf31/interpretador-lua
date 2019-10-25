tabelafuncoes = {}
pilha = {}


--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = "./Testes/teste.txt"
if not filename then
   print("Usage: lua interpretador.lua <prog.bpl>")
   os.exit(1)
end

local file = io.open(filename, "r")
if not file then
   print(string.format("[ERRO] Cannot open file %q", filename))
   os.exit(1)
end


-- ### REGEX ###


--
-- regex para comparação
--
function regexComparacao(line)
  local comp = "==" -- regex pra igualdade
  local cmp = string.match(line, comp) -- vou armazenar o comparador em cmp
  
  if cmp ~= nil then
    return cmp
  end

  if cmp == nil then
    comp = "!="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = ">="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = "<="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = "<"
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = ">"
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end
end


--
-- regex para declaração de função
--
function regexDeclaracaoFuncao(line)
	local str0 = "(function%s+(%l+)%(%l*,?%l*,?%l*%))"
  
  -- retorno0 recebe a string completa
  -- retorno1 recebe o nome da função que está sendo atribuída, para depois decidir se ela é main ou não
	local assinatura, nomefuncao = string.match(line,str0)	
	
	if nomefuncao == "main" then
		tabelafuncoes["main"] = {}
    pilha[#pilha+1] = "main"
    tabelafuncoes["main"]["numVariaveisNaTabela"] = 0
    return "main" -- olhar depois
  else
		return assinatura
	end
end


--
-- regex para identificar chamadas de funções
--
function regexChamadaFuncao(line)
	local str0 = "((%l+)%((%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?)%))" 
  
  -- retorno0 recebe a string completa, recebe a assinatura da função completa, seja ela print ou não
  -- retorno1 recebe o nome da função, para assim fazer a comparação e decidir se ela é print ou não
	local assinatura, nomefuncao, p1, p2, p3 = string.match(line,str0)	

  tabelafuncoes[nomefuncao] = {}

	print(assinatura,nomefuncao,p1,p2,p3)
	
	if retorno1 == "print" then
		--Chamar interpretação do print
	else
		return assinatura
	end
end


--
-- regex do if
--
function regexIf(line)
  local str, str2, str3, str4, str5 -- regex
  local verificaIf, verificaElse, ladoesquerdo, ladodireito, cmp -- variaveis

  -- identifica se é um if
  str = "if"
  verificaIf = string.match(line, str)
  
  -- identifica o lado esquerdo da operaçao                               
  str2 = "if%s+(%l*%d*%[?%-?%d*%]?)"
  ladoesquerdo = string.match(line, str2)

  -- identifica qual operador temos
  cmp = regexComparacao(line) 
  
  if cmp ~= nil then
    -- identifica o lado direito da operaçao
    str3 = "if%s+%l*%d*%[?%-?%d*%]?".. "%s+" .. cmp .. " (%l*%d*%[?%-?%d*%]?)" -- pode dar erro no terminal se o CMP for nill
    ladodireito = string.match(line, str3)
  end

  -- mudar onde ele é chamado
  -- regexAtribuicao(line)

  str4 = "else"
  verificaElse = string.match(line, str4)
  if(verificaElse ~= null) then
    -- tratar else
  end

  str5 = "fi"
  verificaFi = string.match(line, str4)
  if(verificaFi ~= null) then
    -- acaba o if
  end
end


--
-- regex de atribuição
--
function regexAtribuicao(line)
  local rgx, rgx2, rgx3, rgx4
  local variavel, attr, ladoEsquedoOperacao, ladoDireitoOperacao, op, posicaoVetor
  
  -- variável de controle da pilha
  local j = 0 

  -- essa expressão significa que o argumento passado no lado direito da atribuicao pode tanto ser nome, vetor, numero ou chamada de função
  rgx = "(%l*)%[?(%-?%d*)%]?%s+(=)%s+(%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?)"
  variavel, posicaoVetor, attr, ladoEsquedoOperacao = string.match(line, rgx)

  rgx2 = "%l*%[?(%-?%d*)%]?%s+=%s+%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?([%+%-%*%/])"
  op = string.match(line, rgx2)

  if variavel == nil then
    return nil
  end

  -- se for nula faz uma atribuição
  if(op == nil) then

    -- olhar quem está na posição 1 até o fim da tabelade funcoes, pra fazer a atribuição a variável correta
    for i = 1, #pilha do

      -- caso a variável não esteja no escopo atual procuramos na função chamada anteriormente, simulação de escopo dinâmico
      if tabelafuncoes[pilha[#pilha+j]][variavel] == nil then 
        j = j-1
      -- atribuições começam aqui
      else
        
        -- é uma função
        if string.match(ladoEsquedoOperacao,"%l+%(") then
          regexChamadaFuncao(line)
          return true
        end
        
        -- verificar se é um vetor
        if posicaoVetor == nil or posicaoVetor == "" then
          tabelafuncoes[pilha[#pilha+j]][variavel] = ladoEsquedoOperacao
        -- se for um vetor a gente faz outro tipo de atribuição
        else
          -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores positivos
          if tonumber(posicaoVetor) >= 0 then
            
            posicaoVetor = corrigeVetorPositivo(posicaoVetor)
            --print(type(posicaoVetor))
            tabelafuncoes[pilha[#pilha+j]][variavel][posicaoVetor] = ladoEsquedoOperacao
          -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
          else
            posicaoVetor = tonumber(posicaoVetor)
            posicaoVetor = corrigeVetorNegativo(posicaoVetor, #tabelafuncoes[pilha[#pilha+j]][variavel])
            tabelafuncoes[pilha[#pilha+j]][variavel][posicaoVetor] = ladoEsquedoOperacao
          end


        end
      end
    end
    
    return true
  
  -- caso for uma operação
  else
    -- regex que identifica o lado direito da operação                                                                                 -- vv essa é a parte que queremos vv
    rgx3 = "[%+%-%*%/]%s+(%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?)"
    ladoDireitoOperacao = string.match(line, rgx3)
    print(variavel, attr, ladoEsquedoOperacao, op, ladoDireitoOperacao)
    -- ARRUMAR RETORNO posso retornar a operacao que está sendo feita
  end


end


--
-- regex de variavel
--
function regexVar(line)
  local rgx
  local variavel, numeroVetor

  rgx = "var%s+(%l*)%[?(%d*)%]?"
  variavel, numeroVetor = string.match(line, rgx) -- Extração do nome da variável e do número do vetor


  if variavel == nil then
    return nil
  end

  -- Quando a atribuição não possui um vetor a direita da igualdade
  if numeroVetor == "" then 
    tabelafuncoes[pilha[#pilha]][variavel] = 0
    tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  -- Quando a atribuição possui um vetor a direita da igualdade
  else  
    tabelafuncoes[pilha[#pilha]][variavel] = {}
    for i = 1, tonumber(numeroVetor) do
      tabelafuncoes[pilha[#pilha]][variavel][i] = 0
    end
    tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  end

  if numeroVetor ~= "" then
    -- para ver o que tem dentro do vetor
    -- imprimeTabela1(tabelafuncoes[pilha[#pilha]][variavel])
  end
  
  return variavel

end


--
-- regex de begin
--
function regexBegin(line)
  local rgx = "begin"
  local aux = string.match(line, rgx)
  
  return aux
end


-- ### FIM DO REGEX ###

function corrigeVetorPositivo(posicaoVetor) 
  return posicaoVetor + 1
end

function corrigeVetorNegativo(posicaoVetor, tamanhoVetor)
  return posicaoVetor + tamanhoVetor + 1
end

function imprimeTabela1(t)
  for k, v in pairs(t) do
    print("tabela:", k, v)
  end
end


function imprimeTabela2(t)
  for k, v in pairs(t) do
    print("tabela:", k, v)
    
    for v, j in pairs(v) do
      print(v, j)
    end
  end
end

function imprimePilha()
  for k, v in pairs(pilha) do
    print("pilha:", k, v)
  end
  print()
end


function iniciaInterpretador(line)
  if regexDeclaracaoFuncao(line) ~= nil then
    -- imprimeTabela1(tabelafuncoes)
    -- imprimePilha()
    return 
  elseif regexVar(line) ~= nil then
    imprimeTabela2(tabelafuncoes)
    print("\n")
    return 
  elseif regexBegin(line) ~= nil then
    return
  elseif regexAtribuicao(line) ~= nil then
    imprimeTabela2(tabelafuncoes)
    -- imprimeTabela1(tabelafuncoes[pilha[#pilha]]["x"])
    -- imprimeTabela1(tabelafuncoes[pilha[#pilha]]["i"])
    return
  -- elseif regexIf(line) ~= nil then
  --   teste = regexDeclaracaoFuncao(line)
  -- elseif regexChamadaFuncao(line) ~= nil then
  --   teste = regexDeclaracaoFuncao(line)
  end
end


--
-- Imprime cada uma das linhas do arquivo
--
for line in file:lines() do
  -- print(line)

  iniciaInterpretador(line)
end

file:close()