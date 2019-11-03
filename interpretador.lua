--- ### VARIAVEIS GLOBAIS ### ---

tabelafuncoes = {}
pilha = {}
tabelaarquivo = {}
linhaAtual = {"valor"} -- Índice atual do vetor da tabela de arquivos que é uma cópia do arquivo
                       -- A linha atual é uma tabela pois se fosse uma variável ela estava retornando o valor errado

--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = "./Testes/codigo2.txt"
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
    tabelafuncoes[nomefuncao]["posicaoNoArquivo"] = i

    -- p1, p2 e p3 são variáveis que basicamente dizem se tais paramêtros existem para podermos identifica-los na hora da chamada da função
    tabelafuncoes[nomefuncao]["p1"] = p1
    tabelafuncoes[nomefuncao]["p2"] = p2
    tabelafuncoes[nomefuncao]["p3"] = p3

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
  local aux

  -- retorno0 recebe a string completa, recebe a assinatura da função completa, seja ela print ou não
  -- retorno1 recebe o nome da função, para assim fazer a comparação e decidir se ela é print ou não
	local assinatura, nomefuncao, p1, p2, p3 = string.match(variavel,str0)	


  if variavel == nil or variavel == "" then
    return nil
  end

  -- O ERRO ESTA AQUI, ELE ESTA CHEGANDO AQUI MAS A VARIAVEL TA COM O NOME "VAR X" MAS NAO PODE SER ASSIM
  print(variavel)

  -- A pilha recebe o nome da função no topo, para saber qual foi a última função que foi chamada
  pilha[#pilha+1] = nomefuncao

  if nomefuncao == "print" then
    pilha[#pilha] = nil
    p1 = extraiNumero(p1)
    print(p1)
    return tabelafuncoes[pilha[#pilha]]["ret"]
  end

  -- Aqui nós estamos atribuindo os valores (numéricos) que passamos como parâmetro na chamada de função
  if p1 ~= nil or p1 ~= "" then
    p1 = extraiNumero(p1)
    tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p1"]] = p1
  end

  if p2 ~= nil or p2 ~= "" then
    p2 = extraiNumero(p2)
    tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p2"]] = p2
  end

  if p3 ~= nil or p3 ~= "" then
    p3 = extraiNumero(p3)
    tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p3"]] = p3
  end

  while linhaAtual["valor"] <= #tabelaarquivo do
    
    aux = segundaPassada(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
    if aux == "end" then
      -- tiramos a função da pilha
      pilha[#pilha] = nil      
      return tabelafuncoes[pilha[#pilha]]["ret"]
    end
  end
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

  --imprimeTabela2(tabelafuncoes)

  -- identifica o lado esquerdo da operaçao                               
  str2 = "if%s+(%l*%d*%[?%-?%d*%]?)"
  ladoEsquerdo = string.match(line, str2)

  -- identifica qual operador temos
  cmp = regexComparacao(line) 
  
  -- identifica o lado direito da operaçao
  str3 = "if%s+%l*%d*%[?%-?%d*%]?".. "%s+" .. cmp .. " (%l*%d*%[?%-?%d*%]?)" 
  ladoDireito = string.match(line, str3)

  -- extrai os valores numéricos das variaveis do lado esquerdo e direito
  ladoEsquerdo = extraiNumero(ladoEsquerdo)
  ladoDireito = extraiNumero(ladoDireito)
  
  -- tratamento de cada tipo de comparação
  if cmp == "==" then
    -- se a comparação for verdadeira
    if ladoEsquerdo == ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1
    
  elseif cmp == "!=" then
    -- se a comparação for verdadeira
    if ladoEsquerdo ~= ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1

  elseif cmp == ">" then
    -- se a comparação for verdadeira
    
    if ladoEsquerdo > ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1

  elseif cmp == "<" then
    -- se a comparação for verdadeira
    if ladoEsquerdo < ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1

  elseif cmp == ">=" then
    -- se a comparação for verdadeira
    if ladoEsquerdo >= ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1

  elseif cmp == "<="  then
    -- se a comparação for verdadeira
    if ladoEsquerdo <= ladoDireito then
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      linhaAtual["valor"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[linhaAtual["valor"] + 1])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    linhaAtual["valor"] = procuraPalavra("fi")
    return 1

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
  ladoEsquerdo = extraiNumero(ladoEsquerdo)
  
  -- FUNCIONAVA CORRETAMENTE
  
  -- se for uma função
  -- if string.match(ladoEsquerdo,"%l+%(") then
  --   -- tratar o caso de ser função
  
  -- -- se o lado esquerdo for um vetor
  -- elseif string.match(ladoEsquerdo,"%l+%[") then
  --   posicaoVetorLadoEsquerdo = string.match(ladoEsquerdo, "%l+%[(%-?%d+)%]")
  --   localLadoEsquerdo = acharPosicao(string.match(ladoEsquerdo, "(%l+)"))
  --   ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo, posicaoVetorLadoEsquerdo)
  
  -- -- se o lado esquerdo for uma variável
  -- elseif string.match(ladoEsquerdo,"%l+") then
  --   localLadoEsquerdo = acharPosicao(ladoEsquerdo)
  --   ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo)
  
  -- --se o lado esquerdo for um número
  -- else
  --   ladoEsquerdo = transformaLado(localLadoEsquerdo, ladoEsquerdo)
  -- end
  
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
    
    ladoEsquerdoOperacao = extraiNumero(ladoEsquerdoOperacao)
    ladoDireitoOperacao = extraiNumero(ladoDireitoOperacao)

    -- FUNCIONAVA CORRETAMENTE

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
  local aux
  
  aux = string.match(line, rgx)
  
  if aux == "begin" then
    return aux
  else
    return nil
  end
end


-- ### FIM DO REGEX ###

-- REVER DEPOIS
-- procura fi ou else
function procuraPalavra(string)
  local j = linhaAtual["valor"]
  local i 
  for i = j, #tabelaarquivo do
    -- procura um else e retorna sua posição
    if string.match(tabelaarquivo[i], string) == string then
      return i, string
    -- caso o else nao exista a gente procura o fi
    elseif string.match(tabelaarquivo[i], "fi") == "fi" then
      return i
    end
  end
end

function extraiNumero(variavel)

  local localVariavel
  
  --Se a variável for uma função
  if string.match(variavel,"%l+%(") then
    return transformaLado(nil, variavel)
  -- Se a variável for um número, variável ou um vetor
  else
    -- print(acharPosicao(variavel))
    localVariavel = acharPosicao(variavel)
    variavel = transformaLado(localVariavel, variavel, string.match(variavel, "%[(%-?%d*)%]"))
    return variavel
  end
  
end

function transformaLado(localizacao, variavel, posicaoVetor)
  -- Se for  uma função
  if string.match(variavel,"%l+%(") then
    -- Tratar depois
    return regexChamadaFuncao(variavel)
  
  -- Se for um vetor
  elseif string.match(variavel,"%l+%[") then
    variavel = string.match(variavel, "(%l+)")
    posicaoVetor = tonumber(posicaoVetor)

    if posicaoVetor >= 0 then
      posicaoVetor = corrigeVetorPositivo(posicaoVetor)
      return tabelafuncoes[pilha[#pilha+localizacao]][variavel][posicaoVetor]

    -- Corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetor = corrigeVetorNegativo(posicaoVetor, #tabelafuncoes[pilha[#pilha+localizacao]][variavel])
      return tabelafuncoes[pilha[#pilha+localizacao]][variavel][posicaoVetor]
    end

  -- Se for uma variavel
  elseif string.match(variavel,"%l+") then
    return tabelafuncoes[pilha[#pilha+localizacao]][variavel]

  -- Se for um numero
  else
    return tonumber(variavel)
  end
end

-- Encontra j tal que: #pilha + j é a posicao na pilha, e pilha[#pilha+j] é a função onde a variável está
function acharPosicao(variavel)
  local j = 0

  if string.match(variavel,"%l+%[") ~= nil or string.match(variavel,"%l+%[") ~= "" then
    variavel = string.match(variavel,"(%l+)")
  end

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
  if string.match(line, "end") == "end" then
    return "end"
  elseif regexBegin(line) ~= nil then
    return 1
  elseif regexOperacao(line) ~= nil then
    return 1
  elseif regexIf(line) ~= nil then
    return 1
  elseif regexChamadaFuncao(line) ~= nil then
    return 1
  end
end

-- Função que executa o interpretador
function inicia()
  local i = 1
  local aux
  --print(#tabelaarquivo)

  -- Transforma o arquivo em um vetor de strings e faz a declaração de todas as funções e suas variáveis
  for line in file:lines() do
    tabelaarquivo[i] = line
    primeiraPassada(line, i)
    i = i + 1
  end
  
  -- esvaziando a pilha
  pilha = {"main"}

  -- Executa as funções
  linhaAtual["valor"] = tabelafuncoes["main"]["posicaoNoArquivo"] + 1
 
  
  while linhaAtual["valor"] <= #tabelaarquivo do
    tabelafuncoes["main"]["posicaoNoArquivo"] = linhaAtual["valor"]
    
    aux = segundaPassada(tabelaarquivo[linhaAtual["valor"]])
    
    if aux == "end" then
      break
    end

    linhaAtual["valor"] = linhaAtual["valor"] + 1 -- Movimentando a linha atual
  end

  -- imprimeTabela2(tabelafuncoes)
  -- imprimeTabela1(tabelafuncoes["main"]["x"])
end

-- ### INÍCIO DO PROGRAMA ###

inicia()

file:close()