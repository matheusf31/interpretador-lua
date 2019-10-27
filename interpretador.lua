--- ### VARIAVEIS GLOBAIS ### ---

tabelafuncoes = {}
pilha = {}
tabelaarquivo = {}


--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = "./Testes/operacao.txt"
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
function regexDeclaracaoFuncao(line, i)
  local str0 = "(function%s+(%l+)%((%l*),?(%l*),?(%l*)%))"

  -- retorno0 recebe a string completa
  -- retorno1 recebe o nome da função que está sendo atribuída, para depois decidir se ela é main ou não
  local assinatura, nomefuncao, p1, p2, p3 = string.match(line,str0)

  --imprimeTabela2(tabelafuncoes)

  if nomefuncao ~= nil then
    -- cria uma tabela para a função
    tabelafuncoes[nomefuncao] = {}
    pilha[#pilha+1] = nomefuncao
    tabelafuncoes[nomefuncao]["numVariaveisNaTabela"] = 1
    regexVarParametros(nomefuncao, p1, p2, p3, i)
    return nomefuncao
  else 
    return nil
  end
end


--
-- regex para identificar chamadas de funções
--
function regexChamadaFuncao(variavel)
	local str0 = "((%l+)%((%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?)%))" 

  -- retorno0 recebe a string completa, recebe a assinatura da função completa, seja ela print ou não
  -- retorno1 recebe o nome da função, para assim fazer a comparação e decidir se ela é print ou não
	local assinatura, nomefuncao, p1, p2, p3 = string.match(variavel,str0)	

  -- A pilha recebe o nome da função no topo, para saber qual foi a última função que foi chamada
  pilha[#pilha+1] = nomefuncao

  -- FINAL DO TRABALHO

	print(assinatura,nomefuncao,p1,p2,p3)
	
	if retorno1 == "print" then
		--Chamar interpretação do print
	else
		return assinatura
  end
  
  -- TEM QUE RETORNAR RET EM FORMA DE NUMERO
  return tabelafuncoes[pilha[#pilha]]["ret"]
end


--
-- regex do if
--
function regexIf(line)
  local str, str2, str3, str4, str5
  local verificaIf, verificaElse, ladoEsquerdo, ladoDireito, cmp, localLadoEsquerdo, localLadoDireito, posicaoVetorLadoEsquerdo, posicaoVetorLadoDireito

  -- identifica se é um if
  str = "if"
  verificaIf = string.match(line, str)

  if verificaIf == nil or verificaIf == "" then
    return nil
  end

  -- identifica o lado esquerdo da operaçao                               
  str2 = "if%s+(%l*%d*%[?%-?%d*%]?)"
  ladoEsquerdo = string.match(line, str2)

  -- identifica qual operador temos
  cmp = regexComparacao(line) 
  
  -- identifica o lado direito da operaçao
  str3 = "if%s+%l*%d*%[?%-?%d*%]?".. "%s+" .. cmp .. " (%l*%d*%[?%-?%d*%]?)" 
  ladoDireito = string.match(line, str3)

  -- se for vetor
  ladoEsquerdo = encontraNumero(ladoEsquerdo)
  ladoDireito = encontraNumero(ladoDireito)
  

  -- tratamento de cada tipo de comparação
  -- if cmp == "==" then
  --   if then
      
  --   elseif then

  --   elseif then

  --   end
  -- elseif cmp == "!=" then
  --   if then

  --   elseif  then

  --   elseif  then

  --   end

  -- elseif cmp == ">" then
  --   if then
      
  --   elseif  then

  --   elseif  then

  --   end

  -- elseif cmp == "<" then
  --   if then
      
  --   elseif  then

  --   elseif  then

  --   end

  -- elseif cmp == ">=" then
    
  --   if then
      
  --   elseif  then

  --   elseif  then

  --   end

  -- elseif cmp == "<="  then
    
  --   if then
      
  --   elseif  then

  --   elseif  then

  --   end

  -- end

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
function regexAtribuicao(variavel,ladoEsquerdo)
  local localVariavel, posicaoVetorLadoEsquerdo, posicaoVetorVariavel, localLadoEsquerdo
  
  -- Encontrando em qual posição da pilha (qual função) a variavel se encontra
  localVariavel = acharPosicao(string.match(variavel, "(%l+)"))

  -- TRATAR LADO ESQUERDO

  -- se for uma função
  if string.match(ladoEsquerdo,"%l+%(") then
    -- tratar o caso de ser função

  -- se o lado esquerdo for um vetor
  elseif string.match(ladoEsquerdo,"%l+%[") then
    posicaoVetorLadoEsquerdo = string.match(ladoEsquerdo, "%l+%[(%-?%d+)%]")
    localLadoEsquerdo = acharPosicao(string.match(ladoEsquerdo, "(%l+)"))
    ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo, posicaoVetorLadoEsquerdo)

  -- se o lado esquerdo for uma variável
  elseif string.match(ladoEsquerdo,"%l+") then
    localLadoEsquerdo = acharPosicao(ladoEsquerdo)
    ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo)

  --se o lado esquerdo for um número
  else
    ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo)
  end

  -- TRATAR VARIAVEL
  
  -- se a variável é um vetor
  if string.match(variavel,"%l+%[") then
    
    posicaoVetorVariavel = string.match(variavel, "(%-?%d+)")
    posicaoVetorVariavel = tonumber(posicaoVetorVariavel)
    variavel = string.match(variavel, "(%l+)")
    
    if posicaoVetorVariavel >= 0 then
      posicaoVetorVariavel = corrigeVetorPositivo(posicaoVetorVariavel)
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel][posicaoVetorVariavel] = ladoEsquerdo

    -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetorVariavel = corrigeVetorNegativo(posicaoVetorVariavel, #tabelafuncoes[pilha[#pilha+localVariavel]][variavel])
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel][posicaoVetorVariavel] = ladoEsquerdo
    end

  -- se a variável é uma palavra
  else
    tabelafuncoes[pilha[#pilha+localVariavel]][variavel] = ladoEsquerdo
  end
    
end


--
-- regex de operacao
--
function regexOperacao(line)
  local rgx, rgx2, rgx3, rgx4
  local variavel, ladoEsquerdoOperacao, ladoDireitoOperacao, op, posicaoVetorVariavel, posicaoVetorLadoEsquerdo, posicaoVetorLadoDireito, resultado
  local localLadoEsquerdo, localLadoDireito

  -- essa expressão significa que o argumento passado no lado esquerdo ou direito da atribuicao pode tanto ser nome, vetor, numero ou chamada de função
  -- alem disso estamos armazenando o operador
  rgx = "(%l*%[?(%-?%d*)%]?)%s+=%s+(%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?)"
  rgx2 = "%l*%[?%-?%d*%]?%s+=%s+%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?%s+([%+%-%*%/])"  
  rgx3 = "[%+%-%*%/]%s+(%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?)"

  variavel, posicaoVetorVariavel, ladoEsquerdoOperacao = string.match(line, rgx)
  op = string.match(line, rgx2)
  ladoDireitoOperacao = string.match(line, rgx3)

  if variavel == nil or variavel == "" then
    return nil
  end
  
  -- A PARTIR DAQUI TUDO FOI COPIADO

  -- Se for uma operação
  if op ~= nil and op ~= "" then

    ladoEsquerdoOperacao = encontraNumero(ladoEsquerdoOperacao)
    ladoDireitoOperacao = encontraNumero(ladoDireitoOperacao)

    -- TRATANDO LADO ESQUERDO

    -- se for função
    -- if string.match(ladoEsquerdoOperacao,"%l+%(") then
    --   -- tratar o caso de ser função

    -- -- se for vetor
    -- elseif string.match(ladoEsquerdoOperacao,"%l+%[") then
    --   posicaoVetorLadoEsquerdo = string.match(ladoEsquerdoOperacao, "%l+%[(%-?%d+)%]")
    --   localLadoEsquerdo = acharPosicao(string.match(ladoEsquerdoOperacao, "(%l+)"))
    --   ladoEsquerdoOperacao = transformaLado(localLadoEsquerdo, ladoEsquerdoOperacao, posicaoVetorLadoEsquerdo)

    -- -- se for variavel
    -- elseif string.match(ladoEsquerdoOperacao,"%l+") then
    --   localLadoEsquerdo = acharPosicao(ladoEsquerdoOperacao)
    --   ladoEsquerdoOperacao = transformaLado(localLadoEsquerdo, ladoEsquerdoOperacao)

    -- --se for número
    -- else
    --   ladoEsquerdoOperacao = transformaLado(localLadoEsquerdo, ladoEsquerdoOperacao)
    -- end

    -- -- TRATANDO LADO DIREITO
    
    -- -- se for função
    -- if string.match(ladoDireitoOperacao,"%l+%(") then
    --   -- tratar o caso de ser função

    -- -- se for vetor
    -- elseif string.match(ladoDireitoOperacao,"%l+%[") then
    --   posicaoVetorLadoDireito = string.match(ladoDireitoOperacao, "%l+%[(%-?%d+)%]")
    --   localLadoDireito = acharPosicao(string.match(ladoDireitoOperacao, "(%l+)"))
    --   ladoDireitoOperacao = transformaLado(localLadoDireito, ladoDireitoOperacao, posicaoVetorLadoDireito)
      
    -- -- se for variavel
    -- elseif string.match(ladoDireitoOperacao,"%l+") then
    --   localLadoDireito = acharPosicao(ladoDireitoOperacao)
    --   ladoDireitoOperacao = transformaLado(localLadoDireito, ladoDireitoOperacao)

    -- --se for número
    -- else
    --   ladoDireitoOperacao = transformaLado(localLadoDireito, ladoDireitoOperacao)
    -- end

    -- TRATANDO AS OPERAÇÕES
    
    -- se for soma
    if op == '+' then
      resultado = ladoEsquerdoOperacao + ladoDireitoOperacao
    elseif op == '-' then
      resultado = ladoEsquerdoOperacao - ladoDireitoOperacao
    elseif op == '*' then
      resultado = ladoEsquerdoOperacao * ladoDireitoOperacao
    elseif op == '/' then
      resultado = ladoEsquerdoOperacao / ladoDireitoOperacao
      resultado = math.floor(resultado)
    end
    
    regexAtribuicao(variavel,resultado)
    return 1
  -- Se for uma atribuição
  else

    regexAtribuicao(variavel,ladoEsquerdoOperacao)
    return 1
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

  if variavel == nil or variavel == "" then
    return nil
  end

  -- Quando a atribuição não for um vetor
  if numeroVetor == "" then
    tabelafuncoes[pilha[#pilha]][variavel] = 0
    tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  -- Quando a atribuição for um vetor
  else  
    tabelafuncoes[pilha[#pilha]][variavel] = {}
    for i = 1, tonumber(numeroVetor) do
      tabelafuncoes[pilha[#pilha]][variavel][i] = 0
    end
    tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  end

  -- ver o que tem no vetor
  if numeroVetor ~= "" then
    -- para ver o que tem dentro do vetor
    -- imprimeTabela1(tabelafuncoes[pilha[#pilha]][variavel])
  end
  
  return variavel

end

--
-- regex dos paramentros das funções
--
function regexVarParametros(nomefuncao, p1, p2, p3, i)
 
  if p1 ~= nil and p1 ~= "" then
    tabelafuncoes[nomefuncao][p1] = 0
    tabelafuncoes[nomefuncao]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  end

  if p2 ~= nil and p2 ~= "" then
    tabelafuncoes[nomefuncao][p2] = 0
    tabelafuncoes[nomefuncao]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  end

  if p3 ~= nil and p3 ~= "" then
    tabelafuncoes[nomefuncao][p3] = 0
    tabelafuncoes[nomefuncao]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 1
  end
  
  tabelafuncoes[nomefuncao]["ret"] = 0
  tabelafuncoes[nomefuncao]["posicaoNoArquivo"] = i
  tabelafuncoes[nomefuncao]["numVariaveisNaTabela"] = tabelafuncoes[pilha[#pilha]]["numVariaveisNaTabela"] + 2
  
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

function encontraNumero(variavel)
  local localVariavel
  localVariavel = acharPosicao(variavel)
  variavel = transformaLado(localVariavel, variavel, string.match(variavel, "(%-?%d*)"))
  return variavel
end

function transformaLado(localizacao, variavel, posicaoVetor)
  -- se for  uma função
  if string.match(variavel,"%l+%(") then
    -- tratar depois
    -- return regexChamadaFuncao(variavel)

  -- se for um vetor
  elseif string.match(variavel,"%l+%[") then
    variavel = string.match(variavel, "(%l+)")
    posicaoVetor = tonumber(posicaoVetor)

    if posicaoVetor >= 0 then
      posicaoVetor = corrigeVetorPositivo(posicaoVetor)
      return tabelafuncoes[pilha[#pilha+localizacao]][variavel][posicaoVetor]

    -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetor = corrigeVetorNegativo(posicaoVetor, #tabelafuncoes[pilha[#pilha+localizacao]][variavel])
      return tabelafuncoes[pilha[#pilha+localizacao]][variavel][posicaoVetor]
    end

  -- se for uma variavel
  elseif string.match(variavel,"%l+") then
    return tabelafuncoes[pilha[#pilha+localizacao]][variavel]

  -- se for um numero
  else
    return tonumber(variavel)
  end
end

-- Encontra j tal que: #pilha + j é a posicao na pilha, e pilha[#pilha+j] é a função onde a variável está
function acharPosicao(variavel)
  local j = 0

  for i = 1, #pilha do
    if tabelafuncoes[pilha[#pilha+j]][variavel] == nil then 
      j = j-1
    else
      break
    end
  end

  return j
end

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
  print("\n")
end

function imprimePilha()
  for k, v in pairs(pilha) do
    print("pilha:", k, v)
  end
  print()
end

function imprimeArqrivo()
  print("\n")
  
  for i = 1, #tabelaarquivo do
    print(i, tabelaarquivo[i])  
  end

  print("\n")
end

-- Declara todas as funções e suas variáveis, ou seja coloca todas as funções e suas variáveis na tabela de funções
function primeiraPassada(line, i)
  if regexDeclaracaoFuncao(line, i) ~= nil then
    return 1
  elseif regexVar(line) ~= nil then
    return 1
  end
end

-- Executa as funções
function segundaPassada(line)
  if regexOperacao(line) ~= nil then
    return 1
  -- elseif regexIf(line) ~= nil then
  --   return 1
  -- elseif regexChamadaFuncao(line) ~= nil then
  --   return 1
  -- end
  end
end

-- Função que executa o interpretador
function inicia()
  local i = 1
  
  -- Transforma o arquivo em um vetor de strings e faz a declaração de todas as funções e suas variáveis
  for line in file:lines() do
    tabelaarquivo[i] = line
    primeiraPassada(line, i)
    i = i + 1
  end

  -- esvaziando a pilha
  pilha = {"main"}

  -- Executa as funções
  -- j = tabelaarquivo["main"][posicaoNoArquivo] para colocarmos o programa para executar direto na main
  -- Ainda é necessário terminar no end da main
  for j = 1, #tabelaarquivo do
    segundaPassada(tabelaarquivo[j])
  end

  imprimeTabela2(tabelafuncoes)
  imprimeTabela1(tabelafuncoes["main"]["x"])
  
end

-- ### INÍCIO DO PROGRAMA ###

inicia()

file:close()