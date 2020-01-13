--- ### VARIAVEIS GLOBAIS ### ---

-- Tabela que armazena todas as funções e suas variáveis
tabelafuncoes = {}

-- Tabela que simula o escopo dinâmico, sempre que uma função é chamada ela é empilhada nesta tabela
pilha = {}

-- Tabela que armazena todo o arquivo, linha por linha
tabelaarquivo = {}

-- Índice atual do vetor da tabela de arquivos que é uma cópia do arquivo, 
linhaAtual = 0


--- ### ABERTURA DO ARQUIVO ### ---

--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = "./Testes/codigo1.txt"
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
-- regex para comparação do if
-- 
function regexComparacao(line)
  local comp = "==" 
  local cmp = string.match(line, comp) 
  
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

  local assinatura, nomefuncao, p1, p2, p3 = string.match(line,str0)

  if nomefuncao ~= nil then
    -- Cria uma tabela para a função, e cria variáveis que são padrão para todas as funções
    tabelafuncoes[nomefuncao] = {}
    
    -- Colocamos na pilha na declaração para acessarmos a pilha correta na hora da atribuição das variáveis na chamada de regexVarParametros
    pilha[#pilha+1] = nomefuncao
    tabelafuncoes[nomefuncao]["posicaoNoArquivo"] = i
    tabelafuncoes[nomefuncao]["posicaoInicialNoArquivo"] = i
    
    -- p1, p2 e p3 são os parâmetros das funções, caso exista
    tabelafuncoes[nomefuncao]["p1"] = p1
    tabelafuncoes[nomefuncao]["p2"] = p2
    tabelafuncoes[nomefuncao]["p3"] = p3
    
    -- Atribui 0 aos paramêtros, caso eles existam, e à variável ret
    regexVarParametros(nomefuncao, p1, p2, p3, i)
  
    -- Retorna o nome para o retorno ser diferente de nulo 
    return nomefuncao
  else
    -- Retornamos nulo para o programa prosseguir na execução (na primeira passada)
    return nil
  end
end

--
-- regex para declaração de função para resolver recursão
--
function copiaRegexDeclaracaoFuncao(line, i, nomefuncaoconcatenada)
  -- A diferença entre copiaRegexDeclaracaoFuncao e regexDeclaracaoFuncao é que quando a função é recursiva, 
  -- nós concatenamos a palavra recursão no nome da função original, e este nome modificado é passado como a variável nomefuncaoconcatenada
  local str0 = "(function%s+(%l+)%((%l*),?(%l*),?(%l*)%))"
  
  local assinatura, nomefuncao, p1, p2, p3 = string.match(line,str0)

  if nomefuncao ~= nil then
    -- Cria uma tabela para a função, e cria variáveis que são padrão para todas as funções
    tabelafuncoes[nomefuncaoconcatenada] = {}
    pilha[#pilha+1] = nomefuncaoconcatenada
    tabelafuncoes[nomefuncaoconcatenada]["posicaoNoArquivo"] = i
    tabelafuncoes[nomefuncaoconcatenada]["posicaoInicialNoArquivo"] = i
    
    -- p1, p2 e p3 são os parâmetros das funções, caso exista
    tabelafuncoes[nomefuncaoconcatenada]["p1"] = p1
    tabelafuncoes[nomefuncaoconcatenada]["p2"] = p2
    tabelafuncoes[nomefuncaoconcatenada]["p3"] = p3
    
    -- Atribui 0 aos paramêtros, caso eles existam, e à variável ret
    regexVarParametros(nomefuncaoconcatenada, p1, p2, p3, i)
    
    -- Retorna o nome para o retorno ser diferente de nulo
    return nomefuncaoconcatenada
  else
    -- Retornamos nulo para o programa prosseguir na execução (na primeira passada)
    return nil
  end
end


--
-- regex para identificar chamadas de funções
--
function regexChamadaFuncao(variavel)
  local str0 = "((%l+)%((%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?)%))" 
  local aux, tmp

	local assinatura, nomefuncao, p1, p2, p3 = string.match(variavel,str0)	

  -- Caso a variavel não for uma chamada de função, nós retornamos nil
  if variavel == nil or variavel == "" or string.match(variavel,"%l+%(") == nil or string.match(variavel,"%l+%(") == "" then
    return nil
  end

  -- Trata chamadas recursivas
  -- A pilha recebe o nome da função no topo, para saber qual foi a última função que foi chamada
  -- Se na posicao pilha[#pilha] == nomefuncao, teremos que criar uma nova funcao na tabelafuncoes, com um nome diferente e fazer ela ser a funcao atual
  if string.match(pilha[#pilha], nomefuncao) == pilha[#pilha] or string.match(pilha[#pilha], nomefuncao .. "recursao") then     
    -- Nome da função que representa a recursão
    tmp = pilha[#pilha] .. "recursao"

    -- Declara a função em sua forma recursiva, alocando apenas seus parâmetros
    copiaPrimeiraPassada(tabelaarquivo[tabelafuncoes[nomefuncao]["posicaoInicialNoArquivo"]], tabelafuncoes[nomefuncao]["posicaoInicialNoArquivo"], tmp)
    
    -- Aponta a execução da função que representa a recursão para a linha das declarações das variáveis, caso elas existam 
    tabelafuncoes[tmp]["posicaoNoArquivo"] = tabelafuncoes[tmp]["posicaoNoArquivo"] + 1

    -- Atribuição dos valores que passamos como parâmetro na chamada de função
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
    
    -- Declara as variáveis e apontando a execução para a linha do begin
    while true do
      local tmp2
      tmp2 = copiaPrimeiraPassada(tabelaarquivo[tabelafuncoes[tmp]["posicaoNoArquivo"]], tabelafuncoes[tmp]["posicaoNoArquivo"], tmp)
      if tmp2 == "begin" then
        break
      end
      tabelafuncoes[tmp]["posicaoNoArquivo"] = tabelafuncoes[tmp]["posicaoNoArquivo"] + 1
    end
  
  -- Trata chamadas não recursivas
  else
    
    -- Empilha a função a função chamada
    pilha[#pilha+1] = nomefuncao

    -- Trata exclusivamente a chamada da função print
    if nomefuncao == "print" then
      -- Desempilhamos porque ao chamar print() ele é empilhado
      pilha[#pilha] = nil
      p1 = extraiNumero(p1)
      print(p1)
      return tabelafuncoes[pilha[#pilha]]["ret"]
    end
    
    -- Atribuição dos valores que passamos como parâmetro na chamada de função
    if p1 ~= nil or p1 ~= "" then
      -- Chamamos a copiaExtraiNumero ao invés do extraiNumero porque ao passarmos paramêtros como paramêtro para próxima função devemos fazer a atribuição, e nosso
      -- extrai número não faz isso, ele pula a função caso a atribuição seja de paramêtros
      p1 = copiaExtraiNumero(p1, "p1")
      tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p1"]] = p1
    end
    
    if p2 ~= nil or p2 ~= "" then
      p2 = copiaExtraiNumero(p2, "p2")
      tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p2"]] = p2
    end

    if p3 ~= nil or p3 ~= "" then
      p3 = copiaExtraiNumero(p3, "p3")
      tabelafuncoes[pilha[#pilha]][tabelafuncoes[pilha[#pilha]]["p3"]] = p3
    end

  end

  -- Pula o begin (prepara a execução da função em si)
  tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1

  while linhaAtual <= #tabelaarquivo do
    
    -- segundaPassada representa a execução do corpo da função
    aux = segundaPassada(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
    
    -- Se o aux for 'end' paramos a execução da função
    if aux == "end" then
      -- Criamos uma variavel auxiliar para receber o ret para que possamos desempilhar a função
      local tmp3 = tabelafuncoes[pilha[#pilha]]["ret"]
      
      -- Aponta pra posição inicial da função para procurarmos o begin
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoInicialNoArquivo"]
      
      -- Procura o begin
      while true do
        if regexBegin(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]], tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]) == "begin" then 
          break
        end
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      end

      -- Desempilha a função pois ela chegou ao fim da sua execução (end)
      pilha[#pilha] = nil

      -- tmp3 representa o ret da função, que sempre deve ser retornado
      return tmp3
    end

    -- Ir para próxima linha da função que chamou a função antes da recursão main -> foo -> foorecursao
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
  end
  
end

--
-- regex do if
--
function regexIf(line)
  local str, str2, str3, str4, str5, str6
  local verificaIf, verificaElse, ladoEsquerdo, ladoDireito, cmp, localLadoEsquerdo, localLadoDireito, posicaoVetorLadoEsquerdo, posicaoVetorLadoDireito, aux

  -- identifica se é um if
  str = "if"
  verificaIf = string.match(line, str)


  if verificaIf == nil or verificaIf == "" then
    return nil
  end

  str6 = "if%l+"
  verificaIf = string.match(line, str6)
  if verificaIf ~= nil then
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

  -- extrai os valores numéricos das variaveis do lado esquerdo e direito
  ladoEsquerdo = extraiNumero(ladoEsquerdo)
  ladoDireito = extraiNumero(ladoDireito)
  

  -- tratamento de cada tipo de comparação
  if cmp == "==" then
    -- se a comparação for verdadeira
    if ladoEsquerdo == ladoDireito then
      
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
      
    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      -- se tiver else a gente entra aqui
      if aux == "else" then
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
    return 1
    
  elseif cmp == "!=" then
    -- se a comparação for verdadeira
    if ladoEsquerdo ~= ladoDireito then

      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then

        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
    return 1

  elseif cmp == ">" then
    -- se a comparação for verdadeira
    
    if ladoEsquerdo > ladoDireito then
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        -- faz uma operação ou attr
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
    return 1

  elseif cmp == "<" then
    -- se a comparação for verdadeira
    if ladoEsquerdo < ladoDireito then
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
    return 1

  elseif cmp == ">=" then
    -- se a comparação for verdadeira
    if ladoEsquerdo >= ladoDireito then
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
    return 1

  elseif cmp == "<="  then
    -- se a comparação for verdadeira
    if ladoEsquerdo <= ladoDireito then
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
      -- faz a operação ou atribuição
      regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])

    -- se a comparação é falsa ele vai para o else
    else
      -- procuramos a palavra else OU fi caso não tenha else
      tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"], aux = procuraPalavra("else")
      
      -- se tiver else a gente entra aqui
      if aux == "else" then
        tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
        -- faz uma operação ou attr
        regexOperacao(tabelaarquivo[tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]])
        -- pula duas linhas para pular o else e a linha de attr ou op       
      end
    end
    
    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = procuraPalavra("fi")
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
    
  -- TRATAR VARIAVEL
  
  -- se a variável é um vetor
  if string.match(variavel,"%l+%[") then
    
    posicaoVetorVariavel = string.match(variavel, "(%-?%d+)")
    posicaoVetorVariavel = tonumber(posicaoVetorVariavel)
    variavel = string.match(variavel, "(%l+)")
    
    if posicaoVetorVariavel >= 0 then
      posicaoVetorVariavel = corrigeVetorPositivo(posicaoVetorVariavel)
      verificaVetor(variavel, posicaoVetorVariavel, 0)
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel][posicaoVetorVariavel] = ladoEsquerdo

    -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetorVariavel = corrigeVetorNegativo(posicaoVetorVariavel, #tabelafuncoes[pilha[#pilha+localVariavel]][variavel])
      verificaVetor(variavel, posicaoVetorVariavel, 0)
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


  -- Se for uma operação
  if op ~= nil and op ~= "" then

    ladoEsquerdoOperacao = extraiNumero(ladoEsquerdoOperacao)
    ladoDireitoOperacao = extraiNumero(ladoDireitoOperacao)

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
  -- Quando a atribuição for um vetor
  else  
    tabelafuncoes[pilha[#pilha]][variavel] = {}
    for i = 1, tonumber(numeroVetor) do
      tabelafuncoes[pilha[#pilha]][variavel][i] = 0
    end
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
  end

  if p2 ~= nil and p2 ~= "" then
    tabelafuncoes[nomefuncao][p2] = 0
  end

  if p3 ~= nil and p3 ~= "" then
    tabelafuncoes[nomefuncao][p3] = 0
  end
  
  tabelafuncoes[nomefuncao]["ret"] = 0
  tabelafuncoes[nomefuncao]["posicaoNoArquivo"] = i
end

--
-- regex de begin
--
function regexBegin(line, i)
  local rgx = "begin", rgx2, verificaBegin
  local aux
  
  aux = string.match(line, rgx)

  if aux == "begin" then
    rgx2 = "begin%l+"
    verificaBegin = string.match(line, rgx2)
    if verificaBegin ~= nil then
      return nil
    end

    tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = i
    return aux
  else
    return nil
  end
end


-- ### FUNÇÕES AUXILIARES ###


function verificaVetor(nomeVetor, i, localizacao)
  if tabelafuncoes[pilha[#pilha+localizacao]][nomeVetor][i] == nil then
    print("ERRO!")
    os.exit(1)
  end
  return 1
end

-- procura fi ou else
function procuraPalavra(string)
  local j = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"]
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

function extraiNumero(variavel, qualParametro)
  local localVariavel
  
  --Se a variável for uma função
  if string.match(variavel,"%l+%(") then
    return transformaLado(nil, variavel)

  -- Se a variável for um número, variável ou um vetor
  else
    localVariavel = acharPosicao(variavel, qualParametro)
    variavel = transformaLado(localVariavel, variavel, string.match(variavel, "%[(%-?%d*)%]"))
    return variavel
  end
  
end

function copiaExtraiNumero(variavel, qualParametro)
  local localVariavel
  
  --Se a variável for uma função
  if string.match(variavel,"%l+%(") then
    return transformaLado(nil, variavel)

  -- Se a variável for um número, variável ou um vetor
  else
    localVariavel = copiaAcharPosicao(variavel, qualParametro)
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
      verificaVetor(variavel, posicaoVetor, localizacao)
      return tabelafuncoes[pilha[#pilha+localizacao]][variavel][posicaoVetor]

    -- Corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetor = corrigeVetorNegativo(posicaoVetor, #tabelafuncoes[pilha[#pilha+localizacao]][variavel])
      verificaVetor(variavel, posicaoVetor, localizacao)
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
function acharPosicao(variavel, qualParametro)
  local j = 0
    
  -- se for um vetor extraimos o NOME dele
  if string.match(variavel,"%l+%[") ~= nil and string.match(variavel,"%l+%[") ~= "" then
    variavel = string.match(variavel,"(%l+)")
  end
  
  -- Se a função tiver um parâmetro nós decrementamos o j para apontar para a função anterior na pilha, porque ela estava apontando para ela mesma, e o correto quando
  -- Se é um paramêtro procuramos na função anterior
  if tabelafuncoes[pilha[#pilha]][qualParametro] ~= nil and tabelafuncoes[pilha[#pilha]][qualParametro] ~= "" then
    j = j-1
  end

  -- Procura a posição da variavel, seja ela um vetor, uma variável ou um número, no máximo até a main (se pilha[#pilha+j] passar da main é nil)
  while pilha[#pilha+j] ~= nil do
    -- Se j < 0 significa que estamos olhando funções anteriores e só podemos utilizar variáveis que são declaradas (Ex: var algumacoisa), logo voltamos a pilha se
    -- a variável for um paramêtro 
    if j < 0 and variavel ~= "" then
      -- Verificamos se a variável usada é parâmetro da função que a chamou
      if variavel == tabelafuncoes[pilha[#pilha+j]]["p1"] or variavel == tabelafuncoes[pilha[#pilha+j]]["p2"] or variavel == tabelafuncoes[pilha[#pilha+j]]["p3"] then 
        j = j-1
      end
    end

    -- Se j == 0, pula-se o if de cima e olhamos tanto os paramêtros quanto as variáveis locais
    if tabelafuncoes[pilha[#pilha+j]][variavel] == nil then 
      j = j-1
    else
      break
    end
  end

  return j
end

function copiaAcharPosicao(variavel, qualParametro)
  local j = 0
    
    -- se for um vetor extraimos o NOME dele
    if string.match(variavel,"%l+%[") ~= nil and string.match(variavel,"%l+%[") ~= "" then
      variavel = string.match(variavel,"(%l+)")
    end
    
    -- Se a função tiver um parâmetro nós decrementamos o j para apontar para a função anterior na pilha, porque ela estava apontando para ela mesma, e o correto quando
    -- Se é um paramêtro procuramos na função anterior
    if tabelafuncoes[pilha[#pilha]][qualParametro] ~= nil and tabelafuncoes[pilha[#pilha]][qualParametro] ~= "" then
      j = j-1
    end
 
    -- Procura a posição da variavel, seja ela um vetor, uma variável ou um número, no máximo até a main (se pilha[#pilha+j] passar da main é nil)
    while pilha[#pilha+j] ~= nil do
      -- Se j == 0, pula-se o if de cima e olhamos tanto os paramêtros quanto as variáveis locais
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
    print("\n")
  end
  
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
    -- tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] = tabelafuncoes[pilha[#pilha]]["posicaoNoArquivo"] + 1
    return 1
  elseif regexBegin(line, i) ~= nil then
    return 1
  end
end

function copiaPrimeiraPassada(line, i, nomefuncaoconcatenada)
  if copiaRegexDeclaracaoFuncao(line, i, nomefuncaoconcatenada) ~= nil then
    return 1
  elseif regexVar(line) ~= nil then
    return 1
  elseif regexBegin(line, i) ~= nil then
    return "begin"
  end
end

-- Executa as funções
function segundaPassada(line)
  if string.match(line, "end") == "end" then
    return "end"
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

  -- Transforma o arquivo em um vetor de strings e faz a declaração de todas as funções e suas variáveis
  for line in file:lines() do
    tabelaarquivo[i] = line
    primeiraPassada(line, i)
    i = i + 1
  end
  
  -- esvaziando a pilha
  pilha = {"main"}

  -- Executa as funções
  linhaAtual = tabelafuncoes["main"]["posicaoNoArquivo"] + 1
  
  while linhaAtual <= #tabelaarquivo do
    tabelafuncoes["main"]["posicaoNoArquivo"] = linhaAtual
    
    aux = segundaPassada(tabelaarquivo[linhaAtual])
    
    if aux == "end" then
      break
    end

    linhaAtual = linhaAtual + 1
  end
end

-- ### INÍCIO DO PROGRAMA ###

inicia()

file:close()